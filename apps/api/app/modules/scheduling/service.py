"""Jobs, visits and crew assignment (ARCHITECTURE §11, §14).

Rules enforced here (and by the database):
- A worker cannot be on two overlapping visits (`no_worker_overlap` → 409 WORKER_ALREADY_BOOKED).
- A crew has exactly one LEAD (schema + partial unique index).
- Status changes go through the transition tables; side effects (job SCHEDULED/DRAFT,
  project SURVEY) happen in the same transaction.
- A submitted assignment cannot be removed; pay can't change once the timesheet is reviewed.
"""

from collections.abc import Sequence
from datetime import datetime
from http import HTTPStatus

from sqlalchemy import exists, select
from sqlalchemy.dialects.postgresql import Range
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.time import yerevan_short
from app.core.transitions import SYSTEM, Actor
from app.db.crud import apply_patch, get_or_404
from app.modules.audit import service as audit
from app.modules.notifications import service as notifications
from app.modules.notifications.models import NotificationType
from app.modules.projects import service as projects
from app.modules.projects.models import Project, ProjectStatus
from app.modules.scheduling.models import (
    AssignmentRole,
    AssignmentStatus,
    Job,
    JobStatus,
    JobStatusHistory,
    JobType,
    JobVisit,
    VisitAssignment,
    VisitStatus,
)
from app.modules.scheduling.schemas import (
    CrewIn,
    CrewMemberOut,
    JobDetailOut,
    JobIn,
    JobOut,
    JobPatch,
    ScheduleEntryOut,
    VisitIn,
    VisitOut,
)
from app.modules.scheduling.transitions import (
    ASSIGNMENT_TRANSITIONS,
    JOB_TRANSITIONS,
    VISIT_TRANSITIONS,
)
from app.modules.users.models import User, Worker

_CLOSED_JOB = {JobStatus.COMPLETED, JobStatus.CANCELLED}
_CANCELLED = AssignmentStatus.CANCELLED  # "active" means status <> CANCELLED


def _period(start: datetime, end: datetime) -> Range[datetime]:
    return Range(start, end, bounds="[)")


def _conflict(code: str, message: str, **details: object) -> AppError:
    return AppError(code, message, status_code=HTTPStatus.CONFLICT, details=details)


# --- status helpers -----------------------------------------------------------------


def set_job_status(
    session: AsyncSession,
    job: Job,
    target: JobStatus,
    actor: Actor,
    user_id: int | None,
    comment: str | None = None,
) -> None:
    if job.status == target:
        return
    JOB_TRANSITIONS.check(job.status, target, actor)
    session.add(
        JobStatusHistory(
            job_id=job.id,
            old_status=job.status,
            new_status=target,
            changed_by=user_id,
            comment=comment,
        )
    )
    job.status = target


async def _job_has_crew(session: AsyncSession, job_id: int) -> bool:
    stmt = select(
        exists()
        .where(VisitAssignment.visit_id == JobVisit.id)
        .where(JobVisit.job_id == job_id)
        .where(JobVisit.status == VisitStatus.PLANNED)
        .where(VisitAssignment.status != _CANCELLED)
    )
    return bool(await session.scalar(stmt))


async def _sync_job_after_crew_change(session: AsyncSession, job: Job) -> None:
    """DRAFT ⇄ SCHEDULED as crews appear/disappear (§11), plus the project side effect."""
    await session.flush()
    has_crew = await _job_has_crew(session, job.id)
    if job.status is JobStatus.DRAFT and has_crew:
        set_job_status(session, job, JobStatus.SCHEDULED, SYSTEM, None)
        if job.job_type is JobType.SURVEY:
            project = await get_or_404(session, Project, job.project_id, "project")
            projects.advance_if_allowed(session, project, ProjectStatus.SURVEY)
    elif job.status is JobStatus.SCHEDULED and not has_crew:
        set_job_status(session, job, JobStatus.DRAFT, SYSTEM, None)


async def _tell(
    session: AsyncSession, assignment: VisitAssignment, job: Job, type_: NotificationType
) -> None:
    """In-app notification for the assigned worker (§26)."""
    await notifications.notify_worker(
        session,
        assignment.worker_id,
        type_,
        data={"assignment_id": assignment.id, "job_id": job.id},
        task=job.title,
        when=yerevan_short(assignment.period.lower),
    )


