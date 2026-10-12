"""`projects`: one engagement at one site (ARCHITECTURE §8, §10)."""

from datetime import date
from enum import StrEnum

from sqlalchemy import BigInteger, Date, ForeignKey, Identity, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, text_enum


class ProjectStatus(StrEnum):
    LEAD = "LEAD"
    SURVEY = "SURVEY"
    QUOTED = "QUOTED"
    WON = "WON"
    LOST = "LOST"
    INSTALLED = "INSTALLED"
    DISMANTLED = "DISMANTLED"
    CLOSED = "CLOSED"


class Project(TimestampMixin, Base):
    __tablename__ = "projects"

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    reference: Mapped[str] = mapped_column(String(20), unique=True)  # P-2026-0001
    name: Mapped[str] = mapped_column(String(200))  # "Davtashen Residential"
    site_id: Mapped[int] = mapped_column(ForeignKey("sites.id"), index=True)
    company_id: Mapped[int | None] = mapped_column(ForeignKey("companies.id"), index=True)
    primary_contact_id: Mapped[int | None] = mapped_column(ForeignKey("contacts.id"))
    service_slug: Mapped[str] = mapped_column(ForeignKey("services.slug"))
    status: Mapped[ProjectStatus] = mapped_column(
        text_enum(ProjectStatus, "project_status"), server_default=ProjectStatus.LEAD.value
    )
    expected_install_date: Mapped[date | None] = mapped_column(Date)
    expected_dismantle_date: Mapped[date | None] = mapped_column(Date)
    manager_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    notes: Mapped[str | None] = mapped_column(Text)
