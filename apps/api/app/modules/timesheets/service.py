"""Timesheet review (ARCHITECTURE §13 "Timesheets", §20): see every worker's time,
GPS checks, photos and flags; approve, adjust a time entry, override a location.

Approving sets `visit_assignments.reviewed_at`, which is what makes the task's pay
count as earned in the worker app (§8 "Worker pay"). Every action is audited (§31).
"""

import csv
import io
import uuid
from datetime import datetime
from http import HTTPStatus
from typing import Any

from sqlalchemy import Select, case, func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.time import YEREVAN, utcnow
from app.db.crud import not_found
from app.modules.audit import service as audit
from app.modules.files.models import File, FileOwner, FileStatus
from app.modules.files.storage import Storage
from app.modules.materials.models import CatalogItem, SiteMaterialMovement
from app.modules.scheduling.models import AssignmentStatus, Job, JobVisit, VisitAssignment
from app.modules.settings.service import get_operational
from app.modules.sites.models import Site
from app.modules.timesheets.schemas import (
    AdjustIn,
    LocationCheckRowOut,
    MaterialRowOut,
    PhotoOut,
    TimeEntryRowOut,
    TimesheetDetailOut,
    TimesheetRowOut,
)
from app.modules.timetracking.models import (
    AssignmentCompletion,
    CheckPurpose,
    EntryKind,
    LocationCheck,
    TimeEntry,
)
from app.modules.users.models import User, Worker

_REVIEWABLE = (AssignmentStatus.IN_PROGRESS, AssignmentStatus.SUBMITTED)


def _conflict(code: str, message: str) -> AppError:
    return AppError(code, message, status_code=HTTPStatus.CONFLICT)


# --- totals ------------------------------------------------------------------------


async def _totals(session: AsyncSession, ids: list[int]) -> dict[int, tuple[int, int]]:
    """(work, break) seconds per assignment from its entries; open ones until now."""
    if not ids:
        return {}
    seconds = func.extract(
        "epoch", func.coalesce(TimeEntry.ended_at, func.now()) - TimeEntry.started_at
    )
    rows = await session.execute(
        select(
            TimeEntry.assignment_id,
            func.sum(case((TimeEntry.kind == EntryKind.WORK, seconds), else_=0)),
            func.sum(case((TimeEntry.kind == EntryKind.BREAK, seconds), else_=0)),
        )
        .where(TimeEntry.assignment_id.in_(ids))
        .group_by(TimeEntry.assignment_id)
    )
    return {a: (max(0, int(w or 0)), max(0, int(b or 0))) for a, w, b in rows}


# --- list --------------------------------------------------------------------------

RowSelect = Select[VisitAssignment, JobVisit, Job, Site, Worker, User]


def _rows_query() -> RowSelect:
    return (
        select(VisitAssignment, JobVisit, Job, Site, Worker, User)
        .join(JobVisit, JobVisit.id == VisitAssignment.visit_id)
        .join(Job, Job.id == JobVisit.job_id)
        .join(Site, Site.id == Job.site_id)
        .join(Worker, Worker.id == VisitAssignment.worker_id)
        .join(User, User.id == Worker.user_id)
    )


async def _reviewer_names(session: AsyncSession, ids: set[int]) -> dict[int, str]:
    if not ids:
        return {}
    users = await session.scalars(select(User).where(User.id.in_(ids)))
    return {u.id: u.full_name for u in users}


def _row(
    a: VisitAssignment,
    visit: JobVisit,
    job: Job,
    site: Site,
    worker: Worker,
    user: User,
    totals: tuple[int, int],
    reviewers: dict[int, str],
) -> dict[str, Any]:
    assert visit.period.lower is not None and visit.period.upper is not None  # noqa: S101
    return {
        "assignment_id": a.id,
        "worker_id": worker.id,
        "worker_name": user.full_name,
        "employee_code": worker.employee_code,
        "job_id": job.id,
        "job_title": job.title,
        "job_type": job.job_type,
        "site_name": site.name,
        "scheduled_start": visit.period.lower,
        "scheduled_end": visit.period.upper,
        "role": a.role,
        "status": a.status,
        "work_seconds": totals[0],
        "break_seconds": totals[1],
        "review_flags": list(a.review_flags),
        "pay_amount": a.pay_amount,
        "currency": a.currency,
        "reviewed_at": a.reviewed_at,
        "reviewed_by_name": reviewers.get(a.reviewed_by) if a.reviewed_by else None,
    }


