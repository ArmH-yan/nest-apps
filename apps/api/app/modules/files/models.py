"""`files`: metadata only; the bytes live in object storage (ARCHITECTURE §8, §24)."""

import uuid
from datetime import datetime
from enum import StrEnum

from sqlalchemy import BigInteger, DateTime, Float, ForeignKey, Index, String, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, text_enum


class FileOwner(StrEnum):
    ASSIGNMENT = "ASSIGNMENT"
    JOB = "JOB"
    QUOTE = "QUOTE"
    REQUEST = "REQUEST"
    SITE = "SITE"


class FileKind(StrEnum):
    PHOTO_BEFORE = "PHOTO_BEFORE"
    PHOTO_AFTER = "PHOTO_AFTER"
    PHOTO = "PHOTO"
    PDF = "PDF"
    OTHER = "OTHER"


class FileStatus(StrEnum):
    PENDING = "PENDING"
    UPLOADED = "UPLOADED"


class File(Base):
    __tablename__ = "files"
    __table_args__ = (Index("ix_files_owner", "owner_type", "owner_id"),)

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    owner_type: Mapped[FileOwner] = mapped_column(text_enum(FileOwner, "file_owner"))
    owner_id: Mapped[int] = mapped_column(BigInteger)
    kind: Mapped[FileKind] = mapped_column(text_enum(FileKind, "file_kind"))
    storage_key: Mapped[str] = mapped_column(String(300), unique=True)
    file_name: Mapped[str | None] = mapped_column(String(200))
    mime_type: Mapped[str] = mapped_column(String(100))
    size_bytes: Mapped[int] = mapped_column(BigInteger)
    taken_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    latitude: Mapped[float | None] = mapped_column(Float)
    longitude: Mapped[float | None] = mapped_column(Float)
    uploaded_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    status: Mapped[FileStatus] = mapped_column(
        text_enum(FileStatus, "file_status"), server_default=FileStatus.PENDING.value
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    uploaded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