def _cancel_assignment(assignment: VisitAssignment, actor: Actor) -> None:
    ASSIGNMENT_TRANSITIONS.check(assignment.status, AssignmentStatus.CANCELLED, actor)
    assignment.status = AssignmentStatus.CANCELLED


async def _active_assignments(
    session: AsyncSession, visit_ids: Sequence[int]
) -> list[VisitAssignment]:
    if not visit_ids:
        return []
    rows = await session.scalars(
        select(VisitAssignment).where(
            VisitAssignment.visit_id.in_(visit_ids), VisitAssignment.status != _CANCELLED
        )
    )
    return list(rows)


# --- overlap check --------------------------------------------------------------------


async def _check_not_booked(
    session: AsyncSession, worker_id: int, period: Range[datetime], visit_id: int
) -> None:
    """Friendly 409 with the conflicting visit. The exclusion constraint still guards
    against races between two managers."""
    row = (
        await session.execute(
            select(VisitAssignment.visit_id, Job.id, Job.title)
            .join(JobVisit, JobVisit.id == VisitAssignment.visit_id)
            .join(Job, Job.id == JobVisit.job_id)
            .where(
                VisitAssignment.worker_id == worker_id,
                VisitAssignment.status != _CANCELLED,
                VisitAssignment.visit_id != visit_id,
                VisitAssignment.period.overlaps(period),
            )
            .limit(1)
        )
    ).first()
    if row is not None:
        raise _conflict(
            "WORKER_ALREADY_BOOKED",
            f"The worker is already assigned to “{row.title}” at this time.",
            worker_id=worker_id,
            conflicting_visit_id=row.visit_id,
            conflicting_job_id=row.id,
        )


async def _flush_or_booked(session: AsyncSession) -> None:
    try:
        await session.flush()
    except IntegrityError as exc:
        await session.rollback()
        if "no_worker_overlap" in str(exc.orig):
            raise _conflict(
                "WORKER_ALREADY_BOOKED", "A worker is already assigned at this time."
            ) from exc
        raise


# --- side effects of worker activity (called by timetracking) -----------------------


def on_work_started(session: AsyncSession, job: Job) -> None:
    """The first time entry of any crew member: job SCHEDULED → IN_PROGRESS."""
    if job.status is JobStatus.SCHEDULED:
        set_job_status(session, job, JobStatus.IN_PROGRESS, SYSTEM, None)


_COMPLETES_PROJECT = {
    JobType.INSTALLATION: ProjectStatus.INSTALLED,
    JobType.DISMANTLING: ProjectStatus.DISMANTLED,
}


async def on_assignment_submitted(session: AsyncSession, visit: JobVisit, job: Job) -> None:
    """Visit DONE when every active assignment is SUBMITTED; job COMPLETED when no
    PLANNED visit remains; installation/dismantling then moves the project (§10, §11)."""
    remaining = await session.scalar(
        select(
            exists().where(
                VisitAssignment.visit_id == visit.id,
                VisitAssignment.status.in_(
                    [AssignmentStatus.ASSIGNED, AssignmentStatus.IN_PROGRESS]
                ),
            )
        )
    )
    if remaining:
        return
    VISIT_TRANSITIONS.check(visit.status, VisitStatus.DONE, SYSTEM)
    visit.status = VisitStatus.DONE
    await session.flush()
    planned = await session.scalar(
        select(exists().where(JobVisit.job_id == job.id, JobVisit.status == VisitStatus.PLANNED))
    )
    if planned or job.status is not JobStatus.IN_PROGRESS:
        return
    set_job_status(session, job, JobStatus.COMPLETED, SYSTEM, None)
    if (target := _COMPLETES_PROJECT.get(job.job_type)) is not None:
        project = await get_or_404(session, Project, job.project_id, "project")
        projects.advance_if_allowed(session, project, target)


# --- jobs ---------------------------------------------------------------------------


async def create_job(session: AsyncSession, data: JobIn, user: User) -> Job:
    project = await get_or_404(session, Project, data.project_id, "project")
    job = Job(**data.model_dump(), site_id=project.site_id, created_by=user.id)
    session.add(job)
    await session.flush()
    session.add(JobStatusHistory(job_id=job.id, new_status=JobStatus.DRAFT, changed_by=user.id))
    audit.record(
        session,
        "job.created",
        user_id=user.id,
        entity_type="job",
        entity_id=job.id,
        metadata={"type": job.job_type.value, "project_id": project.id},
    )
    await session.commit()
    return job


