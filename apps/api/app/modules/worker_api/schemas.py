"""DTOs of `/api/v1/worker/*` (ARCHITECTURE §18). The worker app maps these to its
domain models (WORKER_APP_SPEC "Backend API"); snake_case JSON, UTC timestamps."""

import uuid
from datetime import datetime
from decimal import Decimal
from typing import Annotated, Literal, Self

from pydantic import AwareDatetime, BaseModel, Field, model_validator

from app.modules.files.models import FileKind
from app.modules.materials.models import Movement
from app.modules.notifications.models import NotificationType
from app.modules.scheduling.models import AssignmentRole, AssignmentStatus, JobType
from app.modules.timetracking.models import CheckPurpose, EntryKind

Meters = Annotated[float, Field(ge=0, le=20_000_000)]


# --- reads -------------------------------------------------------------------------


class WorkerConfigOut(BaseModel):
    default_geofence_radius_m: int
    max_location_accuracy_m: int
    min_completion_photos: int
    start_window_minutes_before: int
    min_supported_app_version: str
    telegram_bot_username: str | None


class CrewMateOut(BaseModel):
    worker_id: int
    full_name: str
    role: AssignmentRole
    phone: str


class TaskOut(BaseModel):
    """A `visit_assignment` with everything the app needs offline."""

    id: int
    job_id: int
    visit_id: int
    job_type: JobType
    title: str
    project_name: str
    customer_name: str
    instructions: str
    site_name: str
    address: str
    latitude: float
    longitude: float
    # null → use config.default_geofence_radius_m
    geofence_radius_m: int | None
    access_notes: str
    site_contact_name: str | None
    site_contact_phone: str | None
    scheduled_start: datetime
    scheduled_end: datetime
    role: AssignmentRole
    status: AssignmentStatus
    crew: list[CrewMateOut]


class CatalogItemOut(BaseModel):
    id: int
    name: str
    unit: str


class ExpectedMaterialOut(BaseModel):
    item: CatalogItemOut
    quantity: Decimal


class HistoryEntryOut(BaseModel):
    task: TaskOut
    completed_at: datetime
    work_seconds: int
    break_seconds: int
    photo_count: int
    comment: str | None


class HistoryPageOut(BaseModel):
    items: list[HistoryEntryOut]
    # pass as ?cursor= for the next (older) page; null = no more
    next_cursor: int | None


class EarningsOut(BaseModel):
    month: str  # YYYY-MM (Yerevan)
    approved_tasks: int
    approved_amount: Decimal  # serialized as a string, e.g. "80000.00"
    currency: str


class NotificationOut(BaseModel):
    id: int
    type: NotificationType
    title: str
    body: str
    task_id: int | None
    created_at: datetime
    read_at: datetime | None


class NotificationPageOut(BaseModel):
    items: list[NotificationOut]
    next_cursor: int | None


# --- writes (idempotent PUTs keyed by client UUIDs) -------------------------------


class LocationCheckIn(BaseModel):
    task_id: int
    purpose: CheckPurpose
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    accuracy_m: Meters
    is_mocked: bool
    captured_at: AwareDatetime
    distance_m: Meters
    radius_m: Meters
    verified: bool


class LocationCheckOut(BaseModel):
    id: uuid.UUID
    server_distance_m: float
    radius_m: float
    server_verified: bool
    review_flags: list[str]


class TimeEntryIn(BaseModel):
    task_id: int
    kind: EntryKind
    started_at: AwareDatetime
    ended_at: AwareDatetime | None = None
    start_location_check_id: uuid.UUID | None = None

    @model_validator(mode="after")
    def _ordered(self) -> Self:
        if self.ended_at is not None and self.ended_at < self.started_at:
            raise ValueError("ended_at must not be before started_at.")
        return self


class TimeEntryOut(BaseModel):
    id: uuid.UUID
    task_id: int
    kind: EntryKind
    started_at: datetime
    ended_at: datetime | None
    task_status: AssignmentStatus


class MaterialMovementIn(BaseModel):
    task_id: int
    catalog_item_id: int
    quantity: Annotated[Decimal, Field(gt=0, max_digits=12, decimal_places=3)]
    movement: Movement
    note: str | None = Field(default=None, max_length=1000)
    recorded_at: AwareDatetime | None = None


class MaterialMovementOut(BaseModel):
    id: uuid.UUID
    task_id: int
    catalog_item_id: int
    quantity: Decimal
    movement: Movement


ImageType = Literal["image/jpeg", "image/png", "image/heic", "image/webp"]
PhotoKind = Literal[FileKind.PHOTO_BEFORE, FileKind.PHOTO_AFTER, FileKind.PHOTO]


class PresignIn(BaseModel):
    task_id: int
    kind: PhotoKind = FileKind.PHOTO
    mime_type: ImageType = "image/jpeg"
    size_bytes: int = Field(gt=0)
    taken_at: AwareDatetime | None = None
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)


class PresignOut(BaseModel):
    upload_url: str
    headers: dict[str, str]
    expires_at: datetime
    # true when the file was already confirmed (replay): skip the PUT, call confirm
    already_uploaded: bool


class FileOut(BaseModel):
    id: uuid.UUID
    status: str
    size_bytes: int


class CompletionIn(BaseModel):
    completed_at: AwareDatetime
    completion_location_check_id: uuid.UUID | None = None
    reported_work_seconds: int = Field(ge=0)
    reported_break_seconds: int = Field(ge=0)
    photo_ids: list[uuid.UUID] = Field(max_length=50)
    comment: str | None = Field(default=None, max_length=2000)


class CompletionOut(BaseModel):
    id: uuid.UUID
    task_id: int
    task_status: AssignmentStatus
    work_seconds: int
    break_seconds: int
    review_flags: list[str]
