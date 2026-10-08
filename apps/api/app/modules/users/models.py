"""`users` and `workers` (ARCHITECTURE §6, §8)."""

from enum import StrEnum

from sqlalchemy import (
    BigInteger,
    Boolean,
    Enum,
    ForeignKey,
    Identity,
    String,
    Text,
    text,
)
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin


class UserRole(StrEnum):
    ADMIN = "ADMIN"
    MANAGER = "MANAGER"
    WORKER = "WORKER"


class UserLocale(StrEnum):
    HY = "hy"
    RU = "ru"
    EN = "en"


def _text_enum(enum: type[StrEnum], name: str) -> Enum:
    """Stored as text + CHECK constraint (ARCHITECTURE §8), so adding a value is a
    plain constraint change instead of an ALTER TYPE."""
    return Enum(
        enum,
        name=name,
        native_enum=False,
        create_constraint=True,
        length=16,
        values_callable=lambda members: [m.value for m in members],
    )


class User(TimestampMixin, Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    # E.164-like, normalized by the service ("+37491000007"). Login identifier.
    phone: Mapped[str] = mapped_column(String(20), unique=True)
    # Lower-cased by the service.
    email: Mapped[str | None] = mapped_column(String(254), unique=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    first_name: Mapped[str] = mapped_column(String(100))
    last_name: Mapped[str] = mapped_column(String(100))
    role: Mapped[UserRole] = mapped_column(_text_enum(UserRole, "user_role"))
    locale: Mapped[UserLocale] = mapped_column(
        _text_enum(UserLocale, "user_locale"), server_default=UserLocale.HY.value
    )
    telegram_chat_id: Mapped[int | None] = mapped_column(BigInteger)
    must_change_password: Mapped[bool] = mapped_column(Boolean, server_default=text("true"))
    is_active: Mapped[bool] = mapped_column(Boolean, server_default=text("true"))

    @property
    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}".strip()


class Worker(TimestampMixin, Base):
    __tablename__ = "workers"

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True)
    employee_code: Mapped[str] = mapped_column(String(32), unique=True)
    # e.g. safety_net, dust_net, rope_access
    skills: Mapped[list[str]] = mapped_column(ARRAY(Text), server_default=text("'{}'"))
    is_active: Mapped[bool] = mapped_column(Boolean, server_default=text("true"))
