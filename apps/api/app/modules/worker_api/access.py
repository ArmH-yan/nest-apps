"""Object-level authorization for worker writes (ARCHITECTURE §30): every lookup is
scoped `WHERE worker_id = :me`, and another worker's task is a 404, not a 403."""

from dataclasses import dataclass
from http import HTTPStatus

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.db.crud import not_found
from app.modules.projects.models import Project
from app.modules.scheduling.models import AssignmentStatus, Job, JobVisit, VisitAssignment
from app.modules.sites.models import Site


@dataclass(frozen=True)
class TaskContext:
    assignment: VisitAssignment
    visit: JobVisit
    job: Job
    site: Site
    project: Project


async def own_task(
    session: AsyncSession, worker_id: int, task_id: int, *, lock: bool = False
) -> TaskContext:
    stmt = (
        select(VisitAssignment, JobVisit, Job, Site, Project)
        .join(JobVisit, JobVisit.id == VisitAssignment.visit_id)
        .join(Job, Job.id == JobVisit.job_id)
        .join(Site, Site.id == Job.site_id)
        .join(Project, Project.id == Job.project_id)
        .where(VisitAssignment.id == task_id, VisitAssignment.worker_id == worker_id)
    )
    if lock:
        # serializes concurrent writes to one task (e.g. completion vs. a late time entry)
        stmt = stmt.with_for_update(of=VisitAssignment)
    row = (await session.execute(stmt)).first()
    if row is None:
        raise not_found("task")
    return TaskContext(*row)


def ensure_writable(ctx: TaskContext) -> None:
    status = ctx.assignment.status
    if status is AssignmentStatus.CANCELLED:
        raise AppError(
            "TASK_CANCELLED",
            "This task was cancelled by your manager.",
            status_code=HTTPStatus.CONFLICT,
        )
    if status is AssignmentStatus.SUBMITTED:
        raise AppError(
            "TASK_ALREADY_SUBMITTED",
            "This task was already submitted.",
            status_code=HTTPStatus.CONFLICT,
        )


def add_flags(assignment: VisitAssignment, *flags: str) -> None:
    """Review flags for the manager (§13). Data is never rejected for these (§18)."""
    merged = sorted(set(assignment.review_flags) | set(flags))
    if merged != assignment.review_flags:
        assignment.review_flags = merged  # new list: ARRAY changes need reassignment
