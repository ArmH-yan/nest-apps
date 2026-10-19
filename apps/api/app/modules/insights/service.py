"""Manager "Info" views (ARCHITECTURE §13a): totals, averages and raw rows for one
worker or one customer company over a window of Yerevan dates.

Read-only. Everything is computed from the operational tables at request time
(fewer than 20 workers, a few hundred tasks a year); Metabase (§27) stays the place
for cross-cutting reports.
"""

import csv
import io
from collections import Counter, defaultdict
from collections.abc import Iterable
from datetime import date, datetime, time, timedelta
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.time import YEREVAN
from app.db.crud import not_found
from app.modules.companies.models import Company
from app.modules.insights.schemas import (
    CompanyInsightsOut,
    CompanyJobRowOut,
    CompanyMonthOut,
    JobTypeCountOut,
    MaterialTotalOut,
    WorkerInsightsOut,
    WorkerMonthOut,
)
from app.modules.materials.models import CatalogItem, Movement, SiteMaterialMovement
from app.modules.projects.models import Project
from app.modules.scheduling.models import (
    AssignmentStatus,
    Job,
    JobVisit,
    VisitAssignment,
    VisitStatus,
)
from app.modules.sites.models import Site
from app.modules.timesheets.schemas import TimesheetRowOut
from app.modules.timesheets.service import entry_totals, list_timesheets
from app.modules.users.models import User, Worker

ZERO = Decimal("0.00")


# --- window --------------------------------------------------------------------------


def default_window(today: date) -> tuple[date, date]:
    """The last 12 months including the current one."""
    first = date(today.year, today.month, 1)
    for _ in range(11):
        first = (first - timedelta(days=1)).replace(day=1)
    return first, today


def _instants(start: date, end: date) -> tuple[datetime, datetime]:
    """[start 00:00, end+1 00:00) in Yerevan."""
    return (
        datetime.combine(start, time(), YEREVAN),
        datetime.combine(end + timedelta(days=1), time(), YEREVAN),
    )


def _month_keys(start: date, end: date) -> list[str]:
    keys, d = [], date(start.year, start.month, 1)
    while d <= end:
        keys.append(f"{d.year:04d}-{d.month:02d}")
        d = (d.replace(day=28) + timedelta(days=4)).replace(day=1)
    return keys


def _month(instant: datetime) -> str:
    local = instant.astimezone(YEREVAN)
    return f"{local.year:04d}-{local.month:02d}"


def _ratio(part: int, whole: int) -> float:
    return round(part / whole, 3) if whole else 0.0


def _money(value: Decimal) -> Decimal:
    return value.quantize(Decimal("0.01"))


# --- worker --------------------------------------------------------------------------


async def worker_tasks(
    session: AsyncSession, worker_id: int, start: date, end: date
) -> list[TimesheetRowOut]:
    """Raw data: every task of the worker in the window, any status."""
    if await session.get(Worker, worker_id) is None:
        raise not_found("worker")
    lo, hi = _instants(start, end)
    return await list_timesheets(
        session,
        start=lo,
        end=hi,
        worker_id=worker_id,
        flagged=None,
        reviewed=None,
        statuses=tuple(AssignmentStatus),
    )


async def worker_insights(
    session: AsyncSession, worker_id: int, start: date, end: date
) -> WorkerInsightsOut:
    worker = await session.get(Worker, worker_id)
    if worker is None:
        raise not_found("worker")
    user = await session.get(User, worker.user_id)
    assert user is not None  # noqa: S101
    rows = await worker_tasks(session, worker_id, start, end)

    keys = _month_keys(start, end)
    months = {
        k: WorkerMonthOut(
            month=k,
            tasks_assigned=0,
            tasks_submitted=0,
            tasks_approved=0,
            approved_pay=ZERO,
            work_seconds=0,
            break_seconds=0,
            flagged_tasks=0,
        )
        for k in keys
    }
    cancelled = 0
    for r in rows:
        m = months.get(_month(r.scheduled_start))
        if m is None:
            continue
        if r.status is AssignmentStatus.CANCELLED:
            cancelled += 1
            continue
        m.tasks_assigned += 1
        if r.status is AssignmentStatus.SUBMITTED:
            m.tasks_submitted += 1
            m.work_seconds += r.work_seconds
            m.break_seconds += r.break_seconds
            m.flagged_tasks += bool(r.review_flags)
            if r.reviewed_at is not None:
                m.tasks_approved += 1
                m.approved_pay += r.pay_amount or ZERO

    ms = list(months.values())
    submitted = sum(m.tasks_submitted for m in ms)
    approved = sum(m.tasks_approved for m in ms)
    pay = sum((m.approved_pay for m in ms), ZERO)
    work = sum(m.work_seconds for m in ms)
    brk = sum(m.break_seconds for m in ms)
    flagged = sum(m.flagged_tasks for m in ms)
    live = [r for r in rows if r.status is not AssignmentStatus.CANCELLED]
    # monthly averages count only the months since the worker's first task in the
    # window, so a worker hired last month isn't averaged over a whole year
    first = min((_month(r.scheduled_start) for r in live), default=None)
    active = sum(1 for m in ms if first is not None and m.month >= first)
    return WorkerInsightsOut(
        worker_id=worker.id,
        worker_name=user.full_name,
        employee_code=worker.employee_code,
        period_start=start,
        period_end=end,
        months=ms,
        tasks_assigned=sum(m.tasks_assigned for m in ms),
        tasks_submitted=submitted,
        tasks_approved=approved,
        tasks_cancelled=cancelled,
        flagged_tasks=flagged,
        approved_pay=_money(pay),
        work_seconds=work,
        break_seconds=brk,
        mean_monthly_pay=_money(pay / active) if active else ZERO,
        mean_tasks_per_month=round(submitted / active, 2) if active else 0.0,
        mean_pay_per_task=_money(pay / approved) if approved else ZERO,
        mean_work_seconds_per_task=work // submitted if submitted else 0,
        mean_break_seconds_per_task=brk // submitted if submitted else 0,
        approval_rate=_ratio(approved, submitted),
        flag_rate=_ratio(flagged, submitted),
        first_task_at=min((r.scheduled_start for r in live), default=None),
        last_task_at=max((r.scheduled_start for r in live), default=None),
    )


