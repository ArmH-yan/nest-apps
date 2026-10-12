"""GPS checks, work/break time and completion from the worker app (ARCHITECTURE §11,
§18, §19, §21).

Every write is an idempotent PUT keyed by the client UUID:
- same body again            → 200 with the stored record
- different body, final row  → 409
GPS and device time are untrusted: stored as sent, recomputed here, and problems
become review flags instead of rejections. Hard rejections are only authorization,
impossible states and overlapping time.
"""

import uuid
from datetime import datetime, timedelta
from http import HTTPStatus

from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.geo import haversine_m
from app.core.time import utcnow
from app.db.crud import not_found
from app.modules.audit import service as audit
from app.modules.files.models import File, FileOwner, FileStatus
from app.modules.materials.models import SiteMaterialMovement
from app.modules.notifications import service as notifications
from app.modules.notifications.models import NotificationType
from app.modules.scheduling import service as scheduling
from app.modules.scheduling.models import AssignmentRole, AssignmentStatus, JobType
from app.modules.scheduling.transitions import ASSIGNMENT_TRANSITIONS
from app.modules.settings.service import get_operational
from app.modules.timetracking.models import (
    AssignmentCompletion,
    CheckPurpose,
    EntryKind,
    LocationCheck,
    TimeEntry,
)
from app.modules.users.models import UserRole
from app.modules.worker_api.access import TaskContext, add_flags, ensure_writable, own_task
from app.modules.worker_api.dependencies import WorkerContext
from app.modules.worker_api.schemas import CompletionIn, LocationCheckIn, TimeEntryIn

LATE_SYNC_AFTER = timedelta(hours=24)
TOTALS_TOLERANCE_S = 60
_MATERIALS_REQUIRED = {JobType.INSTALLATION, JobType.DISMANTLING}


def _conflict(code: str, message: str, **details: object) -> AppError:
    return AppError(code, message, status_code=HTTPStatus.CONFLICT, details=details)


async def _clock_flags(session: AsyncSession, ctx: TaskContext, me: WorkerContext) -> None:
    if me.clock_offset_s is None:
        return
    limit = (await get_operational(session)).clock_skew_flag_seconds
    if abs(me.clock_offset_s) > limit:
        add_flags(ctx.assignment, "CLOCK_SKEW")


# --- location checks --------------------------------------------------------------


def _same_check(row: LocationCheck, body: LocationCheckIn, task_id: int) -> bool:
    return (
        row.assignment_id == task_id
        and row.purpose == body.purpose
        and row.latitude == body.latitude
        and row.longitude == body.longitude
        and row.accuracy_m == body.accuracy_m
        and row.is_mocked == body.is_mocked
        and row.captured_at == body.captured_at
    )


async def put_location_check(
    session: AsyncSession, me: WorkerContext, check_id: uuid.UUID, body: LocationCheckIn
) -> LocationCheck:
    existing = await session.get(LocationCheck, check_id)
    if existing is not None:
        if existing.worker_id != me.worker.id:
            raise not_found("location check")
        if not _same_check(existing, body, body.task_id):
            raise _conflict("LOCATION_CHECK_FINALIZED", "This location check was already saved.")
        return existing

    ctx = await own_task(session, me.worker.id, body.task_id, lock=True)
    ensure_writable(ctx)
    settings = await get_operational(session)
    radius = float(ctx.site.geofence_radius_m or settings.default_geofence_radius_m)
    distance = haversine_m(
        float(ctx.site.latitude), float(ctx.site.longitude), body.latitude, body.longitude
    )
    accurate = body.accuracy_m <= settings.max_location_accuracy_m
    inside = distance <= radius
    check = LocationCheck(
        id=check_id,
        assignment_id=ctx.assignment.id,
        worker_id=me.worker.id,
        purpose=body.purpose,
        latitude=body.latitude,
        longitude=body.longitude,
        accuracy_m=body.accuracy_m,
        is_mocked=body.is_mocked,
        captured_at=body.captured_at,
        client_distance_m=body.distance_m,
        client_verified=body.verified,
        server_distance_m=round(distance, 1),
        radius_m=radius,
        server_verified=inside and accurate,
    )
    session.add(check)
    flags = []
    if body.purpose is not CheckPurpose.MANUAL and not inside:
        flags.append("OUTSIDE_GEOFENCE")
    if not accurate:
        flags.append("LOW_ACCURACY")
    if body.is_mocked:
        flags.append("MOCK_LOCATION")
    add_flags(ctx.assignment, *flags)
    await _clock_flags(session, ctx, me)
    await session.commit()
    return check


