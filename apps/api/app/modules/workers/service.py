"""Worker management for managers (ARCHITECTURE §6, §7, §20)."""

from datetime import date, datetime, time, timedelta
from http import HTTPStatus

from sqlalchemy import Select, func, or_, select, update
from sqlalchemy.dialects.postgresql import Range
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.security import hash_password
from app.core.time import YEREVAN
from app.db.crud import not_found
from app.modules.audit import service as audit
from app.modules.auth.models import RefreshToken
from app.modules.scheduling.models import AssignmentStatus, VisitAssignment
from app.modules.users.models import User, UserRole, Worker
from app.modules.users.service import create_user, normalize_email, normalize_phone
from app.modules.workers.models import WorkerTimeOff
from app.modules.workers.schemas import TimeOffIn, TimeOffOut, WorkerIn, WorkerOut, WorkerPatch


def to_out(worker: Worker, user: User) -> WorkerOut:
    return WorkerOut(
        id=worker.id,
        user_id=user.id,
        employee_code=worker.employee_code,
        first_name=user.first_name,
        last_name=user.last_name,
        full_name=user.full_name,
        phone=user.phone,
        email=user.email,
        locale=user.locale,
        skills=list(worker.skills),
        is_active=worker.is_active and user.is_active,
        must_change_password=user.must_change_password,
    )


async def _get(session: AsyncSession, worker_id: int) -> tuple[Worker, User]:
    row = (
        await session.execute(
            select(Worker, User).join(User, User.id == Worker.user_id).where(Worker.id == worker_id)
        )
    ).first()
    if row is None:
        raise not_found("worker")
    return row[0], row[1]


async def get_worker(session: AsyncSession, worker_id: int) -> WorkerOut:
    return to_out(*await _get(session, worker_id))


async def list_workers(
    session: AsyncSession, *, q: str | None, active: bool | None
) -> list[WorkerOut]:
    stmt = (
        select(Worker, User)
        .join(User, User.id == Worker.user_id)
        .order_by(User.last_name, User.first_name)
    )
    if q:
        like = f"%{q}%"
        stmt = stmt.where(
            or_(
                User.first_name.ilike(like),
                User.last_name.ilike(like),
                User.phone.ilike(like),
                Worker.employee_code.ilike(like),
            )
        )
    if active is not None:
        stmt = stmt.where((Worker.is_active & User.is_active) == active)
    return [to_out(w, u) for w, u in await session.execute(stmt)]


async def create_worker(session: AsyncSession, data: WorkerIn, manager: User) -> WorkerOut:
    user = await create_user(
        session,
        phone=data.phone,
        password=data.initial_password,
        first_name=data.first_name,
        last_name=data.last_name,
        role=UserRole.WORKER,
        email=data.email,
        locale=data.locale,
        must_change_password=True,
        employee_code=data.employee_code,
        created_by=manager.id,
    )
    worker = await session.scalar(select(Worker).where(Worker.user_id == user.id))
    assert worker is not None  # noqa: S101 — create_user made it
    if data.skills:
        worker.skills = data.skills
        await session.commit()
    return to_out(worker, user)


async def _revoke_sessions(session: AsyncSession, user_id: int) -> None:
    await session.execute(
        update(RefreshToken)
        .where(RefreshToken.user_id == user_id, RefreshToken.revoked_at.is_(None))
        .values(revoked_at=func.now())
    )


async def update_worker(
    session: AsyncSession, worker_id: int, patch: WorkerPatch, manager: User
) -> WorkerOut:
    worker, user = await _get(session, worker_id)
    changes = patch.model_dump(exclude_unset=True)
    if "phone" in changes and changes["phone"] is not None:
        user.phone = normalize_phone(changes["phone"])
    for field in ("first_name", "last_name", "locale"):
        if changes.get(field) is not None:
            setattr(user, field, changes[field])
    if "email" in changes:
        user.email = normalize_email(changes["email"]) if changes["email"] else None
    if changes.get("employee_code") is not None:
        worker.employee_code = changes["employee_code"].strip()
    if changes.get("skills") is not None:
        worker.skills = changes["skills"]
    if changes.get("is_active") is not None and changes["is_active"] != user.is_active:
        user.is_active = worker.is_active = changes["is_active"]
        if not user.is_active:
            await _revoke_sessions(session, user.id)
    audit.record(
        session,
        "worker.updated",
        user_id=manager.id,
        entity_type="worker",
        entity_id=worker.id,
        metadata={k: str(v) for k, v in changes.items()},
    )
    try:
        await session.commit()
    except IntegrityError as exc:
        await session.rollback()
        raise AppError(
            "USER_ALREADY_EXISTS",
            "Another user already has this phone, email or employee code.",
            status_code=HTTPStatus.CONFLICT,
        ) from exc
    return to_out(worker, user)