# --- company -------------------------------------------------------------------------


async def _company(session: AsyncSession, company_id: int) -> Company:
    company = await session.get(Company, company_id)
    if company is None:
        raise not_found("company")
    return company


async def company_jobs(
    session: AsyncSession, company_id: int, start: date, end: date
) -> list[CompanyJobRowOut]:
    """Raw data: every job of the company's projects with a visit in the window."""
    await _company(session, company_id)
    lo, hi = _instants(start, end)
    lower = func.lower(JobVisit.period)
    visits = list(
        await session.execute(
            select(JobVisit, Job, Project, Site)
            .join(Job, Job.id == JobVisit.job_id)
            .join(Project, Project.id == Job.project_id)
            .join(Site, Site.id == Job.site_id)
            .where(Project.company_id == company_id, lower >= lo, lower < hi)
            .order_by(lower)
        )
    )
    tasks = await _submitted_tasks(session, [v.id for v, *_ in visits])

    rows: dict[int, CompanyJobRowOut] = {}
    for visit, job, project, site in visits:
        assert visit.period.lower is not None  # noqa: S101
        row = rows.setdefault(
            job.id,
            CompanyJobRowOut(
                job_id=job.id,
                job_title=job.title,
                job_type=job.job_type,
                job_status=job.status,
                project_reference=project.reference,
                project_name=project.name,
                site_name=site.name,
                visits_done=0,
                visits_planned=0,
                first_visit_at=None,
                last_visit_at=None,
                tasks_submitted=0,
                work_seconds=0,
                crew_pay=ZERO,
            ),
        )
        if visit.status is VisitStatus.CANCELLED:
            continue
        row.visits_done += visit.status is VisitStatus.DONE
        row.visits_planned += visit.status is VisitStatus.PLANNED
        at = visit.period.lower
        row.first_visit_at = min(row.first_visit_at or at, at)
        row.last_visit_at = max(row.last_visit_at or at, at)
        for pay, work in tasks.get(visit.id, []):
            row.tasks_submitted += 1
            row.work_seconds += work
            row.crew_pay += pay
    return list(rows.values())


async def _submitted_tasks(
    session: AsyncSession, visit_ids: list[int]
) -> dict[int, list[tuple[Decimal, int]]]:
    """visit id → [(pay, work seconds)] of its submitted tasks."""
    if not visit_ids:
        return {}
    assignments = list(
        await session.scalars(
            select(VisitAssignment).where(
                VisitAssignment.visit_id.in_(visit_ids),
                VisitAssignment.status == AssignmentStatus.SUBMITTED,
            )
        )
    )
    totals = await entry_totals(session, [a.id for a in assignments])
    out: dict[int, list[tuple[Decimal, int]]] = defaultdict(list)
    for a in assignments:
        out[a.visit_id].append((a.pay_amount or ZERO, totals.get(a.id, (0, 0))[0]))
    return out