async def list_timesheets(
    session: AsyncSession,
    *,
    start: datetime,
    end: datetime,
    worker_id: int | None,
    flagged: bool | None,
    reviewed: bool | None,
) -> list[TimesheetRowOut]:
    lower = func.lower(VisitAssignment.period)
    stmt = (
        _rows_query()
        .where(VisitAssignment.status.in_(_REVIEWABLE), lower >= start, lower < end)
        .order_by(lower, User.last_name)
    )
    if worker_id is not None:
        stmt = stmt.where(VisitAssignment.worker_id == worker_id)
    if flagged is not None:
        has_flags = func.cardinality(VisitAssignment.review_flags) > 0
        stmt = stmt.where(has_flags if flagged else ~has_flags)
    if reviewed is not None:
        stmt = stmt.where(
            VisitAssignment.reviewed_at.is_not(None)
            if reviewed
            else VisitAssignment.reviewed_at.is_(None)
        )
    rows = list(await session.execute(stmt))
    totals = await _totals(session, [r[0].id for r in rows])
    reviewers = await _reviewer_names(session, {r[0].reviewed_by for r in rows if r[0].reviewed_by})
    return [
        TimesheetRowOut(
            **_row(a, visit, job, site, worker, user, totals.get(a.id, (0, 0)), reviewers)
        )
        for a, visit, job, site, worker, user in rows
    ]


# --- detail ------------------------------------------------------------------------


async def _get(session: AsyncSession, assignment_id: int, *, lock: bool = False) -> Any:
    stmt = _rows_query().where(VisitAssignment.id == assignment_id)
    if lock:
        stmt = stmt.with_for_update(of=VisitAssignment)
    row = (await session.execute(stmt)).first()
    if row is None:
        raise not_found("timesheet")
    return row


async def detail(session: AsyncSession, storage: Storage, assignment_id: int) -> TimesheetDetailOut:
    a, visit, job, site, worker, user = await _get(session, assignment_id)
    totals = (await _totals(session, [a.id])).get(a.id, (0, 0))
    reviewers = await _reviewer_names(session, {a.reviewed_by} if a.reviewed_by else set())
    settings = await get_operational(session)
    completion = await session.scalar(
        select(AssignmentCompletion).where(AssignmentCompletion.assignment_id == a.id)
    )
    entries = await session.scalars(
        select(TimeEntry).where(TimeEntry.assignment_id == a.id).order_by(TimeEntry.started_at)
    )
    checks = await session.scalars(
        select(LocationCheck)
        .where(LocationCheck.assignment_id == a.id)
        .order_by(LocationCheck.captured_at)
    )
    photos = await session.scalars(
        select(File)
        .where(
            File.owner_type == FileOwner.ASSIGNMENT,
            File.owner_id == a.id,
            File.status == FileStatus.UPLOADED,
        )
        .order_by(File.created_at)
    )
    materials = await session.execute(
        select(SiteMaterialMovement, CatalogItem)
        .join(CatalogItem, CatalogItem.id == SiteMaterialMovement.catalog_item_id)
        .where(SiteMaterialMovement.assignment_id == a.id)
        .order_by(SiteMaterialMovement.recorded_at)
    )
    return TimesheetDetailOut(
        **_row(a, visit, job, site, worker, user, totals, reviewers),
        site_latitude=float(site.latitude),
        site_longitude=float(site.longitude),
        site_radius_m=float(site.geofence_radius_m or settings.default_geofence_radius_m),
        completed_at=completion.completed_at if completion else None,
        reported_work_seconds=completion.reported_work_seconds if completion else None,
        reported_break_seconds=completion.reported_break_seconds if completion else None,
        comment=completion.comment if completion else None,
        entries=[
            TimeEntryRowOut(
                id=e.id,
                kind=e.kind,
                started_at=e.started_at,
                ended_at=e.ended_at,
                client_clock_offset_s=e.client_clock_offset_s,
                received_at=e.received_at,
            )
            for e in entries
        ],
        checks=[
            LocationCheckRowOut(
                id=c.id,
                purpose=c.purpose,
                latitude=c.latitude,
                longitude=c.longitude,
                accuracy_m=c.accuracy_m,
                is_mocked=c.is_mocked,
                captured_at=c.captured_at,
                client_distance_m=c.client_distance_m,
                server_distance_m=c.server_distance_m,
                radius_m=c.radius_m,
                server_verified=c.server_verified,
                override_reason=c.override_reason,
            )
            for c in checks
        ],
        photos=[
            PhotoOut(
                id=f.id,
                url=storage.presign_get(f.storage_key),
                taken_at=f.taken_at,
                kind=f.kind.value,
            )
            for f in photos
        ],
        materials=[
            MaterialRowOut(
                item_name=item.name_en,
                unit=item.unit.value,
                quantity=m.quantity,
                movement=m.movement,
                note=m.note,
            )
            for m, item in materials
        ],
    )


# --- actions -----------------------------------------------------------------------


def _ensure_not_reviewed(a: VisitAssignment) -> None:
    if a.reviewed_at is not None:
        raise _conflict("ASSIGNMENT_REVIEWED", "This timesheet is already approved.")