# --- time entries ------------------------------------------------------------------


async def put_time_entry(
    session: AsyncSession, me: WorkerContext, entry_id: uuid.UUID, body: TimeEntryIn
) -> tuple[TimeEntry, AssignmentStatus]:
    ctx = await own_task(session, me.worker.id, body.task_id, lock=True)
    existing = await session.get(TimeEntry, entry_id)
    if existing is not None:
        if existing.worker_id != me.worker.id or existing.assignment_id != ctx.assignment.id:
            raise not_found("time entry")
        same_start = existing.kind == body.kind and existing.started_at == body.started_at
        if same_start and existing.ended_at == body.ended_at:
            return existing, ctx.assignment.status  # replay
        if not same_start or existing.ended_at is not None:
            raise _conflict("TIME_ENTRY_FINALIZED", "This time entry was already closed.")
        # the only allowed change: closing an open entry
        ensure_writable(ctx)
        existing.ended_at = body.ended_at
        await _flush_or_overlap(session)
        _late_sync_flag(ctx, body)
        await _clock_flags(session, ctx, me)
        await session.commit()
        return existing, ctx.assignment.status

    ensure_writable(ctx)
    if body.start_location_check_id is not None:
        check = await session.get(LocationCheck, body.start_location_check_id)
        if check is None or check.assignment_id != ctx.assignment.id:
            raise not_found("location check")
    entry = TimeEntry(
        id=entry_id,
        assignment_id=ctx.assignment.id,
        worker_id=me.worker.id,
        kind=body.kind,
        started_at=body.started_at,
        ended_at=body.ended_at,
        start_location_check_id=body.start_location_check_id,
        client_clock_offset_s=me.clock_offset_s,
    )
    session.add(entry)
    await _flush_or_overlap(session)
    if body.kind is EntryKind.WORK and ctx.assignment.status is AssignmentStatus.ASSIGNED:
        ASSIGNMENT_TRANSITIONS.check(
            ctx.assignment.status, AssignmentStatus.IN_PROGRESS, UserRole.WORKER
        )
        ctx.assignment.status = AssignmentStatus.IN_PROGRESS
        scheduling.on_work_started(session, ctx.job)
        audit.record(
            session,
            "assignment.started",
            user_id=me.user.id,
            entity_type="assignment",
            entity_id=ctx.assignment.id,
        )
    _late_sync_flag(ctx, body)
    await _clock_flags(session, ctx, me)
    await session.commit()
    return entry, ctx.assignment.status


def _late_sync_flag(ctx: TaskContext, body: TimeEntryIn) -> None:
    if utcnow() - (body.ended_at or body.started_at) > LATE_SYNC_AFTER:
        add_flags(ctx.assignment, "LATE_SYNC")


async def _flush_or_overlap(session: AsyncSession) -> None:
    try:
        await session.flush()
    except IntegrityError as exc:
        await session.rollback()
        if "no_time_overlap" in str(exc.orig):
            raise _conflict(
                "TIME_ENTRY_OVERLAP", "This time overlaps another work or break session."
            ) from exc
        raise


# --- completion --------------------------------------------------------------------


def _totals(entries: list[TimeEntry]) -> tuple[int, int]:
    work = brk = 0
    for e in entries:
        assert e.ended_at is not None  # noqa: S101 — closed before totals are computed
        seconds = max(0, int((e.ended_at - e.started_at).total_seconds()))
        if e.kind is EntryKind.WORK:
            work += seconds
        else:
            brk += seconds
    return work, brk


