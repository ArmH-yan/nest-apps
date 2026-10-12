"""scheduling core: companies, contacts, sites, settings, services, projects,
jobs, visits, assignments (ARCHITECTURE §8, §11, §14)

Revision ID: 0004
Revises: 0003
Create Date: 2026-10-12 14:55:29.315210+00:00

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0004"
down_revision: str | None = "0003"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "companies",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("name", sa.String(length=200), nullable=False),
        sa.Column("tax_id", sa.String(length=20), nullable=True),
        sa.Column("phone", sa.String(length=20), nullable=True),
        sa.Column("email", sa.String(length=254), nullable=True),
        sa.Column("address", sa.String(length=300), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
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
        sa.PrimaryKeyConstraint("id", name=op.f("pk_companies")),
    )
    op.create_table(
        "reference_counters",
        sa.Column("prefix", sa.String(length=8), nullable=False),
        sa.Column("year", sa.Integer(), nullable=False),
        sa.Column("last_value", sa.Integer(), nullable=False),
        sa.PrimaryKeyConstraint("prefix", "year", name=op.f("pk_reference_counters")),
    )
    op.create_table(
        "services",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("slug", sa.String(length=64), nullable=False),
        sa.Column("name_hy", sa.String(length=200), nullable=False),
        sa.Column("name_ru", sa.String(length=200), nullable=False),
        sa.Column("name_en", sa.String(length=200), nullable=False),
        sa.Column("is_active", sa.Boolean(), server_default=sa.text("true"), nullable=False),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_services")),
        sa.UniqueConstraint("slug", name=op.f("uq_services_slug")),
    )
    op.create_table(
        "contacts",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("company_id", sa.BigInteger(), nullable=True),
        sa.Column("full_name", sa.String(length=200), nullable=False),
        sa.Column("position", sa.String(length=100), nullable=True),
        sa.Column("phone", sa.String(length=20), nullable=True),
        sa.Column("email", sa.String(length=254), nullable=True),
        sa.Column(
            "preferred_locale",
            sa.String(length=16),
            nullable=True,
        ),
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
            "preferred_locale IN ('hy', 'ru', 'en', 'hi', 'id')",
            name=op.f("ck_contacts_contact_locale"),
        ),
        sa.ForeignKeyConstraint(
            ["company_id"], ["companies.id"], name=op.f("fk_contacts_company_id_companies")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_contacts")),
    )
    op.create_index(op.f("ix_contacts_company_id"), "contacts", ["company_id"], unique=False)
    op.create_table(
        "settings",
        sa.Column("key", sa.String(length=64), nullable=False),
        sa.Column("value", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("updated_by", sa.BigInteger(), nullable=True),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["updated_by"], ["users.id"], name=op.f("fk_settings_updated_by_users")
        ),
        sa.PrimaryKeyConstraint("key", name=op.f("pk_settings")),
    )
    op.create_table(
        "sites",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("company_id", sa.BigInteger(), nullable=True),
        sa.Column("name", sa.String(length=200), nullable=False),
        sa.Column("address", sa.String(length=300), nullable=False),
        sa.Column("latitude", sa.Numeric(precision=9, scale=6), nullable=False),
        sa.Column("longitude", sa.Numeric(precision=9, scale=6), nullable=False),
        sa.Column(
            "location_confirmed", sa.Boolean(), server_default=sa.text("false"), nullable=False
        ),
        sa.Column("geofence_radius_m", sa.Integer(), nullable=True),
        sa.Column("access_notes", sa.Text(), nullable=True),
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
            "geofence_radius_m BETWEEN 10 AND 5000", name=op.f("ck_sites_radius_range")
        ),
        sa.CheckConstraint("latitude BETWEEN -90 AND 90", name=op.f("ck_sites_latitude_range")),
        sa.CheckConstraint("longitude BETWEEN -180 AND 180", name=op.f("ck_sites_longitude_range")),
        sa.ForeignKeyConstraint(
            ["company_id"], ["companies.id"], name=op.f("fk_sites_company_id_companies")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_sites")),
    )
    op.create_index(op.f("ix_sites_company_id"), "sites", ["company_id"], unique=False)
    op.create_table(
        "projects",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("reference", sa.String(length=20), nullable=False),
        sa.Column("name", sa.String(length=200), nullable=False),
        sa.Column("site_id", sa.BigInteger(), nullable=False),
        sa.Column("company_id", sa.BigInteger(), nullable=True),
        sa.Column("primary_contact_id", sa.BigInteger(), nullable=True),
        sa.Column("service_slug", sa.String(length=64), nullable=False),
        sa.Column(
            "status",
            sa.String(length=16),
            server_default="LEAD",
            nullable=False,
        ),
        sa.Column("expected_install_date", sa.Date(), nullable=True),
        sa.Column("expected_dismantle_date", sa.Date(), nullable=True),
        sa.Column("manager_id", sa.BigInteger(), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
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
            "status IN ('LEAD', 'SURVEY', 'QUOTED', 'WON', 'LOST', 'INSTALLED', 'DISMANTLED', 'CLOSED')",
            name=op.f("ck_projects_project_status"),
        ),
        sa.ForeignKeyConstraint(
            ["company_id"], ["companies.id"], name=op.f("fk_projects_company_id_companies")
        ),
        sa.ForeignKeyConstraint(
            ["manager_id"], ["users.id"], name=op.f("fk_projects_manager_id_users")
        ),
        sa.ForeignKeyConstraint(
            ["primary_contact_id"],
            ["contacts.id"],
            name=op.f("fk_projects_primary_contact_id_contacts"),
        ),
        sa.ForeignKeyConstraint(
            ["service_slug"], ["services.slug"], name=op.f("fk_projects_service_slug_services")
        ),
        sa.ForeignKeyConstraint(["site_id"], ["sites.id"], name=op.f("fk_projects_site_id_sites")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_projects")),
        sa.UniqueConstraint("reference", name=op.f("uq_projects_reference")),
    )
    op.create_index(op.f("ix_projects_company_id"), "projects", ["company_id"], unique=False)
    op.create_index(op.f("ix_projects_site_id"), "projects", ["site_id"], unique=False)
    op.create_table(
        "jobs",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("project_id", sa.BigInteger(), nullable=False),
        sa.Column("site_id", sa.BigInteger(), nullable=False),
        sa.Column(
            "job_type",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column(
            "status",
            sa.String(length=16),
            server_default="DRAFT",
            nullable=False,
        ),
        sa.Column("priority", sa.Integer(), server_default=sa.text("0"), nullable=False),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("instructions", sa.Text(), nullable=True),
        sa.Column("estimated_hours", sa.Numeric(precision=6, scale=2), nullable=True),
        sa.Column("created_by", sa.BigInteger(), nullable=True),
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
            "job_type IN ('SURVEY', 'INSTALLATION', 'INSPECTION', 'MAINTENANCE', 'DISMANTLING')",
            name=op.f("ck_jobs_job_type"),
        ),
        sa.CheckConstraint(
            "status IN ('DRAFT', 'SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_ACCESS')",
            name=op.f("ck_jobs_job_status"),
        ),
        sa.ForeignKeyConstraint(
            ["created_by"], ["users.id"], name=op.f("fk_jobs_created_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["project_id"], ["projects.id"], name=op.f("fk_jobs_project_id_projects")
        ),
        sa.ForeignKeyConstraint(["site_id"], ["sites.id"], name=op.f("fk_jobs_site_id_sites")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_jobs")),
    )
    op.create_index(op.f("ix_jobs_project_id"), "jobs", ["project_id"], unique=False)
    op.create_index(op.f("ix_jobs_site_id"), "jobs", ["site_id"], unique=False)
    op.create_table(
        "job_status_history",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("job_id", sa.BigInteger(), nullable=False),
        sa.Column(
            "old_status",
            sa.String(length=16),
            nullable=True,
        ),
        sa.Column(
            "new_status",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("changed_by", sa.BigInteger(), nullable=True),
        sa.Column(
            "changed_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("comment", sa.Text(), nullable=True),
        sa.CheckConstraint(
            "new_status IN ('DRAFT', 'SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_ACCESS')",
            name=op.f("ck_job_status_history_new_status"),
        ),
        sa.CheckConstraint(
            "old_status IN ('DRAFT', 'SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_ACCESS')",
            name=op.f("ck_job_status_history_old_status"),
        ),
        sa.ForeignKeyConstraint(
            ["changed_by"], ["users.id"], name=op.f("fk_job_status_history_changed_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["job_id"], ["jobs.id"], name=op.f("fk_job_status_history_job_id_jobs")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_job_status_history")),
    )
    op.create_index(
        op.f("ix_job_status_history_job_id"), "job_status_history", ["job_id"], unique=False
    )
    op.create_table(
        "job_visits",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("job_id", sa.BigInteger(), nullable=False),
        sa.Column("period", postgresql.TSTZRANGE(), nullable=False),
        sa.Column(
            "status",
            sa.String(length=16),
            server_default="PLANNED",
            nullable=False,
        ),
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
            "status IN ('PLANNED', 'DONE', 'CANCELLED')", name=op.f("ck_job_visits_visit_status")
        ),
        sa.ForeignKeyConstraint(["job_id"], ["jobs.id"], name=op.f("fk_job_visits_job_id_jobs")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_job_visits")),
    )
    op.create_index(op.f("ix_job_visits_job_id"), "job_visits", ["job_id"], unique=False)
    op.create_table(
        "visit_assignments",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("visit_id", sa.BigInteger(), nullable=False),
        sa.Column("worker_id", sa.BigInteger(), nullable=False),
        sa.Column(
            "role",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("period", postgresql.TSTZRANGE(), nullable=False),
        sa.Column(
            "status",
            sa.String(length=16),
            server_default="ASSIGNED",
            nullable=False,
        ),
        sa.Column("pay_amount", sa.Numeric(precision=12, scale=2), nullable=True),
        sa.Column("currency", sa.String(length=3), server_default="AMD", nullable=False),
        sa.Column("reviewed_by", sa.BigInteger(), nullable=True),
        sa.Column("reviewed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "review_flags",
            postgresql.ARRAY(sa.Text()),
            server_default=sa.text("'{}'"),
            nullable=False,
        ),
        sa.Column("assigned_by", sa.BigInteger(), nullable=True),
        sa.Column(
            "assigned_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
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
        postgresql.ExcludeConstraint(
            (sa.column("worker_id"), "="),
            (sa.column("period"), "&&"),
            where=sa.text("status <> 'CANCELLED'"),
            using="gist",
            name="no_worker_overlap",
        ),
        sa.CheckConstraint(
            "role IN ('LEAD', 'MEMBER')", name=op.f("ck_visit_assignments_assignment_role")
        ),
        sa.CheckConstraint(
            "status IN ('ASSIGNED', 'IN_PROGRESS', 'SUBMITTED', 'CANCELLED')",
            name=op.f("ck_visit_assignments_assignment_status"),
        ),
        sa.ForeignKeyConstraint(
            ["assigned_by"], ["users.id"], name=op.f("fk_visit_assignments_assigned_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["reviewed_by"], ["users.id"], name=op.f("fk_visit_assignments_reviewed_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["visit_id"], ["job_visits.id"], name=op.f("fk_visit_assignments_visit_id_job_visits")
        ),
        sa.ForeignKeyConstraint(
            ["worker_id"], ["workers.id"], name=op.f("fk_visit_assignments_worker_id_workers")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_visit_assignments")),
        sa.UniqueConstraint("visit_id", "worker_id", name="uq_visit_assignments_visit_worker"),
    )
    op.create_index(
        op.f("ix_visit_assignments_visit_id"), "visit_assignments", ["visit_id"], unique=False
    )
    op.create_index(
        op.f("ix_visit_assignments_worker_id"), "visit_assignments", ["worker_id"], unique=False
    )
    op.create_index(
        "uq_visit_assignments_one_lead",
        "visit_assignments",
        ["visit_id"],
        unique=True,
        postgresql_where=sa.text("role = 'LEAD' AND status <> 'CANCELLED'"),
    )

    op.bulk_insert(
        sa.table(
            "services",
            sa.column("slug", sa.String),
            sa.column("name_hy", sa.String),
            sa.column("name_ru", sa.String),
            sa.column("name_en", sa.String),
        ),
        [  # slugs match nest_web/src/config/services.ts
            {
                "slug": "safety-system",
                "name_hy": "Անվտանգության ցանցային համակարգ",
                "name_ru": "Защитная сетевая система",
                "name_en": "Safety net system",
            },
            {
                "slug": "dust-protection",
                "name_hy": "Փոշեպաշտպանություն",
                "name_ru": "Пылезащита",
                "name_en": "Dust protection",
            },
        ],
    )


def downgrade() -> None:
    op.drop_index(
        "uq_visit_assignments_one_lead",
        table_name="visit_assignments",
        postgresql_where=sa.text("role = 'LEAD' AND status <> 'CANCELLED'"),
    )
    op.drop_index(op.f("ix_visit_assignments_worker_id"), table_name="visit_assignments")
    op.drop_index(op.f("ix_visit_assignments_visit_id"), table_name="visit_assignments")
    op.drop_table("visit_assignments")
    op.drop_index(op.f("ix_job_visits_job_id"), table_name="job_visits")
    op.drop_table("job_visits")
    op.drop_index(op.f("ix_job_status_history_job_id"), table_name="job_status_history")
    op.drop_table("job_status_history")
    op.drop_index(op.f("ix_jobs_site_id"), table_name="jobs")
    op.drop_index(op.f("ix_jobs_project_id"), table_name="jobs")
    op.drop_table("jobs")
    op.drop_index(op.f("ix_projects_site_id"), table_name="projects")
    op.drop_index(op.f("ix_projects_company_id"), table_name="projects")
    op.drop_table("projects")
    op.drop_index(op.f("ix_sites_company_id"), table_name="sites")
    op.drop_table("sites")
    op.drop_table("settings")
    op.drop_index(op.f("ix_contacts_company_id"), table_name="contacts")
    op.drop_table("contacts")
    op.drop_table("services")
    op.drop_table("reference_counters")
    op.drop_table("companies")
