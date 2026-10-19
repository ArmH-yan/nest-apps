from datetime import date, datetime

from pydantic import BaseModel

from app.modules.projects.models import ProjectStatus
from app.modules.scheduling.models import JobStatus, JobType, VisitStatus


class PlanningVisitOut(BaseModel):
    id: int
    starts_at: datetime
    ends_at: datetime
    status: VisitStatus
    crew: list[str]  # names, the lead first; empty = unstaffed


class PlanningJobOut(BaseModel):
    id: int
    title: str
    job_type: JobType
    status: JobStatus
    visits: list[PlanningVisitOut]  # non-cancelled visits that overlap the window


class PlanningProjectOut(BaseModel):
    """One row of the planning timeline (ARCHITECTURE §14a)."""

    id: int
    reference: str
    name: str
    status: ProjectStatus
    company_name: str | None
    site_name: str
    expected_install_date: date | None
    expected_dismantle_date: date | None
    # actual "net on site" period, from DONE installation / dismantling visits (any date)
    on_site_from: datetime | None
    on_site_to: datetime | None  # None while still installed
    dismantle_overdue: bool  # INSTALLED and expected_dismantle_date < today
    dismantle_soon: bool  # INSTALLED and expected_dismantle_date within 7 days
    unstaffed_visits: int  # planned visits in the window without a crew
    jobs: list[PlanningJobOut]
