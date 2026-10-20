"""Demo data for development and the first field test (ARCHITECTURE §34, §41 Phase 2).

    python -m app.cli seed-demo            # refuses if users already exist
    python -m app.cli seed-demo --reset    # wipes ALL data first (development only)

Mirrors the worker app's mock world (WORKER_APP_SPEC "Mock data"), with dates
relative to today in Yerevan. Everyone's password is `nest1234`. Refused when
APP_ENV=production.
"""

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime, time, timedelta
from decimal import Decimal

from sqlalchemy import select, text
from sqlalchemy.dialects.postgresql import Range
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.time import YEREVAN
from app.db.models import Base
from app.modules.companies.models import Company, Contact
from app.modules.files.models import File, FileKind, FileOwner, FileStatus
from app.modules.materials.models import CatalogItem, Movement, SiteMaterialMovement
from app.modules.projects.models import Project, ProjectStatus
from app.modules.scheduling import service as scheduling
from app.modules.scheduling.models import (
    AssignmentRole,
    AssignmentStatus,
    Job,
    JobStatus,
    JobType,
    JobVisit,
    VisitAssignment,
    VisitStatus,
)
from app.modules.scheduling.schemas import CrewIn, CrewMemberIn, JobIn, VisitIn
from app.modules.sites.models import Site
from app.modules.timetracking.models import (
    AssignmentCompletion,
    CheckPurpose,
    EntryKind,
    LocationCheck,
    TimeEntry,
)
from app.modules.users.models import User, UserLocale, UserRole, Worker
from app.modules.users.service import create_user, get_worker_for_user
from app.modules.workers.models import TimeOffReason, WorkerTimeOff

PASSWORD = "nest1234"  # noqa: S105 — demo accounts only; seeding is refused in production
_KEEP_ON_RESET = {"services", "catalog_items", "alembic_version"}


class SeedRefused(Exception):
    pass


def _yerevan(days: int, hour: int, minute: int = 0) -> datetime:
    today = datetime.now(YEREVAN).date()
    day = today + timedelta(days=days)
    return datetime(day.year, day.month, day.day, hour, minute, tzinfo=YEREVAN).astimezone(UTC)


@dataclass
class _People:
    manager: User
    arman: Worker
    david: Worker
    karen: Worker
    vardan: Worker
    ravi: Worker
    budi: Worker


async def _reset(session: AsyncSession) -> None:
    tables = [t.name for t in Base.metadata.sorted_tables if t.name not in _KEEP_ON_RESET]
    await session.execute(text(f"TRUNCATE {', '.join(tables)} RESTART IDENTITY CASCADE"))
    await session.commit()


async def _people(session: AsyncSession) -> _People:
    manager = await create_user(
        session,
        phone="+37491000001",
        password=PASSWORD,
        first_name="Mane",
        last_name="Manager",
        role=UserRole.MANAGER,
        email="manager@nest.local",
        must_change_password=False,
    )

    async def worker(
        phone: str, first: str, last: str, code: str, locale: UserLocale = UserLocale.HY
    ) -> Worker:
        user = await create_user(
            session,
            phone=phone,
            password=PASSWORD,
            first_name=first,
            last_name=last,
            role=UserRole.WORKER,
            locale=locale,
            must_change_password=False,
            employee_code=code,
        )
        found = await get_worker_for_user(session, user.id)
        assert found is not None  # noqa: S101
        return found

    return _People(
        manager=manager,
        arman=await worker("+37491000007", "Arman", "Harutyunyan", "NEST-007"),
        david=await worker("+37491000011", "David", "Sargsyan", "NEST-011", UserLocale.RU),
        karen=await worker("+37491000014", "Karen", "Petrosyan", "NEST-014"),
        vardan=await worker("+37491000003", "Vardan", "Grigoryan", "NEST-003"),
        ravi=await worker("+37491000021", "Ravi", "Kumar", "NEST-021", UserLocale.HI),
        budi=await worker("+37491000022", "Budi", "Santoso", "NEST-022", UserLocale.ID),
    )


