"""`notifications`: content and read state live in PostgreSQL; FCM (Phase 3) is only
the delivery transport (ARCHITECTURE §26)."""

from datetime import datetime
from enum import StrEnum
from typing import Any

from sqlalchemy import BigInteger, DateTime, ForeignKey, Identity, Index, String, Text, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, text_enum


class NotificationType(StrEnum):
    TASK_ASSIGNED = "TASK_ASSIGNED"
    TASK_CHANGED = "TASK_CHANGED"
    TASK_CANCELLED = "TASK_CANCELLED"
    TASK_REMINDER = "TASK_REMINDER"
    SUBMISSION_ACCEPTED = "SUBMISSION_ACCEPTED"


class Notification(Base):
    __tablename__ = "notifications"
    __table_args__ = (Index("ix_notifications_user_id_id", "user_id", "id"),)

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
