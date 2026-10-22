"""`device_tokens` (ARCHITECTURE §8, §26): a phone's FCM registration token. A token
belongs to whoever logged in on that phone last; it is removed on logout, when FCM
says it is no longer registered, and when the worker is deactivated.
"""

from datetime import datetime
from enum import StrEnum

from sqlalchemy import BigInteger, DateTime, ForeignKey, Identity, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, text_enum


class Platform(StrEnum):
    ANDROID = "android"
    IOS = "ios"


class DeviceToken(Base):
    __tablename__ = "device_tokens"

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    fcm_token: Mapped[str] = mapped_column(Text, unique=True)
    platform: Mapped[Platform] = mapped_column(text_enum(Platform, "device_platform"))
    app_version: Mapped[str | None] = mapped_column(String(32))
    last_seen_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
