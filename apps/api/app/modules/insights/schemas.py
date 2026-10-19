from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel

from app.modules.scheduling.models import JobStatus, JobType


class WorkerMonthOut(BaseModel):
    """One Yerevan month of a worker's tasks (by the visit's start)."""

    month: str  # "2026-10"
    tasks_assigned: int  # every non-cancelled task
    tasks_submitted: int
    tasks_approved: int
    approved_pay: Decimal
    work_seconds: int
    break_seconds: int
    flagged_tasks: int


class WorkerInsightsOut(BaseModel):
    """Totals and averages for the manager's "Info" view of a worker (§13a)."""

    worker_id: int
    worker_name: str
    employee_code: str
    period_start: date
    period_end: date  # inclusive
    months: list[WorkerMonthOut]
    tasks_assigned: int
    tasks_submitted: int
    tasks_approved: int
    tasks_cancelled: int
    flagged_tasks: int
    approved_pay: Decimal
    work_seconds: int
    break_seconds: int
    # averages: per month over the months since the first task in the window,
    # per task over submitted tasks
    mean_monthly_pay: Decimal
    mean_tasks_per_month: float
    mean_pay_per_task: Decimal
    mean_work_seconds_per_task: int
    mean_break_seconds_per_task: int
    approval_rate: float  # approved / submitted
    flag_rate: float  # flagged / submitted
    first_task_at: datetime | None
    last_task_at: datetime | None
    currency: str = "AMD"


class CompanyMonthOut(BaseModel):
    month: str
    visits_done: int
    tasks_submitted: int
    work_seconds: int
    crew_pay: Decimal


class JobTypeCountOut(BaseModel):
    job_type: JobType
    jobs: int


class MaterialTotalOut(BaseModel):
    item_name: str
    unit: str
    installed: Decimal
    retrieved: Decimal
    damaged_or_lost: Decimal


class CompanyInsightsOut(BaseModel):
    """What NEST did for one customer company in the window (§13a)."""

    company_id: int
    company_name: str
    period_start: date
    period_end: date  # inclusive
    months: list[CompanyMonthOut]
    projects: int
    projects_by_status: dict[str, int]
    sites: int
    jobs_by_type: list[JobTypeCountOut]
    visits_done: int
    tasks_submitted: int
    work_seconds: int
    crew_pay: Decimal  # pay of submitted tasks (approved or not): NEST's labour cost
    mean_work_seconds_per_visit: int  # over visits with submitted work
    first_visit_at: datetime | None
    last_visit_at: datetime | None
    materials: list[MaterialTotalOut]
    currency: str = "AMD"


class CompanyJobRowOut(BaseModel):
    """Raw data: one job of the company's projects."""

    job_id: int
    job_title: str
    job_type: JobType
    job_status: JobStatus
    project_reference: str
    project_name: str
    site_name: str
    visits_done: int
    visits_planned: int
    first_visit_at: datetime | None
    last_visit_at: datetime | None
    tasks_submitted: int
    work_seconds: int
    crew_pay: Decimal
