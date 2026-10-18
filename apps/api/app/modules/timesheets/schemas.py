import uuid
from datetime import datetime
from decimal import Decimal
from typing import Self

from pydantic import AwareDatetime, BaseModel, Field, model_validator

from app.modules.materials.models import Movement
from app.modules.scheduling.models import AssignmentRole, AssignmentStatus, JobType
from app.modules.timetracking.models import CheckPurpose, EntryKind


class TimesheetRowOut(BaseModel):
    """One worker on one visit (ARCHITECTURE §13 "Timesheets")."""

    assignment_id: int
    worker_id: int
    worker_name: str
    employee_code: str
    job_id: int
    job_title: str
    job_type: JobType
    site_name: str
    scheduled_start: datetime
    scheduled_end: datetime
    role: AssignmentRole
    status: AssignmentStatus
    # recomputed from time_entries (open entries count until now)
    work_seconds: int
    break_seconds: int
    review_flags: list[str]
    pay_amount: Decimal | None
    currency: str
    reviewed_at: datetime | None
    reviewed_by_name: str | None


class TimeEntryRowOut(BaseModel):
    id: uuid.UUID
    kind: EntryKind
    started_at: datetime
    ended_at: datetime | None
    client_clock_offset_s: int | None
    received_at: datetime


class LocationCheckRowOut(BaseModel):
    id: uuid.UUID
    purpose: CheckPurpose
    latitude: float
    longitude: float
    accuracy_m: float
    is_mocked: bool
    captured_at: datetime
    client_distance_m: float
    server_distance_m: float
    radius_m: float
    server_verified: bool
    override_reason: str | None


class PhotoOut(BaseModel):
    id: uuid.UUID
    url: str
    taken_at: datetime | None
    kind: str


class MaterialRowOut(BaseModel):
    item_name: str
    unit: str
    quantity: Decimal
    movement: Movement
    note: str | None


class TimesheetDetailOut(TimesheetRowOut):
    site_latitude: float
    site_longitude: float
    site_radius_m: float
    completed_at: datetime | None
    reported_work_seconds: int | None
    reported_break_seconds: int | None
    comment: str | None
    entries: list[TimeEntryRowOut]
    checks: list[LocationCheckRowOut]
    photos: list[PhotoOut]
    materials: list[MaterialRowOut]


class AdjustIn(BaseModel):
    """Corrects one time entry (e.g. "forgot to stop the break"). Audited (§31)."""

    time_entry_id: uuid.UUID
    started_at: AwareDatetime
    ended_at: AwareDatetime
    reason: str = Field(min_length=3, max_length=500)

    @model_validator(mode="after")
    def _ordered(self) -> Self:
        if self.ended_at <= self.started_at:
            raise ValueError("ended_at must be after started_at.")
        return self


class OverrideIn(BaseModel):
    reason: str = Field(min_length=3, max_length=500)
