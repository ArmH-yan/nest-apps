"""Read models for the worker app (ARCHITECTURE §18). Every query is scoped to the
signed-in worker."""

from collections import defaultdict
from datetime import datetime
from decimal import Decimal

from sqlalchemy import Select, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.time import yerevan_month_bounds
from app.modules.companies.models import Company, Contact
from app.modules.files.models import File, FileOwner, FileStatus
from app.modules.materials import service as materials
from app.modules.notifications import service as notifications
from app.modules.notifications.models import Notification
from app.modules.projects.models import Project
from app.modules.scheduling.models import (
    AssignmentStatus,
    Job,
    JobVisit,
    VisitAssignment,
)
from app.modules.settings.service import get_operational
from app.modules.sites.models import Site
from app.modules.timetracking.models import AssignmentCompletion
from app.modules.users.models import User, Worker
from app.modules.worker_api.access import own_task
from app.modules.worker_api.schemas import (
    CatalogItemOut,
    CrewMateOut,
    EarningsOut,
    ExpectedMaterialOut,
    HistoryEntryOut,
    HistoryPageOut,
    NotificationOut,
    NotificationPageOut,
    TaskOut,
    WorkerConfigOut,
)

_CANCELLED = AssignmentStatus.CANCELLED

# Company/Contact come from outer joins and may be None at runtime.
TaskSelect = Select[VisitAssignment, JobVisit, Job, Site, Project, Company, Contact]


async def config(session: AsyncSession) -> WorkerConfigOut:
    ops = await get_operational(session)
    settings = get_settings()
    return WorkerConfigOut(
        default_geofence_radius_m=ops.default_geofence_radius_m,
        max_location_accuracy_m=ops.max_location_accuracy_m,
        min_completion_photos=ops.min_completion_photos,
        start_window_minutes_before=ops.start_window_minutes_before,
        min_supported_app_version=settings.min_supported_app_version,
        telegram_bot_username=settings.telegram_bot_username,
    )


# --- tasks -------------------------------------------------------------------------


def _task_query() -> TaskSelect:
    return (
        select(VisitAssignment, JobVisit, Job, Site, Project, Company, Contact)
        .join(JobVisit, JobVisit.id == VisitAssignment.visit_id)
        .join(Job, Job.id == JobVisit.job_id)
        .join(Site, Site.id == Job.site_id)
        .join(Project, Project.id == Job.project_id)
        .outerjoin(Company, Company.id == Project.company_id)
        .outerjoin(Contact, Contact.id == Project.primary_contact_id)
    )


async def _crews(session: AsyncSession, visit_ids: list[int]) -> dict[int, list[CrewMateOut]]:
    crews: dict[int, list[CrewMateOut]] = defaultdict(list)
    if not visit_ids:
        return crews
    rows = await session.execute(
        select(VisitAssignment.visit_id, VisitAssignment.worker_id, VisitAssignment.role, User)
        .join(Worker, Worker.id == VisitAssignment.worker_id)
        .join(User, User.id == Worker.user_id)
        .where(VisitAssignment.visit_id.in_(visit_ids), VisitAssignment.status != _CANCELLED)
        .order_by(VisitAssignment.role, User.last_name)
    )
    for visit_id, worker_id, role, user in rows:
        crews[visit_id].append(
            CrewMateOut(worker_id=worker_id, full_name=user.full_name, role=role, phone=user.phone)
        )
    return crews


async def _tasks(
    session: AsyncSession,
    stmt: TaskSelect,
) -> list[TaskOut]:
    rows = list(await session.execute(stmt))
    crews = await _crews(session, [row[1].id for row in rows])
    out = []
    for a, visit, job, site, project, company, contact in rows:
        assert visit.period.lower is not None and visit.period.upper is not None  # noqa: S101
        out.append(
            TaskOut(
                id=a.id,
                job_id=job.id,
                visit_id=visit.id,
                job_type=job.job_type,
                title=job.title,
                project_name=project.name,
                customer_name=company.name if company else (contact.full_name if contact else ""),
                instructions=job.instructions or "",
                site_name=site.name,
                address=site.address,
                latitude=float(site.latitude),
                longitude=float(site.longitude),
                geofence_radius_m=site.geofence_radius_m,
                access_notes=site.access_notes or "",
                site_contact_name=contact.full_name if contact else None,
                site_contact_phone=contact.phone if contact else None,
                scheduled_start=visit.period.lower,
                scheduled_end=visit.period.upper,
                role=a.role,
                status=a.status,
                crew=crews[visit.id],
            )
        )
    return out