async def list_jobs(
    session: AsyncSession,
    *,
    status: JobStatus | None,
    project_id: int | None,
    limit: int,
    offset: int,
) -> list[Job]:
    stmt = select(Job).order_by(Job.id.desc()).limit(limit).offset(offset)
    if status is not None:
        stmt = stmt.where(Job.status == status)
    if project_id is not None:
        stmt = stmt.where(Job.project_id == project_id)
    return list(await session.scalars(stmt))


async def update_job(session: AsyncSession, job_id: int, patch: JobPatch, user: User) -> Job:
    job = await get_or_404(session, Job, job_id, "job")
    if patch.status is not None and patch.status is not job.status:
        if patch.status is JobStatus.CANCELLED:
            raise AppError("USE_CANCEL_ENDPOINT", "Cancel a job with POST /jobs/{id}/cancel.")
        set_job_status(session, job, patch.status, user.role, user.id)
        audit.record(
            session,
            "job.status_changed",
            user_id=user.id,
            entity_type="job",
            entity_id=job.id,
            metadata={"to": patch.status.value},
        )
    apply_patch(job, patch, exclude={"status"})
    await session.commit()
    return job


async def cancel_job(session: AsyncSession, job_id: int, reason: str, user: User) -> Job:
    """Cancels the job, its planned visits and their active assignments (§14)."""
    job = await get_or_404(session, Job, job_id, "job")
    set_job_status(session, job, JobStatus.CANCELLED, user.role, user.id, comment=reason)
    visits = list(
        await session.scalars(
            select(JobVisit).where(
                JobVisit.job_id == job.id, JobVisit.status == VisitStatus.PLANNED
            )
        )
    )
    for visit in visits:
        visit.status = VisitStatus.CANCELLED
    for assignment in await _active_assignments(session, [v.id for v in visits]):
        if assignment.status is not AssignmentStatus.SUBMITTED:
            _cancel_assignment(assignment, SYSTEM)
            await _tell(session, assignment, job, NotificationType.TASK_CANCELLED)
    audit.record(
        session,
        "job.cancelled",
        user_id=user.id,
        entity_type="job",
        entity_id=job.id,
        metadata={"reason": reason},
    )
    await session.commit()
    return job


# --- visits -------------------------------------------------------------------------


async def _open_job(session: AsyncSession, job_id: int) -> Job:
    job = await get_or_404(session, Job, job_id, "job")
    if job.status in _CLOSED_JOB:
        raise _conflict("JOB_CLOSED", "This job is completed or cancelled.", job_id=job.id)
    return job


async def _planned_visit(session: AsyncSession, visit_id: int) -> tuple[JobVisit, Job]:
    visit = await get_or_404(session, JobVisit, visit_id, "visit")
    if visit.status is not VisitStatus.PLANNED:
        raise _conflict("VISIT_NOT_PLANNED", "This visit is done or cancelled.", visit_id=visit.id)
    return visit, await _open_job(session, visit.job_id)


async def create_visit(session: AsyncSession, job_id: int, data: VisitIn, user: User) -> JobVisit:
    job = await _open_job(session, job_id)
    visit = JobVisit(job_id=job.id, period=_period(data.starts_at, data.ends_at))
    session.add(visit)
    await session.flush()
    audit.record(session, "visit.created", user_id=user.id, entity_type="visit", entity_id=visit.id)
    await session.commit()
    return visit


async def update_visit(session: AsyncSession, visit_id: int, data: VisitIn, user: User) -> JobVisit:
    """Moves the visit and every active assignment on it (re-checks double booking)."""
    visit, job = await _planned_visit(session, visit_id)
    period = _period(data.starts_at, data.ends_at)
    assignments = await _active_assignments(session, [visit.id])
    for assignment in assignments:
        await _check_not_booked(session, assignment.worker_id, period, visit.id)
    visit.period = period
    for assignment in assignments:
        assignment.period = period
        await _tell(session, assignment, job, NotificationType.TASK_CHANGED)
    audit.record(
        session,
        "visit.rescheduled",
        user_id=user.id,
        entity_type="visit",
        entity_id=visit.id,
        metadata={"starts_at": data.starts_at.isoformat(), "ends_at": data.ends_at.isoformat()},
    )
    await _flush_or_booked(session)
    await session.commit()
    return visit


