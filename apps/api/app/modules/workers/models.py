"""`worker_time_off` (ARCHITECTURE §8, §14): days a worker is away. Scheduling over
time off is a warning, not a block (§14 "v1 rules"); two absences of the same
worker may not overlap (`no_time_off_overlap`).
"""

from datetime import datetime
from enum import StrEnum

from sqlalchemy import BigInteger, DateTime, ForeignKey, Identity, Text, func
from sqlalchemy.dialects.postgresql import TSTZRANGE, ExcludeConstraint, Range
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, text_enum


class TimeOffReason(StrEnum):
    VACATION = "VACATION"
    SICK = "SICK"
    OTHER = "OTHER"


class WorkerTimeOff(Base):
    __tablename__ = "worker_time_off"
    __table_args__ = (
        ExcludeConstraint(
            ("worker_id", "="),
            ("period", "&&"),
            name="no_time_off_overlap",
            using="gist",
        ),
    )

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    worker_id: Mapped[int] = mapped_column(ForeignKey("workers.id"), index=True)
    # whole Yerevan days: [first day 00:00, day after the last day 00:00)
    period: Mapped[Range[datetime]] = mapped_column(TSTZRANGE)
    reason: Mapped[TimeOffReason] = mapped_column(text_enum(TimeOffReason, "time_off_reason"))
    note: Mapped[str | None] = mapped_column(Text)
    created_by: Mapped[int] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