async def tasks(
    session: AsyncSession, worker_id: int, start: datetime, end: datetime
) -> list[TaskOut]:
    """Tasks whose scheduled start is in [start, end]. Cancelled ones are included so
    the app can show "cancelled by your manager"."""
    lower = func.lower(VisitAssignment.period)
    stmt = (
        _task_query()
        .where(VisitAssignment.worker_id == worker_id, lower >= start, lower <= end)
        .order_by(lower)
    )
    return await _tasks(session, stmt)


async def task(session: AsyncSession, worker_id: int, task_id: int) -> TaskOut:
    await own_task(session, worker_id, task_id)  # 404 unless it's mine
    found = await _tasks(session, _task_query().where(VisitAssignment.id == task_id))
    return found[0]


async def expected_materials(
    session: AsyncSession, worker_id: int, task_id: int, locale: str
) -> list[ExpectedMaterialOut]:
    ctx = await own_task(session, worker_id, task_id)
    return [
        ExpectedMaterialOut(
            item=CatalogItemOut(id=item.id, name=item.name(locale), unit=item.unit.value),
            quantity=qty,
        )
        for item, qty in await materials.on_site(session, ctx.site.id)
    ]


async def catalog(session: AsyncSession, locale: str) -> list[CatalogItemOut]:
    return [
        CatalogItemOut(id=i.id, name=i.name(locale), unit=i.unit.value)
        for i in await materials.trackable_catalog(session)
    ]


# --- history, earnings -------------------------------------------------------------


async def history(
    session: AsyncSession, worker_id: int, cursor: int | None, limit: int
) -> HistoryPageOut:
    """Submitted tasks, newest first. `cursor` = the last task id of the previous page."""
    stmt = (
        _task_query()
        .where(
            VisitAssignment.worker_id == worker_id,
            VisitAssignment.status == AssignmentStatus.SUBMITTED,
        )
        .order_by(VisitAssignment.id.desc())
        .limit(limit + 1)
    )
    if cursor is not None:
        stmt = stmt.where(VisitAssignment.id < cursor)
    page = await _tasks(session, stmt)
    more = len(page) > limit
    page = page[:limit]
    ids = [t.id for t in page]
    completions = {
        c.assignment_id: c
        for c in await session.scalars(
            select(AssignmentCompletion).where(AssignmentCompletion.assignment_id.in_(ids))
        )
    }
    photo_rows = await session.execute(
        select(File.owner_id, func.count())
        .where(
            File.owner_type == FileOwner.ASSIGNMENT,
            File.owner_id.in_(ids),
            File.status == FileStatus.UPLOADED,
        )
        .group_by(File.owner_id)
    )
    photo_counts: dict[int, int] = {owner: n for owner, n in photo_rows}
    items = []
    for t in page:
        c = completions.get(t.id)
        if c is None:
            continue
        items.append(
            HistoryEntryOut(
                task=t,
                completed_at=c.completed_at,
                work_seconds=c.work_seconds,
                break_seconds=c.break_seconds,
                photo_count=photo_counts.get(t.id, 0),
                comment=c.comment,
            )
        )
    return HistoryPageOut(items=items, next_cursor=page[-1].id if more and page else None)


async def earnings(session: AsyncSession, worker_id: int, year: int, month: int) -> EarningsOut:
    """Approved tasks (timesheet reviewed) whose visit starts in the Yerevan month,
    and the sum of their fixed pay (§8 "Worker pay")."""
    start, end = yerevan_month_bounds(year, month)
    lower = func.lower(VisitAssignment.period)
    count, total = (
        await session.execute(
            select(func.count(), func.coalesce(func.sum(VisitAssignment.pay_amount), 0)).where(
                VisitAssignment.worker_id == worker_id,
                VisitAssignment.status == AssignmentStatus.SUBMITTED,
                VisitAssignment.reviewed_at.is_not(None),
                lower >= start,
                lower < end,
            )
        )
    ).one()
    return EarningsOut(
        month=f"{year:04d}-{month:02d}",
        approved_tasks=count,
        approved_amount=Decimal(total or 0).quantize(Decimal("0.01")),
        currency="AMD",
    )


# --- notifications -----------------------------------------------------------------


def _notification_out(n: Notification) -> NotificationOut:
    task_id = n.data.get("assignment_id")
    return NotificationOut(
        id=n.id,
        type=n.type,
        title=n.title,
        body=n.body,
        task_id=task_id if isinstance(task_id, int) else None,
        created_at=n.created_at,
        read_at=n.read_at,
    )


async def notification_page(
    session: AsyncSession, user_id: int, cursor: int | None, limit: int
) -> NotificationPageOut:
    rows = await notifications.list_for_user(session, user_id, cursor, limit + 1)
    more = len(rows) > limit
    rows = rows[:limit]
    return NotificationPageOut(
        items=[_notification_out(n) for n in rows],
        next_cursor=rows[-1].id if more and rows else None,
    )