async def put_completion(
    session: AsyncSession,
    me: WorkerContext,
    task_id: int,
    completion_id: uuid.UUID,
    body: CompletionIn,
) -> tuple[AssignmentCompletion, TaskContext]:
    ctx = await own_task(session, me.worker.id, task_id, lock=True)
    existing = await session.scalar(
        select(AssignmentCompletion).where(AssignmentCompletion.assignment_id == task_id)
    )
    if existing is not None:
        if existing.id == completion_id:
            return existing, ctx  # replay
        raise _conflict("TASK_ALREADY_SUBMITTED", "This task was already submitted.")
    ensure_writable(ctx)
    a = ctx.assignment
    settings = await get_operational(session)

    # guards (§11 "Server-side completion rules")
    start_checks = await session.scalar(
        select(func.count())
        .select_from(LocationCheck)
        .where(LocationCheck.assignment_id == a.id, LocationCheck.purpose == CheckPurpose.START)
    )
    if not start_checks:
        raise _conflict("START_CHECK_MISSING", "There is no start location check for this task.")

    photos = list(
        await session.scalars(
            select(File).where(
                File.id.in_(body.photo_ids),
                File.owner_type == FileOwner.ASSIGNMENT,
                File.owner_id == a.id,
            )
        )
    )
    uploaded = {f.id for f in photos if f.status is FileStatus.UPLOADED}
    missing = [str(p) for p in body.photo_ids if p not in uploaded]
    if missing:
        raise _conflict(
            "PHOTOS_NOT_UPLOADED", "Some photos have not been uploaded yet.", photo_ids=missing
        )
    if len(uploaded) < settings.min_completion_photos:
        raise _conflict(
            "NOT_ENOUGH_PHOTOS",
            f"Add at least {settings.min_completion_photos} photo(s).",
            required=settings.min_completion_photos,
        )
    if a.role is AssignmentRole.LEAD and ctx.job.job_type in _MATERIALS_REQUIRED:
        has_materials = await session.scalar(
            select(func.count())
            .select_from(SiteMaterialMovement)
            .where(SiteMaterialMovement.assignment_id == a.id)
        )
        if not has_materials:
            raise _conflict("MATERIALS_REQUIRED", "The crew lead must record materials.")
    if body.completion_location_check_id is not None:
        check = await session.get(LocationCheck, body.completion_location_check_id)
        if check is None or check.assignment_id != a.id:
            raise not_found("location check")

    ASSIGNMENT_TRANSITIONS.check(a.status, AssignmentStatus.SUBMITTED, UserRole.WORKER)

    # close anything still open at the completion time, then recompute (§8)
    entries = list(await session.scalars(select(TimeEntry).where(TimeEntry.assignment_id == a.id)))
    for e in entries:
        if e.ended_at is None:
            e.ended_at = max(body.completed_at, e.started_at)
    await _flush_or_overlap(session)
    work, brk = _totals(entries)
    if (
        abs(work - body.reported_work_seconds) > TOTALS_TOLERANCE_S
        or abs(brk - body.reported_break_seconds) > TOTALS_TOLERANCE_S
    ):
        add_flags(a, "TOTALS_MISMATCH")

    completion = AssignmentCompletion(
        id=completion_id,
        assignment_id=a.id,
        completed_at=body.completed_at,
        completion_location_check_id=body.completion_location_check_id,
        reported_work_seconds=body.reported_work_seconds,
        reported_break_seconds=body.reported_break_seconds,
        work_seconds=work,
        break_seconds=brk,
        comment=body.comment,
    )
    session.add(completion)
    a.status = AssignmentStatus.SUBMITTED
    await session.flush()
    await scheduling.on_assignment_submitted(session, ctx.visit, ctx.job)
    await _clock_flags(session, ctx, me)
    await notifications.notify_worker(
        session,
        me.worker.id,
        NotificationType.SUBMISSION_ACCEPTED,
        data={"assignment_id": a.id, "job_id": ctx.job.id},
        task=ctx.job.title,
    )
    audit.record(
        session,
        "assignment.submitted",
        user_id=me.user.id,
        entity_type="assignment",
        entity_id=a.id,
        metadata={
            "work_seconds": work,
            "break_seconds": brk,
            "photos": len(uploaded),
            "flags": a.review_flags,
        },
    )
    await session.commit()
    return completion, ctx


async def completed_at_by_task(session: AsyncSession, task_ids: list[int]) -> dict[int, datetime]:
    rows = await session.execute(
        select(AssignmentCompletion.assignment_id, AssignmentCompletion.completed_at).where(
            AssignmentCompletion.assignment_id.in_(task_ids)
        )
    )
    return {task_id: at for task_id, at in rows}