async def approve(session: AsyncSession, assignment_id: int, manager: User) -> None:
    a, *_ = await _get(session, assignment_id, lock=True)
    if a.reviewed_at is not None:
        return  # idempotent
    if a.status is not AssignmentStatus.SUBMITTED:
        raise _conflict("NOT_SUBMITTED", "Only submitted tasks can be approved.")
    work, brk = (await _totals(session, [a.id])).get(a.id, (0, 0))
    a.reviewed_by = manager.id
    a.reviewed_at = utcnow()
    audit.record(
        session,
        "timesheet.approved",
        user_id=manager.id,
        entity_type="assignment",
        entity_id=a.id,
        metadata={
            "work_seconds": work,
            "break_seconds": brk,
            "pay_amount": str(a.pay_amount),
            "flags": list(a.review_flags),
        },
    )
    await session.commit()


async def adjust(session: AsyncSession, assignment_id: int, data: AdjustIn, manager: User) -> None:
    a, *_ = await _get(session, assignment_id, lock=True)
    _ensure_not_reviewed(a)
    entry = await session.get(TimeEntry, data.time_entry_id)
    if entry is None or entry.assignment_id != a.id:
        raise not_found("time entry")
    before = {
        "started_at": entry.started_at.isoformat(),
        "ended_at": entry.ended_at.isoformat() if entry.ended_at else None,
    }
    entry.started_at = data.started_at
    entry.ended_at = data.ended_at
    try:
        await session.flush()
    except IntegrityError as exc:
        await session.rollback()
        if "no_time_overlap" in str(exc.orig):
            raise _conflict(
                "TIME_ENTRY_OVERLAP", "This time overlaps another work or break session."
            ) from exc
        raise
    completion = await session.scalar(
        select(AssignmentCompletion).where(AssignmentCompletion.assignment_id == a.id)
    )
    if completion is not None:
        work, brk = (await _totals(session, [a.id])).get(a.id, (0, 0))
        completion.work_seconds, completion.break_seconds = work, brk
    audit.record(
        session,
        "timesheet.adjusted",
        user_id=manager.id,
        entity_type="time_entry",
        entity_id=str(entry.id),
        metadata={
            "assignment_id": a.id,
            "reason": data.reason,
            "before": before,
            "after": {
                "started_at": data.started_at.isoformat(),
                "ended_at": data.ended_at.isoformat(),
            },
        },
    )
    await session.commit()


async def override_location(
    session: AsyncSession, check_id: uuid.UUID, reason: str, manager: User
) -> None:
    """Accepts a check that failed the geofence (e.g. the pin was wrong, §25).
    OUTSIDE_GEOFENCE is cleared once no unexplained outside check remains."""
    check = await session.get(LocationCheck, check_id)
    if check is None:
        raise not_found("location check")
    a, *_ = await _get(session, check.assignment_id, lock=True)
    _ensure_not_reviewed(a)
    check.override_reason = reason
    check.overridden_by = manager.id
    await session.flush()
    remaining = await session.scalar(
        select(func.count())
        .select_from(LocationCheck)
        .where(
            LocationCheck.assignment_id == a.id,
            LocationCheck.purpose != CheckPurpose.MANUAL,
            LocationCheck.server_distance_m > LocationCheck.radius_m,
            LocationCheck.override_reason.is_(None),
        )
    )
    if not remaining and "OUTSIDE_GEOFENCE" in a.review_flags:
        a.review_flags = [f for f in a.review_flags if f != "OUTSIDE_GEOFENCE"]
    audit.record(
        session,
        "location_check.overridden",
        user_id=manager.id,
        entity_type="location_check",
        entity_id=str(check.id),
        metadata={"assignment_id": a.id, "reason": reason},
    )
    await session.commit()


# --- export ------------------------------------------------------------------------


async def export_csv(session: AsyncSession, start: datetime, end: datetime) -> str:
    """Approved tasks for payroll (§13). Hours as decimals, Yerevan dates."""
    rows = await list_timesheets(
        session, start=start, end=end, worker_id=None, flagged=None, reviewed=True
    )
    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(
        [
            "date",
            "employee_code",
            "worker",
            "job",
            "role",
            "work_hours",
            "break_hours",
            "pay_amount",
            "currency",
            "approved_at",
            "approved_by",
        ]
    )
    for r in rows:
        writer.writerow(
            [
                r.scheduled_start.astimezone(YEREVAN).date().isoformat(),
                r.employee_code,
                r.worker_name,
                r.job_title,
                r.role.value,
                f"{r.work_seconds / 3600:.2f}",
                f"{r.break_seconds / 3600:.2f}",
                r.pay_amount if r.pay_amount is not None else "",
                r.currency,
                r.reviewed_at.astimezone(YEREVAN).isoformat(timespec="minutes")
                if r.reviewed_at
                else "",
                r.reviewed_by_name or "",
            ]
        )
    return out.getvalue()
