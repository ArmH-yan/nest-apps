"""`location_checks`, `time_entries`, `assignment_completions` (ARCHITECTURE §8, §19).

All three are created on the phone with client-generated UUIDs, so replays from the
offline outbox are idempotent. Device timestamps (`*_at`) are kept as sent;
`received_at` is server time.
"""

import uuid
from datetime import datetime
from enum import StrEnum

from sqlalchemy import (
    BigInteger,
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    Text,
    func,
    text,
)
from sqlalchemy.dialects.postgresql import UUID, ExcludeConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, text_enum


class CheckPurpose(StrEnum):
    START = "START"
    RESUME = "RESUME"
    COMPLETION = "COMPLETION"
    MANUAL = "MANUAL"


class EntryKind(StrEnum):
    WORK = "WORK"
    BREAK = "BREAK"


class LocationCheck(Base):
    __tablename__ = "location_checks"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    assignment_id: Mapped[int] = mapped_column(ForeignKey("visit_assignments.id"), index=True)
    worker_id: Mapped[int] = mapped_column(ForeignKey("workers.id"), index=True)
    purpose: Mapped[CheckPurpose] = mapped_column(text_enum(CheckPurpose, "check_purpose"))
    # GPS input is untrusted: stored as sent, judged again by the server (§19)
    latitude: Mapped[float] = mapped_column(Float)
    longitude: Mapped[float] = mapped_column(Float)
    accuracy_m: Mapped[float] = mapped_column(Float)
    is_mocked: Mapped[bool] = mapped_column(Boolean)
    captured_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    client_distance_m: Mapped[float] = mapped_column(Float)
    client_verified: Mapped[bool] = mapped_column(Boolean)
    server_distance_m: Mapped[float] = mapped_column(Float)
    radius_m: Mapped[float] = mapped_column(Float)
    server_verified: Mapped[bool] = mapped_column(Boolean)
    # set by a manager in timesheet review (Phase 3)
    override_reason: Mapped[str | None] = mapped_column(Text)
    overridden_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    received_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )


class TimeEntry(Base):
    __tablename__ = "time_entries"
    __table_args__ = (
        # A worker's sessions never overlap (open entries count until infinity).
        ExcludeConstraint(
            ("worker_id", "="),
            (text("tstzrange(started_at, coalesce(ended_at, 'infinity'))"), "&&"),
            name="no_time_overlap",
            using="gist",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    assignment_id: Mapped[int] = mapped_column(ForeignKey("visit_assignments.id"), index=True)
    worker_id: Mapped[int] = mapped_column(ForeignKey("workers.id"), index=True)
    kind: Mapped[EntryKind] = mapped_column(text_enum(EntryKind, "entry_kind"))
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    start_location_check_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("location_checks.id")
    )
    # server_now - device_now measured when the entry arrived (X-Device-Time)
    client_clock_offset_s: Mapped[int | None] = mapped_column(Integer)
    received_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )


class AssignmentCompletion(Base):
    __tablename__ = "assignment_completions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    assignment_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("visit_assignments.id"), unique=True
    )
    completed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    completion_location_check_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("location_checks.id")
    )
    reported_work_seconds: Mapped[int] = mapped_column(Integer)
    reported_break_seconds: Mapped[int] = mapped_column(Integer)
    # recomputed from time_entries (§8); a mismatch adds TOTALS_MISMATCH
    work_seconds: Mapped[int] = mapped_column(Integer)
    break_seconds: Mapped[int] = mapped_column(Integer)
    comment: Mapped[str | None] = mapped_column(Text)
    received_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
