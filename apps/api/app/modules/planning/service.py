"""Planning timeline (ARCHITECTURE §14a): projects over a window of Yerevan dates,
each with its planned and actual on-site period and the jobs' visits. Read-only;
visits are still created and moved on the job page (§13).
"""

from collections import defaultdict
from datetime import date, datetime, time, timedelta

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.time import YEREVAN
from app.modules.companies.models import Company
from app.modules.planning.schemas import PlanningJobOut, PlanningProjectOut, PlanningVisitOut
from app.modules.projects.models import Project, ProjectStatus
from app.modules.scheduling.models import (
    AssignmentRole,
    AssignmentStatus,
    Job,
    JobType,
    JobVisit,
    VisitAssignment,
    VisitStatus,
)
from app.modules.sites.models import Site
from app.modules.users.models import User, Worker

# projects worth planning: sold, on site, or just finished; quoted ones once dated
_ACTIVE = (ProjectStatus.WON, ProjectStatus.INSTALLED, ProjectStatus.DISMANTLED)
_FINISHED = (ProjectStatus.DISMANTLED, ProjectStatus.CLOSED)
SOON = timedelta(days=7)


def _bounds(start: date, end: date) -> tuple[datetime, datetime]:
    return (
        datetime.combine(start, time(), YEREVAN),
        datetime.combine(end + timedelta(days=1), time(), YEREVAN),
    )


async def _crews(session: AsyncSession, visit_ids: list[int]) -> dict[int, list[str]]:
    if not visit_ids:
        return {}
    rows = await session.execute(
        select(VisitAssignment.visit_id, VisitAssignment.role, User.first_name, User.last_name)
        .join(Worker, Worker.id == VisitAssignment.worker_id)
        .join(User, User.id == Worker.user_id)
        .where(
            VisitAssignment.visit_id.in_(visit_ids),
            VisitAssignment.status != AssignmentStatus.CANCELLED,
        )
        .order_by(VisitAssignment.role != AssignmentRole.LEAD, User.last_name)
    )
    crews: dict[int, list[str]] = defaultdict(list)
    for visit_id, _, first, last in rows:
        crews[visit_id].append(f"{first} {last}")
    return crews


async def _on_site(
    session: AsyncSession, project_ids: list[int]
) -> dict[int, tuple[datetime | None, datetime | None]]:
    """project → (first DONE installation start, last DONE dismantling end)."""
    if not project_ids:
        return {}
    rows = await session.execute(
        select(
            Job.project_id,
            Job.job_type,
            func.min(func.lower(JobVisit.period)),
            func.max(func.upper(JobVisit.period)),
        )
        .join(JobVisit, JobVisit.job_id == Job.id)
        .where(
            Job.project_id.in_(project_ids),
            Job.job_type.in_([JobType.INSTALLATION, JobType.DISMANTLING]),
            JobVisit.status == VisitStatus.DONE,
        )
        .group_by(Job.project_id, Job.job_type)
    )
    out: dict[int, tuple[datetime | None, datetime | None]] = {}
    for project_id, job_type, first, last in rows:
        start, end = out.get(project_id, (None, None))
        if job_type is JobType.INSTALLATION:
            start = first
        else:
            end = last
        out[project_id] = (start, end)
    return out


def _overlaps(a: date | None, b: date | None, start: date, end: date) -> bool:
    """Does the planned period [a, b] (b open when None) touch [start, end]?"""
    if a is None:
        return False
    return a <= end and (b is None or b >= start)


async def projects(
    session: AsyncSession, start: date, end: date, today: date
) -> list[PlanningProjectOut]:
    lo, hi = _bounds(start, end)
    candidates = list(
        await session.execute(
            select(Project, Site.name, Company.name)
            .join(Site, Site.id == Project.site_id)
            .outerjoin(Company, Company.id == Project.company_id)
            .where(
                or_(
                    Project.status.in_(_ACTIVE),
                    (Project.status == ProjectStatus.QUOTED)
                    & Project.expected_install_date.is_not(None),
                )
            )
        )
    )
    ids = [p.id for p, *_ in candidates]
    window = JobVisit.period.overlaps(func.tstzrange(lo, hi))
    visit_rows = list(
        await session.execute(
            select(JobVisit, Job)
            .join(Job, Job.id == JobVisit.job_id)
            .where(Job.project_id.in_(ids), JobVisit.status != VisitStatus.CANCELLED, window)
            .order_by(func.lower(JobVisit.period))
        )
    )
    crews = await _crews(session, [v.id for v, _ in visit_rows])
    on_site = await _on_site(session, ids)

    jobs: dict[int, dict[int, PlanningJobOut]] = defaultdict(dict)
    for visit, job in visit_rows:
        assert visit.period.lower is not None and visit.period.upper is not None  # noqa: S101
        row = jobs[job.project_id].setdefault(
            job.id,
            PlanningJobOut(
                id=job.id, title=job.title, job_type=job.job_type, status=job.status, visits=[]
            ),
        )
        row.visits.append(
            PlanningVisitOut(
                id=visit.id,
                starts_at=visit.period.lower,
                ends_at=visit.period.upper,
                status=visit.status,
                crew=crews.get(visit.id, []),
            )
        )

    out = []
    for project, site_name, company_name in candidates:
        first, last = on_site.get(project.id, (None, None))
        if project.status not in _FINISHED:
            last = None  # still on site
        on_site_dates = (
            first.astimezone(YEREVAN).date() if first else None,
            last.astimezone(YEREVAN).date() if last else None,
        )
        own_jobs = list(jobs.get(project.id, {}).values())
        relevant = (
            own_jobs
            or _overlaps(project.expected_install_date, project.expected_dismantle_date, start, end)
            or _overlaps(*on_site_dates, start, end)
        )
        if not relevant:
            continue
        installed = project.status is ProjectStatus.INSTALLED
        due = project.expected_dismantle_date
        out.append(
            PlanningProjectOut(
                id=project.id,
                reference=project.reference,
                name=project.name,
                status=project.status,
                company_name=company_name,
                site_name=site_name,
                expected_install_date=project.expected_install_date,
                expected_dismantle_date=due,
                on_site_from=first,
                on_site_to=last,
                dismantle_overdue=installed and due is not None and due < today,
                dismantle_soon=installed and due is not None and today <= due <= today + SOON,
                unstaffed_visits=sum(
                    1
                    for j in own_jobs
                    for v in j.visits
                    if v.status is VisitStatus.PLANNED and not v.crew
                ),
                jobs=own_jobs,
            )
        )

    def first_date(p: PlanningProjectOut) -> date:
        dates = [v.starts_at.astimezone(YEREVAN).date() for j in p.jobs for v in j.visits]
        if p.on_site_from:
            dates.append(p.on_site_from.astimezone(YEREVAN).date())
        if p.expected_install_date:
            dates.append(p.expected_install_date)
        return min(dates, default=end)

    return sorted(out, key=lambda p: (first_date(p), p.reference))