async def cancel_visit(session: AsyncSession, visit_id: int, user: User) -> None:
    visit, job = await _planned_visit(session, visit_id)
    assignments = await _active_assignments(session, [visit.id])
    if any(a.status is AssignmentStatus.SUBMITTED for a in assignments):
        raise _conflict("VISIT_HAS_SUBMISSIONS", "Workers already submitted this visit.")
    VISIT_TRANSITIONS.check(visit.status, VisitStatus.CANCELLED, user.role)
    visit.status = VisitStatus.CANCELLED
    for assignment in assignments:
        _cancel_assignment(assignment, SYSTEM)
        await _tell(session, assignment, job, NotificationType.TASK_CANCELLED)
    audit.record(
        session, "visit.cancelled", user_id=user.id, entity_type="visit", entity_id=visit.id
    )
    await _sync_job_after_crew_change(session, job)
    await session.commit()


# --- crew ---------------------------------------------------------------------------


async def set_crew(session: AsyncSession, visit_id: int, crew: CrewIn, user: User) -> JobVisit:
    """Replaces the crew of a visit (`PUT /visits/{id}/crew`)."""
    visit, job = await _planned_visit(session, visit_id)
    wanted = {m.worker_id: m for m in crew.members}

    workers = {w.id: w for w in await session.scalars(select(Worker).where(Worker.id.in_(wanted)))}
    missing = sorted(set(wanted) - {w for w, x in workers.items() if x.is_active})
    if missing:
        raise AppError(
            "WORKER_NOT_FOUND",
            "Some workers don't exist or are inactive.",
            status_code=HTTPStatus.NOT_FOUND,
            details={"worker_ids": missing},
        )

    existing = {
        a.worker_id: a
        for a in await session.scalars(
            select(VisitAssignment).where(VisitAssignment.visit_id == visit.id)
        )
    }

    # 1. removals and demotions first, so the one-LEAD index never sees two leads
    for worker_id, assignment in existing.items():
        if assignment.status is AssignmentStatus.CANCELLED:
            continue
        member = wanted.get(worker_id)
        if member is None:
            if assignment.status is AssignmentStatus.SUBMITTED:
                raise _conflict(
                    "ASSIGNMENT_ALREADY_SUBMITTED",
                    "A worker who already submitted cannot be removed.",
                    worker_id=worker_id,
                )
            _cancel_assignment(assignment, user.role)
            await _tell(session, assignment, job, NotificationType.TASK_CANCELLED)
        elif assignment.role is AssignmentRole.LEAD and member.role is AssignmentRole.MEMBER:
            assignment.role = AssignmentRole.MEMBER  # promotions happen in step 2
    await session.flush()

    # 2. additions, re-additions, pay
    newly_assigned: list[VisitAssignment] = []
    for worker_id, member in wanted.items():
        await _check_not_booked(session, worker_id, visit.period, visit.id)
        current = existing.get(worker_id)
        if current is None:
            current = VisitAssignment(
                visit_id=visit.id,
                worker_id=worker_id,
                role=member.role,
                period=visit.period,
                pay_amount=member.pay_amount,
                assigned_by=user.id,
            )
            session.add(current)
            newly_assigned.append(current)
            continue
        if current.status is AssignmentStatus.CANCELLED:
            ASSIGNMENT_TRANSITIONS.check(current.status, AssignmentStatus.ASSIGNED, user.role)
            current.status = AssignmentStatus.ASSIGNED
            newly_assigned.append(current)
            current.period = visit.period
            current.assigned_by = user.id
        current.role = member.role
        if member.pay_amount != current.pay_amount:
            if current.reviewed_at is not None:
                raise _conflict(
                    "ASSIGNMENT_REVIEWED",
                    "Pay can't change after the timesheet was approved.",
                    worker_id=worker_id,
                )
            audit.record(
                session,
                "assignment.pay_changed",
                user_id=user.id,
                entity_type="assignment",
                entity_id=current.id,
                metadata={"before": str(current.pay_amount), "after": str(member.pay_amount)},
            )
            current.pay_amount = member.pay_amount

    await _flush_or_booked(session)
    for assignment in newly_assigned:
        await _tell(session, assignment, job, NotificationType.TASK_ASSIGNED)
    await _sync_job_after_crew_change(session, job)
    audit.record(
        session,
        "visit.crew_set",
        user_id=user.id,
        entity_type="visit",
        entity_id=visit.id,
        metadata={
            "members": [{"worker_id": m.worker_id, "role": m.role.value} for m in crew.members]
        },
    )
    await session.commit()
    return visit


