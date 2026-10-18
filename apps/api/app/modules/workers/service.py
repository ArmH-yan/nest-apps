"""Worker management for managers (ARCHITECTURE §6, §7, §20)."""

from http import HTTPStatus

from sqlalchemy import func, or_, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.security import hash_password
from app.db.crud import not_found
from app.modules.audit import service as audit
from app.modules.auth.models import RefreshToken
from app.modules.users.models import User, UserRole, Worker
from app.modules.users.service import create_user, normalize_email, normalize_phone
from app.modules.workers.schemas import WorkerIn, WorkerOut, WorkerPatch


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
