"""`notifications`: content and read state live in PostgreSQL; FCM is only the
delivery transport (ARCHITECTURE §26).

Each row is also its own push job: it is inserted PENDING in the same transaction as
the change that causes it, and the push worker (`app.modules.push`) delivers it.
"""

from datetime import datetime
from enum import StrEnum
from typing import Any

from sqlalchemy import (
    BigInteger,
    DateTime,
    ForeignKey,
    Identity,
    Index,
    Integer,
    String,
    Text,
    func,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, text_enum


class NotificationType(StrEnum):
    TASK_ASSIGNED = "TASK_ASSIGNED"
    TASK_CHANGED = "TASK_CHANGED"
    TASK_CANCELLED = "TASK_CANCELLED"
    TASK_REMINDER = "TASK_REMINDER"
    SUBMISSION_ACCEPTED = "SUBMISSION_ACCEPTED"


class PushStatus(StrEnum):
    PENDING = "PENDING"  # waiting for the push worker
    SENT = "SENT"  # FCM accepted it for at least one device
    SKIPPED = "SKIPPED"  # no device, or too old to be worth a push
    FAILED = "FAILED"  # gave up after retries


class Notification(Base):
    __tablename__ = "notifications"
    __table_args__ = (
        Index("ix_notifications_user_id_id", "user_id", "id"),
        # the push worker's queue
        Index(
            "ix_notifications_push_pending",
            "next_push_at",
            postgresql_where=text("push_status = 'PENDING'"),
        ),
    )

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    type: Mapped[NotificationType] = mapped_column(
        text_enum(NotificationType, "notification_type", length=32)
    )
    title: Mapped[str] = mapped_column(String(200))
    body: Mapped[str] = mapped_column(Text)
    # e.g. {"assignment_id": 812}
    data: Mapped[dict[str, Any]] = mapped_column(JSONB, server_default="{}")
    read_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    # set for generated notifications that must exist once (task reminders)
    dedupe_key: Mapped[str | None] = mapped_column(String(120), unique=True)
    push_status: Mapped[PushStatus] = mapped_column(
        text_enum(PushStatus, "push_status"), server_default=PushStatus.PENDING.value
    )
    push_attempts: Mapped[int] = mapped_column(Integer, server_default="0")
    next_push_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    pushed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    push_error: Mapped[str | None] = mapped_column(Text)