# --- read models --------------------------------------------------------------------


async def _crew_by_visit(
    session: AsyncSession, visit_ids: Sequence[int]
) -> dict[int, list[CrewMemberOut]]:
    crew: dict[int, list[CrewMemberOut]] = {v: [] for v in visit_ids}
    if not visit_ids:
        return crew
    rows = await session.execute(
        select(VisitAssignment, Worker.employee_code, User.first_name, User.last_name)
        .join(Worker, Worker.id == VisitAssignment.worker_id)
        .join(User, User.id == Worker.user_id)
        .where(VisitAssignment.visit_id.in_(visit_ids), VisitAssignment.status != _CANCELLED)
        .order_by(VisitAssignment.role, User.last_name)
    )
    for a, code, first, last in rows:
        crew[a.visit_id].append(
            CrewMemberOut(
                assignment_id=a.id,
                worker_id=a.worker_id,
                worker_name=f"{first} {last}",
                employee_code=code,
                role=a.role,
                status=a.status,
                pay_amount=a.pay_amount,
                currency=a.currency,
            )
        )
    return crew


async def visit_out(session: AsyncSession, visit: JobVisit) -> VisitOut:
    crew = await _crew_by_visit(session, [visit.id])
    return _visit_out(visit, crew[visit.id])


def _visit_out(visit: JobVisit, crew: list[CrewMemberOut]) -> VisitOut:
    assert visit.period.lower is not None and visit.period.upper is not None  # noqa: S101
    return VisitOut(
        id=visit.id,
        job_id=visit.job_id,
        starts_at=visit.period.lower,
        ends_at=visit.period.upper,
        status=visit.status,
        crew=crew,
    )


def job_out(job: Job) -> JobOut:
    return JobOut.model_validate(job, from_attributes=True)


async def job_detail(session: AsyncSession, job_id: int) -> JobDetailOut:
    job = await get_or_404(session, Job, job_id, "job")
    visits = list(
        await session.scalars(
            select(JobVisit).where(JobVisit.job_id == job.id).order_by(JobVisit.period)
        )
    )
    crew = await _crew_by_visit(session, [v.id for v in visits])
    return JobDetailOut(
        **job_out(job).model_dump(), visits=[_visit_out(v, crew[v.id]) for v in visits]
    )


async def schedule(
    session: AsyncSession, start: datetime, end: datetime, worker_id: int | None
) -> list[ScheduleEntryOut]:
    stmt = (
        select(VisitAssignment, JobVisit, Job, User.first_name, User.last_name)
        .join(JobVisit, JobVisit.id == VisitAssignment.visit_id)
        .join(Job, Job.id == JobVisit.job_id)
        .join(Worker, Worker.id == VisitAssignment.worker_id)
        .join(User, User.id == Worker.user_id)
        .where(
            VisitAssignment.status != _CANCELLED,
            VisitAssignment.period.overlaps(_period(start, end)),
        )
        .order_by(VisitAssignment.period, User.last_name)
    )
    if worker_id is not None:
        stmt = stmt.where(VisitAssignment.worker_id == worker_id)
    entries = []
    for a, visit, job, first, last in await session.execute(stmt):
        assert visit.period.lower is not None and visit.period.upper is not None  # noqa: S101
        entries.append(
            ScheduleEntryOut(
                assignment_id=a.id,
                worker_id=a.worker_id,
                worker_name=f"{first} {last}",
                role=a.role,
                status=a.status,
                visit_id=visit.id,
                starts_at=visit.period.lower,
                ends_at=visit.period.upper,
                job_id=job.id,
                job_title=job.title,
                job_type=job.job_type,
                site_id=job.site_id,
            )
        )
    return entries