async def _site(
    session: AsyncSession,
    company: Company,
    name: str,
    address: str,
    lat: str,
    lon: str,
    notes: str | None = None,
) -> Site:
    site = Site(
        company_id=company.id,
        name=name,
        address=address,
        latitude=Decimal(lat),
        longitude=Decimal(lon),
        location_confirmed=True,
        geofence_radius_m=150,
        access_notes=notes,
    )
    session.add(site)
    await session.flush()
    return site


async def _project(
    session: AsyncSession,
    ref: int,
    name: str,
    site: Site,
    company: Company,
    status: ProjectStatus,
    contact: Contact | None = None,
) -> Project:
    year = datetime.now(YEREVAN).year
    project = Project(
        reference=f"P-{year}-{ref:04d}",
        name=name,
        site_id=site.id,
        company_id=company.id,
        primary_contact_id=contact.id if contact else None,
        service_slug="safety-system",
        status=status,
    )
    session.add(project)
    await session.flush()
    return project


async def _scheduled(
    session: AsyncSession,
    people: _People,
    project: Project,
    job_type: JobType,
    title: str,
    instructions: str,
    start: datetime,
    end: datetime,
    crew: list[tuple[Worker, AssignmentRole, str]],
) -> Job:
    """Through the real services, so statuses and notifications are right."""
    job = await scheduling.create_job(
        session,
        JobIn(project_id=project.id, job_type=job_type, title=title, instructions=instructions),
        people.manager,
    )
    visit = await scheduling.create_visit(
        session, job.id, VisitIn(starts_at=start, ends_at=end), people.manager
    )
    await scheduling.set_crew(
        session,
        visit.id,
        CrewIn(
            members=[
                CrewMemberIn(worker_id=w.id, role=role, pay_amount=Decimal(pay))
                for w, role, pay in crew
            ]
        ),
        people.manager,
    )
    return job


async def _done_job(
    session: AsyncSession,
    people: _People,
    project: Project,
    job_type: JobType,
    title: str,
    days_ago: list[int],
) -> None:
    """A finished job with DONE visits and no crew rows, so the planning timeline
    (§14a) has history: installations long ago, past inspections."""
    job = Job(
        project_id=project.id,
        site_id=project.site_id,
        job_type=job_type,
        status=JobStatus.COMPLETED,
        title=title,
        created_by=people.manager.id,
    )
    session.add(job)
    await session.flush()
    for d in days_ago:
        period = Range(_yerevan(-d, 9), _yerevan(-d, 17), bounds="[)")
        session.add(JobVisit(job_id=job.id, period=period, status=VisitStatus.DONE))
    await session.flush()


async def _approved_past_task(
    session: AsyncSession,
    people: _People,
    project: Project,
    site: Site,
    title: str,
    days_ago: int,
    pay: str,
) -> None:
    """A finished, manager-approved task for history and earnings (written directly:
    the worker-side flow is covered by the API tests)."""
    start, end = _yerevan(-days_ago, 9), _yerevan(-days_ago, 17)
    job = Job(
        project_id=project.id,
        site_id=site.id,
        job_type=JobType.INSTALLATION,
        status=JobStatus.COMPLETED,
        title=title,
        created_by=people.manager.id,
    )
    session.add(job)
    await session.flush()
    visit = JobVisit(job_id=job.id, period=Range(start, end, bounds="[)"), status=VisitStatus.DONE)
    session.add(visit)
    await session.flush()
    assignment = VisitAssignment(
        visit_id=visit.id,
        worker_id=people.arman.id,
        role=AssignmentRole.MEMBER,
        period=visit.period,
        status=AssignmentStatus.SUBMITTED,
        pay_amount=Decimal(pay),
        reviewed_by=people.manager.id,
        reviewed_at=end + timedelta(hours=2),
        assigned_by=people.manager.id,
    )
    session.add(assignment)
    await session.flush()
    check = LocationCheck(
        id=uuid.uuid4(),
        assignment_id=assignment.id,
        worker_id=people.arman.id,
        purpose=CheckPurpose.START,
        latitude=float(site.latitude),
        longitude=float(site.longitude),
        accuracy_m=6.0,
        is_mocked=False,
        captured_at=start,
        client_distance_m=12.0,
        client_verified=True,
        server_distance_m=12.0,
        radius_m=150.0,
        server_verified=True,
    )
    session.add(check)
    await session.flush()
    lunch_from, lunch_to = (
        start + timedelta(hours=3, minutes=25),
        start + timedelta(hours=3, minutes=55),
    )
    finish = start + timedelta(hours=7, minutes=42)
    for kind, a, b in [
        (EntryKind.WORK, start, lunch_from),
        (EntryKind.BREAK, lunch_from, lunch_to),
        (EntryKind.WORK, lunch_to, finish),
    ]:
        session.add(
            TimeEntry(
                id=uuid.uuid4(),
                assignment_id=assignment.id,
                worker_id=people.arman.id,
                kind=kind,
                started_at=a,
                ended_at=b,
                start_location_check_id=check.id if a == start else None,
            )
        )
    work = int((lunch_from - start + finish - lunch_to).total_seconds())
    session.add(
        AssignmentCompletion(
            id=uuid.uuid4(),
            assignment_id=assignment.id,
            completed_at=finish,
            reported_work_seconds=work,
            reported_break_seconds=1800,
            work_seconds=work,
            break_seconds=1800,
            comment="Net installed on floors 2-5.",
        )
    )
    session.add(
        File(
            id=uuid.uuid4(),
            owner_type=FileOwner.ASSIGNMENT,
            owner_id=assignment.id,
            kind=FileKind.PHOTO,
            storage_key=f"seed/{assignment.id}.jpg",
            mime_type="image/jpeg",
            size_bytes=1,
            status=FileStatus.UPLOADED,
            uploaded_by=None,
        )
    )
    await session.flush()