async def company_insights(
    session: AsyncSession, company_id: int, start: date, end: date
) -> CompanyInsightsOut:
    company = await _company(session, company_id)
    lo, hi = _instants(start, end)
    projects = list(await session.scalars(select(Project).where(Project.company_id == company_id)))
    jobs = await company_jobs(session, company_id, start, end)

    # per month, from the visits themselves
    lower = func.lower(JobVisit.period)
    visits = list(
        await session.scalars(
            select(JobVisit)
            .join(Job, Job.id == JobVisit.job_id)
            .join(Project, Project.id == Job.project_id)
            .where(
                Project.company_id == company_id,
                lower >= lo,
                lower < hi,
                JobVisit.status != VisitStatus.CANCELLED,
            )
        )
    )
    tasks = await _submitted_tasks(session, [v.id for v in visits])
    months = {
        k: CompanyMonthOut(month=k, visits_done=0, tasks_submitted=0, work_seconds=0, crew_pay=ZERO)
        for k in _month_keys(start, end)
    }
    for v in visits:
        assert v.period.lower is not None  # noqa: S101
        m = months.get(_month(v.period.lower))
        if m is None:
            continue
        m.visits_done += v.status is VisitStatus.DONE
        for pay, work in tasks.get(v.id, []):
            m.tasks_submitted += 1
            m.work_seconds += work
            m.crew_pay += pay

    visits_done = sum(j.visits_done for j in jobs)
    worked = sum(1 for v in visits if tasks.get(v.id))  # visits with submitted work
    work = sum(j.work_seconds for j in jobs)
    return CompanyInsightsOut(
        company_id=company.id,
        company_name=company.name,
        period_start=start,
        period_end=end,
        months=list(months.values()),
        projects=len(projects),
        projects_by_status=dict(Counter(p.status.value for p in projects)),
        sites=len({p.site_id for p in projects}),
        jobs_by_type=[
            JobTypeCountOut(job_type=t, jobs=n)
            for t, n in Counter(j.job_type for j in jobs).most_common()
        ],
        visits_done=visits_done,
        tasks_submitted=sum(j.tasks_submitted for j in jobs),
        work_seconds=work,
        crew_pay=_money(sum((j.crew_pay for j in jobs), ZERO)),
        mean_work_seconds_per_visit=work // worked if worked else 0,
        first_visit_at=min((j.first_visit_at for j in jobs if j.first_visit_at), default=None),
        last_visit_at=max((j.last_visit_at for j in jobs if j.last_visit_at), default=None),
        materials=await _materials(session, company_id, lo, hi),
    )


async def _materials(
    session: AsyncSession, company_id: int, lo: datetime, hi: datetime
) -> list[MaterialTotalOut]:
    rows = await session.execute(
        select(CatalogItem, SiteMaterialMovement.movement, func.sum(SiteMaterialMovement.quantity))
        .join(CatalogItem, CatalogItem.id == SiteMaterialMovement.catalog_item_id)
        .join(Project, Project.id == SiteMaterialMovement.project_id)
        .where(
            Project.company_id == company_id,
            SiteMaterialMovement.recorded_at >= lo,
            SiteMaterialMovement.recorded_at < hi,
        )
        .group_by(CatalogItem.id, SiteMaterialMovement.movement)
        .order_by(CatalogItem.name_en)
    )
    out: dict[int, MaterialTotalOut] = {}
    for item, movement, qty in rows:
        t = out.setdefault(
            item.id,
            MaterialTotalOut(
                item_name=item.name_en,
                unit=item.unit.value,
                installed=Decimal(0),
                retrieved=Decimal(0),
                damaged_or_lost=Decimal(0),
            ),
        )
        if movement is Movement.INSTALLED:
            t.installed += qty
        elif movement is Movement.RETRIEVED:
            t.retrieved += qty
        elif movement in (Movement.DAMAGED, Movement.LOST):
            t.damaged_or_lost += qty
    return list(out.values())


# --- CSV -----------------------------------------------------------------------------


def to_csv(header: list[str], rows: Iterable[list[object]]) -> str:
    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(header)
    writer.writerows(rows)
    return "﻿" + out.getvalue()  # BOM: Excel opens Armenian/Russian names correctly


def _local(instant: datetime | None) -> str:
    return instant.astimezone(YEREVAN).isoformat(timespec="minutes") if instant else ""


def worker_tasks_csv(rows: list[TimesheetRowOut]) -> str:
    return to_csv(
        [
            "scheduled_start",
            "scheduled_end",
            "job",
            "job_type",
            "site",
            "role",
            "status",
            "work_hours",
            "break_hours",
            "pay_amount",
            "currency",
            "flags",
            "approved_at",
            "approved_by",
        ],
        (
            [
                _local(r.scheduled_start),
                _local(r.scheduled_end),
                r.job_title,
                r.job_type.value,
                r.site_name,
                r.role.value,
                r.status.value,
                f"{r.work_seconds / 3600:.2f}",
                f"{r.break_seconds / 3600:.2f}",
                r.pay_amount if r.pay_amount is not None else "",
                r.currency,
                " ".join(r.review_flags),
                _local(r.reviewed_at),
                r.reviewed_by_name or "",
            ]
            for r in rows
        ),
    )


def company_jobs_csv(rows: list[CompanyJobRowOut]) -> str:
    return to_csv(
        [
            "project",
            "project_name",
            "site",
            "job",
            "job_type",
            "job_status",
            "visits_done",
            "visits_planned",
            "first_visit",
            "last_visit",
            "tasks_submitted",
            "work_hours",
            "crew_pay",
            "currency",
        ],
        (
            [
                r.project_reference,
                r.project_name,
                r.site_name,
                r.job_title,
                r.job_type.value,
                r.job_status.value,
                r.visits_done,
                r.visits_planned,
                _local(r.first_visit_at),
                _local(r.last_visit_at),
                r.tasks_submitted,
                f"{r.work_seconds / 3600:.2f}",
                r.crew_pay,
                "AMD",
            ]
            for r in rows
        ),
    )
