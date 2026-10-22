"""`assessment_requests` (ARCHITECTURE §8, §9, §12): the raw intake from the website,
a phone call or a manager. What was submitted is kept exactly as received
(`submitted_*`); review and conversion only add links and a status.
"""

from datetime import date
from decimal import Decimal
from enum import StrEnum

from sqlalchemy import BigInteger, Date, ForeignKey, Identity, Numeric, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, text_enum


class RequestStatus(StrEnum):
    NEW = "NEW"
    IN_REVIEW = "IN_REVIEW"
    CONVERTED = "CONVERTED"
    REJECTED = "REJECTED"
    SPAM = "SPAM"


class RequestSource(StrEnum):
    WEBSITE = "website"
    PHONE = "phone"
    MANUAL = "manual"


class AssessmentRequest(TimestampMixin, Base):
    __tablename__ = "assessment_requests"

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    reference: Mapped[str] = mapped_column(String(20), unique=True)  # REQ-2026-0001
    status: Mapped[RequestStatus] = mapped_column(
        text_enum(RequestStatus, "request_status"),
        server_default=RequestStatus.NEW.value,
        index=True,
    )
    source: Mapped[RequestSource] = mapped_column(text_enum(RequestSource, "request_source"))
    locale: Mapped[str | None] = mapped_column(String(8))
    submitted_name: Mapped[str] = mapped_column(String(200))
    submitted_company: Mapped[str | None] = mapped_column(String(200))
    submitted_phone: Mapped[str | None] = mapped_column(String(40))
    submitted_email: Mapped[str | None] = mapped_column(String(200))
    # the website sends the service's display name in the visitor's language;
    # kept as text, and matched to `services.slug` when it is known
    submitted_service: Mapped[str | None] = mapped_column(String(200))
    service_slug: Mapped[str | None] = mapped_column(ForeignKey("services.slug"))
    project_type: Mapped[str | None] = mapped_column(String(200))
    message: Mapped[str] = mapped_column(Text)
    site_address: Mapped[str | None] = mapped_column(String(300))
    latitude: Mapped[Decimal | None] = mapped_column(Numeric(9, 6))
    longitude: Mapped[Decimal | None] = mapped_column(Numeric(9, 6))
    preferred_date: Mapped[date | None] = mapped_column(Date)
    review_note: Mapped[str | None] = mapped_column(Text)
    contact_id: Mapped[int | None] = mapped_column(ForeignKey("contacts.id"))
    project_id: Mapped[int | None] = mapped_column(ForeignKey("projects.id"))
    reviewed_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