async def reset_password(
    session: AsyncSession, worker_id: int, new_password: str, manager: User
) -> None:
    """The manager's answer to "forgot password" (§7): a temporary password the
    worker must change at next login. All of the worker's sessions are ended."""
    worker, user = await _get(session, worker_id)
    user.password_hash = hash_password(new_password)
    user.must_change_password = True
    await _revoke_sessions(session, user.id)
    audit.record(
        session,
        "worker.password_reset",
        user_id=manager.id,
        entity_type="worker",
        entity_id=worker.id,
    )
    await session.commit()


# --- time off (§8 worker_time_off, §14) -------------------------------------------


def _day_range(first: date, last: date) -> Range[datetime]:
    """Whole Yerevan days [first 00:00, last+1 00:00)."""
    return Range(
        datetime.combine(first, time(), YEREVAN),
        datetime.combine(last + timedelta(days=1), time(), YEREVAN),
        bounds="[)",
    )


async def _time_off_out(
    session: AsyncSession, rows: list[tuple[WorkerTimeOff, str]]
) -> list[TimeOffOut]:
    out = []
    for entry, name in rows:
        assert entry.period.lower is not None and entry.period.upper is not None  # noqa: S101
        booked = await session.scalar(
            select(func.count())
            .select_from(VisitAssignment)
            .where(
                VisitAssignment.worker_id == entry.worker_id,
                VisitAssignment.status != AssignmentStatus.CANCELLED,
                VisitAssignment.period.overlaps(entry.period),
            )
        )
        out.append(
            TimeOffOut(
                id=entry.id,
                worker_id=entry.worker_id,
                worker_name=name,
                first_day=entry.period.lower.astimezone(YEREVAN).date(),
                last_day=(entry.period.upper.astimezone(YEREVAN) - timedelta(days=1)).date(),
                reason=entry.reason,
                note=entry.note,
                booked_tasks=booked or 0,
            )
        )
    return out


def _time_off_query() -> Select[WorkerTimeOff, str]:
    return (
        select(WorkerTimeOff, User.first_name + " " + User.last_name)
        .join(Worker, Worker.id == WorkerTimeOff.worker_id)
        .join(User, User.id == Worker.user_id)
        .order_by(func.lower(WorkerTimeOff.period))
    )


async def list_time_off(
    session: AsyncSession, *, worker_id: int | None, start: date | None, end: date | None
) -> list[TimeOffOut]:
    stmt = _time_off_query()
    if worker_id is not None:
        await _get(session, worker_id)  # 404 for an unknown worker
        stmt = stmt.where(WorkerTimeOff.worker_id == worker_id)
    if start is not None and end is not None:
        stmt = stmt.where(WorkerTimeOff.period.overlaps(_day_range(start, end)))
    return await _time_off_out(session, [(t, name) for t, name in await session.execute(stmt)])


async def create_time_off(
    session: AsyncSession, worker_id: int, data: TimeOffIn, manager: User
) -> TimeOffOut:
    _, user = await _get(session, worker_id)
    entry = WorkerTimeOff(
        worker_id=worker_id,
        period=_day_range(data.first_day, data.last_day),
        reason=data.reason,
        note=data.note,
        created_by=manager.id,
    )
    session.add(entry)
    try:
        await session.flush()
    except IntegrityError as exc:
        await session.rollback()
        if "no_time_off_overlap" in str(exc.orig):
            raise AppError(
                "TIME_OFF_OVERLAP",
                "This worker already has time off on some of these days.",
                status_code=HTTPStatus.CONFLICT,
            ) from exc
        raise
    audit.record(
        session,
        "time_off.created",
        user_id=manager.id,
        entity_type="worker_time_off",
        entity_id=entry.id,
        metadata={
            "worker_id": worker_id,
            "first_day": data.first_day.isoformat(),
            "last_day": data.last_day.isoformat(),
            "reason": data.reason.value,
        },
    )
    await session.commit()
    [out] = await _time_off_out(session, [(entry, user.full_name)])
    return out


async def delete_time_off(session: AsyncSession, time_off_id: int, manager: User) -> None:
    entry = await session.get(WorkerTimeOff, time_off_id)
    if entry is None:
        raise not_found("time off")
    assert entry.period.lower is not None and entry.period.upper is not None  # noqa: S101
    audit.record(
        session,
        "time_off.deleted",
        user_id=manager.id,
        entity_type="worker_time_off",
        entity_id=entry.id,
        metadata={
            "worker_id": entry.worker_id,
            "from": entry.period.lower.isoformat(),
            "to": entry.period.upper.isoformat(),
            "reason": entry.reason.value,
        },
    )
    await session.delete(entry)
    await session.commit()
