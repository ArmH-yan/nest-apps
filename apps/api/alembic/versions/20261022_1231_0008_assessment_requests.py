"""assessment requests: website, phone and manual leads (ARCHITECTURE §8, §9, §12)

Revision ID: 0008
Revises: 0007
Create Date: 2026-10-22 12:31:23.993584+00:00

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op


revision: str = "0008"
down_revision: str | None = "0007"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "assessment_requests",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("reference", sa.String(length=20), nullable=False),
        sa.Column(
            "status",
            sa.String(length=16),
            server_default="NEW",
            nullable=False,
        ),
        sa.Column(
            "source",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("locale", sa.String(length=8), nullable=True),
        sa.Column("submitted_name", sa.String(length=200), nullable=False),
        sa.Column("submitted_company", sa.String(length=200), nullable=True),
        sa.Column("submitted_phone", sa.String(length=40), nullable=True),
        sa.Column("submitted_email", sa.String(length=200), nullable=True),
        sa.Column("submitted_service", sa.String(length=200), nullable=True),
        sa.Column("service_slug", sa.String(length=64), nullable=True),
        sa.Column("project_type", sa.String(length=200), nullable=True),
        sa.Column("message", sa.Text(), nullable=False),
        sa.Column("site_address", sa.String(length=300), nullable=True),
        sa.Column("latitude", sa.Numeric(precision=9, scale=6), nullable=True),
        sa.Column("longitude", sa.Numeric(precision=9, scale=6), nullable=True),
        sa.Column("preferred_date", sa.Date(), nullable=True),
        sa.Column("review_note", sa.Text(), nullable=True),
        sa.Column("contact_id", sa.BigInteger(), nullable=True),
        sa.Column("project_id", sa.BigInteger(), nullable=True),
        sa.Column("reviewed_by", sa.BigInteger(), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "source IN ('website', 'phone', 'manual')",
            name=op.f("ck_assessment_requests_request_source"),
        ),
        sa.CheckConstraint(
            "status IN ('NEW', 'IN_REVIEW', 'CONVERTED', 'REJECTED', 'SPAM')",
            name=op.f("ck_assessment_requests_request_status"),
        ),
        sa.ForeignKeyConstraint(
            ["contact_id"], ["contacts.id"], name=op.f("fk_assessment_requests_contact_id_contacts")
        ),
        sa.ForeignKeyConstraint(
            ["project_id"], ["projects.id"], name=op.f("fk_assessment_requests_project_id_projects")
        ),
        sa.ForeignKeyConstraint(
            ["reviewed_by"], ["users.id"], name=op.f("fk_assessment_requests_reviewed_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["service_slug"],
            ["services.slug"],
            name=op.f("fk_assessment_requests_service_slug_services"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_assessment_requests")),
        sa.UniqueConstraint("reference", name=op.f("uq_assessment_requests_reference")),
    )
    op.create_index(
        op.f("ix_assessment_requests_status"), "assessment_requests", ["status"], unique=False
    )


def downgrade() -> None:
    op.drop_index(op.f("ix_assessment_requests_status"), table_name="assessment_requests")
    op.drop_table("assessment_requests")