async def seed_demo(session: AsyncSession, *, reset: bool) -> list[str]:
    if get_settings().is_production:
        raise SeedRefused("seed-demo never runs in production.")
    if reset:
        await _reset(session)
    elif await session.scalar(select(User.id).limit(1)) is not None:
        raise SeedRefused("The database already has users. Use --reset to wipe it first.")

    people = await _people(session)
    arm_build = Company(name="Arm Build LLC", phone="+37410500100")
    renshin = Company(name="Renshin CJSC")
    elite = Company(name="Elite Group")
    arabkir = Company(name="Arabkir Development")
    session.add_all([arm_build, renshin, elite, arabkir])
    await session.flush()
    hayk = Contact(
        company_id=arm_build.id,
        full_name="Hayk Avetisyan",
        position="Foreman",
        phone="+37493000101",
    )
    session.add(hayk)
    await session.flush()

    site_a = await _site(
        session,
        arm_build,
        "Building A",
        "Davtashen 3rd district, Yerevan",
        "40.226200",
        "44.493000",
        "Gate 2 on the north side. Ask for foreman Hayk.",
    )
    site_b = await _site(
        session, elite, "Building B", "Komitas Ave 22, Yerevan", "40.204500", "44.516000"
    )
    site_c = await _site(
        session, arabkir, "Building C", "Komitas Ave 49, Arabkir, Yerevan", "40.208000", "44.505000"
    )
    site_d = await _site(
        session,
        arm_build,
        "Building D",
        "Margaryan St 25, Ajapnyak, Yerevan",
        "40.196000",
        "44.458000",
    )
    site_e = await _site(
        session,
        renshin,
        "Building E",
        "Gai Ave 15, Nor Nork, Yerevan",
        "40.199000",
        "44.563000",
        "Crane on site until 15:00 - wait for the signal.",
    )

    davtashen = await _project(
        session, 1, "Davtashen Residential", site_a, arm_build, ProjectStatus.WON, hayk
    )
    komitas = await _project(session, 2, "Komitas 22 Residence", site_b, elite, ProjectStatus.WON)
    arabkir_bc = await _project(
        session, 3, "Arabkir Business Center", site_c, arabkir, ProjectStatus.INSTALLED
    )
    ajapnyak = await _project(
        session, 4, "Ajapnyak Heights", site_d, arm_build, ProjectStatus.INSTALLED
    )
    nor_nork = await _project(
        session, 5, "Nor Nork Tower", site_e, renshin, ProjectStatus.INSTALLED
    )

    # Planned periods for the planning timeline (§14a): Building D's dismantling is
    # overdue, Building C's is due within a week, Building E comes down today.
    today = datetime.now(YEREVAN).date()
    for project, install, dismantle in [
        (davtashen, 0, 120),
        (komitas, 1, 75),
        (arabkir_bc, -3, 5),
        (ajapnyak, -50, -4),
        (nor_nork, -60, 0),
    ]:
        project.expected_install_date = today + timedelta(days=install)
        project.expected_dismantle_date = today + timedelta(days=dismantle)
    await _done_job(
        session, people, ajapnyak, JobType.INSTALLATION, "Install Safety Net - Building D", [50, 49]
    )
    await _done_job(
        session, people, ajapnyak, JobType.INSPECTION, "Safety Net Inspection - Building D", [20]
    )
    await _done_job(
        session, people, nor_nork, JobType.INSTALLATION, "Install Safety Net - Building E", [60]
    )

    # Nets already on Building E: the dismantling crew's expected list.
    catalog = {c.sku: c for c in await session.scalars(select(CatalogItem))}
    for sku, qty in [("NET-M2", "300"), ("ANCHOR-M12", "40")]:
        session.add(
            SiteMaterialMovement(
                id=uuid.uuid4(),
                site_id=site_e.id,
                project_id=nor_nork.id,
                catalog_item_id=catalog[sku].id,
                quantity=Decimal(qty),
                movement=Movement.INSTALLED,
                recorded_by=people.manager.id,
                recorded_at=_yerevan(-60, 12),
            )
        )
    await session.commit()

    lead, member = AssignmentRole.LEAD, AssignmentRole.MEMBER
    await _scheduled(
        session,
        people,
        davtashen,
        JobType.INSTALLATION,
        "Install Safety Net - Building A",
        "Install the catch-fan safety net on floors 6-9, east facade. Check anchors first.",
        _yerevan(0, 9),
        _yerevan(0, 13, 30),
        [
            (people.arman, lead, "25000"),
            (people.david, member, "20000"),
            (people.ravi, member, "20000"),
        ],
    )
    await _scheduled(
        session,
        people,
        nor_nork,
        JobType.DISMANTLING,
        "Dismantle Safety Net - Building E",
        "Remove the safety net from the west facade. Bring back all anchors.",
        _yerevan(0, 14),
        _yerevan(0, 18),
        [
            (people.arman, lead, "20000"),
            (people.karen, member, "15000"),
            (people.budi, member, "15000"),
        ],
    )
    await _scheduled(
        session,
        people,
        komitas,
        JobType.INSTALLATION,
        "Dust Protection Installation - Building B",
        "Install dust net on scaffolding, south and east sides.",
        _yerevan(1, 10),
        _yerevan(1, 16),
        [
            (people.vardan, lead, "25000"),
            (people.arman, member, "20000"),
            (people.ravi, member, "20000"),
        ],
    )
    await _scheduled(
        session,
        people,
        ajapnyak,
        JobType.INSPECTION,
        "Safety Net Inspection - Building D",
        "Monthly inspection of the safety net and anchors.",
        _yerevan(3, 10),
        _yerevan(3, 11),
        [(people.vardan, lead, "10000"), (people.arman, member, "8000")],
    )
    for days_ago, pay in [(1, "25000"), (3, "30000")]:
        await _approved_past_task(
            session,
            people,
            arabkir_bc,
            site_c,
            "Install Protective Net - Building C",
            days_ago,
            pay,
        )
    # Karen's vacation next week: shows on the planning timeline and in the crew editor
    karen_off = today + timedelta(days=2)
    session.add(
        WorkerTimeOff(
            worker_id=people.karen.id,
            period=Range(
                datetime.combine(karen_off, time(), YEREVAN),
                datetime.combine(karen_off + timedelta(days=5), time(), YEREVAN),
                bounds="[)",
            ),
            reason=TimeOffReason.VACATION,
            note="Family trip",
            created_by=people.manager.id,
        )
    )
    await session.commit()

    return [
        f"manager  +37491000001 / {PASSWORD}",
        f"workers  +37491000007 Arman (hy, lead today) / {PASSWORD}",
        "         +37491000011 David (ru), +37491000014 Karen (hy), +37491000003 Vardan (hy),",
        "         +37491000021 Ravi (hi), +37491000022 Budi (id)",
        "today    Building A 09:00-13:30 (installation), Building E 14:00-18:00 (dismantling)",
    ]
