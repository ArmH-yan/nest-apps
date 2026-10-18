from datetime import datetime
from decimal import Decimal
from typing import Annotated, Self

from pydantic import AwareDatetime, BaseModel, Field, model_validator

from app.modules.scheduling.models import (
    AssignmentRole,
    AssignmentStatus,
    JobStatus,
    JobType,
    VisitStatus,
)

Money = Annotated[Decimal, Field(ge=0, max_digits=12, decimal_places=2)]


class JobIn(BaseModel):
    project_id: int
    job_type: JobType
    title: str = Field(min_length=1, max_length=200)
    instructions: str | None = None
    priority: int = 0
    estimated_hours: Annotated[Decimal, Field(ge=0, max_digits=6, decimal_places=2)] | None = None


class JobPatch(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=200)
    instructions: str | None = None
    priority: int | None = None
    estimated_hours: Annotated[Decimal, Field(ge=0, max_digits=6, decimal_places=2)] | None = None
    # manager moves: NO_ACCESS, back to SCHEDULED, COMPLETED (§11 transition table)
    status: JobStatus | None = None


class CancelIn(BaseModel):
    reason: str = Field(min_length=1, max_length=500)


class VisitIn(BaseModel):
    """Times must include a timezone (stored in UTC; clients show Asia/Yerevan)."""

    starts_at: AwareDatetime
    ends_at: AwareDatetime

    @model_validator(mode="after")
    def _ordered(self) -> Self:
        if self.ends_at <= self.starts_at:
            raise ValueError("ends_at must be after starts_at.")
        if (self.ends_at - self.starts_at).total_seconds() > 24 * 3600:
            raise ValueError("A visit cannot be longer than 24 hours.")
        return self


class CrewMemberIn(BaseModel):
    worker_id: int
    role: AssignmentRole
    pay_amount: Money | None = None


class CrewIn(BaseModel):
    """The complete crew for the visit. Workers not listed are removed (cancelled)."""

    members: list[CrewMemberIn] = Field(max_length=30)

    @model_validator(mode="after")
    def _valid_crew(self) -> Self:
        ids = [m.worker_id for m in self.members]
        if len(ids) != len(set(ids)):
            raise ValueError("A worker is listed twice.")
        leads = sum(m.role is AssignmentRole.LEAD for m in self.members)
        if self.members and leads != 1:
            raise ValueError("A crew needs exactly one LEAD.")
        return self


class CrewMemberOut(BaseModel):
    assignment_id: int
    worker_id: int
    worker_name: str
    employee_code: str
    role: AssignmentRole
    status: AssignmentStatus
    pay_amount: Decimal | None
    currency: str


class VisitOut(BaseModel):
    id: int
    job_id: int
    starts_at: datetime
    ends_at: datetime
    status: VisitStatus
    crew: list[CrewMemberOut]


class JobOut(BaseModel):
    id: int
    project_id: int
    site_id: int
    job_type: JobType
    status: JobStatus
    priority: int
    title: str
    instructions: str | None
    estimated_hours: Decimal | None


class JobListItemOut(JobOut):
    project_name: str
    site_name: str
    # earliest PLANNED visit, for "what's next" in lists
    next_visit_at: datetime | None
    visit_count: int


class JobDetailOut(JobOut):
    project_name: str
    site_name: str
    site_address: str
    visits: list[VisitOut]


class ScheduleEntryOut(BaseModel):
    """One row of the calendar (§14): a worker on a visit."""

    assignment_id: int
    worker_id: int
    worker_name: str
    role: AssignmentRole
    status: AssignmentStatus
    visit_id: int
    starts_at: datetime
    ends_at: datetime
    job_id: int
    job_title: str
    job_type: JobType
    site_id: int
