"""`jobs`, `job_visits`, `visit_assignments`, `job_status_history` (ARCHITECTURE §8, §11).

A `visit_assignment` is what the worker app calls a "Task": one worker on one visit.
Double booking is prevented by the database (`no_worker_overlap`).
"""

from datetime import datetime
from decimal import Decimal
from enum import StrEnum

from sqlalchemy import (
    BigInteger,
    DateTime,
    ForeignKey,
    Identity,
    Index,
    Integer,
    Numeric,
    String,
    Text,
    UniqueConstraint,
    func,
    text,
)
from sqlalchemy.dialects.postgresql import ARRAY, TSTZRANGE, ExcludeConstraint, Range
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, text_enum


class JobType(StrEnum):
    SURVEY = "SURVEY"
    INSTALLATION = "INSTALLATION"
    INSPECTION = "INSPECTION"
    MAINTENANCE = "MAINTENANCE"
    DISMANTLING = "DISMANTLING"


class JobStatus(StrEnum):
    DRAFT = "DRAFT"
    SCHEDULED = "SCHEDULED"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"
    NO_ACCESS = "NO_ACCESS"


class VisitStatus(StrEnum):
    PLANNED = "PLANNED"
    DONE = "DONE"
    CANCELLED = "CANCELLED"


class AssignmentRole(StrEnum):
    LEAD = "LEAD"
    MEMBER = "MEMBER"


class AssignmentStatus(StrEnum):
    ASSIGNED = "ASSIGNED"
    IN_PROGRESS = "IN_PROGRESS"
    SUBMITTED = "SUBMITTED"
    CANCELLED = "CANCELLED"


class Job(TimestampMixin, Base):
    __tablename__ = "jobs"

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    project_id: Mapped[int] = mapped_column(ForeignKey("projects.id"), index=True)
    site_id: Mapped[int] = mapped_column(ForeignKey("sites.id"), index=True)
    job_type: Mapped[JobType] = mapped_column(text_enum(JobType, "job_type"))
    status: Mapped[JobStatus] = mapped_column(
        text_enum(JobStatus, "job_status"), server_default=JobStatus.DRAFT.value
    )
    priority: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    title: Mapped[str] = mapped_column(String(200))  # "Install Safety Net - Building A"
    instructions: Mapped[str | None] = mapped_column(Text)
    estimated_hours: Mapped[Decimal | None] = mapped_column(Numeric(6, 2))
    created_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))


class JobVisit(TimestampMixin, Base):
    __tablename__ = "job_visits"

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    job_id: Mapped[int] = mapped_column(ForeignKey("jobs.id"), index=True)
    period: Mapped[Range[datetime]] = mapped_column(TSTZRANGE)
    status: Mapped[VisitStatus] = mapped_column(
        text_enum(VisitStatus, "visit_status"), server_default=VisitStatus.PLANNED.value
    )


class VisitAssignment(TimestampMixin, Base):
    __tablename__ = "visit_assignments"
    __table_args__ = (
        UniqueConstraint("visit_id", "worker_id", name="uq_visit_assignments_visit_worker"),
        # at most one active LEAD per visit
        Index(
            "uq_visit_assignments_one_lead",
            "visit_id",
            unique=True,
            postgresql_where=text("role = 'LEAD' AND status <> 'CANCELLED'"),
        ),
        ExcludeConstraint(
            ("worker_id", "="),
            ("period", "&&"),
            name="no_worker_overlap",
            using="gist",
            where=text("status <> 'CANCELLED'"),
        ),
    )

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    visit_id: Mapped[int] = mapped_column(ForeignKey("job_visits.id"), index=True)
    worker_id: Mapped[int] = mapped_column(ForeignKey("workers.id"), index=True)
    role: Mapped[AssignmentRole] = mapped_column(text_enum(AssignmentRole, "assignment_role"))
    # copied from the visit and kept in sync by the service
    period: Mapped[Range[datetime]] = mapped_column(TSTZRANGE)
    status: Mapped[AssignmentStatus] = mapped_column(
        text_enum(AssignmentStatus, "assignment_status"),
        server_default=AssignmentStatus.ASSIGNED.value,
    )
    # fixed pay for this task, entered by the manager (§8 "Worker pay")
    pay_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    currency: Mapped[str] = mapped_column(String(3), server_default="AMD")
    reviewed_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    review_flags: Mapped[list[str]] = mapped_column(ARRAY(Text), server_default=text("'{}'"))
    assigned_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    assigned_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )


class JobStatusHistory(Base):
    __tablename__ = "job_status_history"

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    job_id: Mapped[int] = mapped_column(ForeignKey("jobs.id"), index=True)
    old_status: Mapped[JobStatus | None] = mapped_column(text_enum(JobStatus, "old_status"))
    new_status: Mapped[JobStatus] = mapped_column(text_enum(JobStatus, "new_status"))
    changed_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))  # null = system
    changed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    comment: Mapped[str | None] = mapped_column(Text)
