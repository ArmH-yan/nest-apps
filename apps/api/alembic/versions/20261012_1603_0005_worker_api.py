"""worker api: location checks, time entries, completions, catalog, material
movements, files, notifications (ARCHITECTURE §8, §18, §19, §24, §26)

Revision ID: 0005
Revises: 0004
Create Date: 2026-10-12 16:03:56.197081+00:00

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0005"
down_revision: str | None = "0004"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


_MATERIAL = {"kind": "MATERIAL", "is_trackable": True}


def upgrade() -> None:
    op.create_table(
        "catalog_items",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("sku", sa.String(length=64), nullable=False),
        sa.Column("name_hy", sa.String(length=200), nullable=False),
        sa.Column("name_ru", sa.String(length=200), nullable=False),
        sa.Column("name_en", sa.String(length=200), nullable=False),
        sa.Column(
            "kind",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column(
            "unit",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("default_price", sa.Numeric(precision=12, scale=2), nullable=True),
        sa.Column("is_trackable", sa.Boolean(), server_default=sa.text("false"), nullable=False),
        sa.Column("is_active", sa.Boolean(), server_default=sa.text("true"), nullable=False),
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
            "kind IN ('MATERIAL', 'LABOR', 'SERVICE', 'RENTAL')",
            name=op.f("ck_catalog_items_catalog_kind"),
        ),
        sa.CheckConstraint(
            "unit IN ('m2', 'm', 'pcs', 'day', 'lump')", name=op.f("ck_catalog_items_catalog_unit")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_catalog_items")),
        sa.UniqueConstraint("sku", name=op.f("uq_catalog_items_sku")),
    )
    op.create_table(
        "files",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column(
            "owner_type",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("owner_id", sa.BigInteger(), nullable=False),
        sa.Column(
            "kind",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("storage_key", sa.String(length=300), nullable=False),
        sa.Column("file_name", sa.String(length=200), nullable=True),
        sa.Column("mime_type", sa.String(length=100), nullable=False),
        sa.Column("size_bytes", sa.BigInteger(), nullable=False),
        sa.Column("taken_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("latitude", sa.Float(), nullable=True),
        sa.Column("longitude", sa.Float(), nullable=True),
        sa.Column("uploaded_by", sa.BigInteger(), nullable=True),
        sa.Column(
            "status",
            sa.String(length=16),
            server_default="PENDING",
            nullable=False,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("uploaded_at", sa.DateTime(timezone=True), nullable=True),
        sa.CheckConstraint(
            "kind IN ('PHOTO_BEFORE', 'PHOTO_AFTER', 'PHOTO', 'PDF', 'OTHER')",
            name=op.f("ck_files_file_kind"),
        ),
        sa.CheckConstraint(
            "owner_type IN ('ASSIGNMENT', 'JOB', 'QUOTE', 'REQUEST', 'SITE')",
            name=op.f("ck_files_file_owner"),
        ),
        sa.CheckConstraint("status IN ('PENDING', 'UPLOADED')", name=op.f("ck_files_file_status")),
        sa.ForeignKeyConstraint(
            ["uploaded_by"], ["users.id"], name=op.f("fk_files_uploaded_by_users")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_files")),
        sa.UniqueConstraint("storage_key", name=op.f("uq_files_storage_key")),
    )
    op.create_index("ix_files_owner", "files", ["owner_type", "owner_id"], unique=False)
    op.create_table(
        "notifications",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column(
            "type",
            sa.String(length=32),
            nullable=False,
        ),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("body", sa.Text(), nullable=False),
        sa.Column(
            "data", postgresql.JSONB(astext_type=sa.Text()), server_default="{}", nullable=False
        ),
        sa.Column("read_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "type IN ('TASK_ASSIGNED', 'TASK_CHANGED', 'TASK_CANCELLED', 'TASK_REMINDER', 'SUBMISSION_ACCEPTED')",
            name=op.f("ck_notifications_notification_type"),
        ),
        sa.ForeignKeyConstraint(
            ["user_id"], ["users.id"], name=op.f("fk_notifications_user_id_users")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_notifications")),
    )
    op.create_index("ix_notifications_user_id_id", "notifications", ["user_id", "id"], unique=False)
    op.create_table(
        "location_checks",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("assignment_id", sa.BigInteger(), nullable=False),
        sa.Column("worker_id", sa.BigInteger(), nullable=False),
        sa.Column(
            "purpose",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("latitude", sa.Float(), nullable=False),
        sa.Column("longitude", sa.Float(), nullable=False),
        sa.Column("accuracy_m", sa.Float(), nullable=False),
        sa.Column("is_mocked", sa.Boolean(), nullable=False),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("client_distance_m", sa.Float(), nullable=False),
        sa.Column("client_verified", sa.Boolean(), nullable=False),
        sa.Column("server_distance_m", sa.Float(), nullable=False),
        sa.Column("radius_m", sa.Float(), nullable=False),
        sa.Column("server_verified", sa.Boolean(), nullable=False),
        sa.Column("override_reason", sa.Text(), nullable=True),
        sa.Column("overridden_by", sa.BigInteger(), nullable=True),
        sa.Column(
            "received_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "purpose IN ('START', 'RESUME', 'COMPLETION', 'MANUAL')",
            name=op.f("ck_location_checks_check_purpose"),
        ),
        sa.ForeignKeyConstraint(
            ["assignment_id"],
            ["visit_assignments.id"],
            name=op.f("fk_location_checks_assignment_id_visit_assignments"),
        ),
        sa.ForeignKeyConstraint(
            ["overridden_by"], ["users.id"], name=op.f("fk_location_checks_overridden_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["worker_id"], ["workers.id"], name=op.f("fk_location_checks_worker_id_workers")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_location_checks")),
    )
    op.create_index(
        op.f("ix_location_checks_assignment_id"), "location_checks", ["assignment_id"], unique=False
    )
    op.create_index(
        op.f("ix_location_checks_worker_id"), "location_checks", ["worker_id"], unique=False
    )
    op.create_table(
        "site_material_movements",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("site_id", sa.BigInteger(), nullable=False),
        sa.Column("project_id", sa.BigInteger(), nullable=False),
        sa.Column("job_id", sa.BigInteger(), nullable=True),
        sa.Column("assignment_id", sa.BigInteger(), nullable=True),
        sa.Column("catalog_item_id", sa.BigInteger(), nullable=False),
        sa.Column("quantity", sa.Numeric(precision=12, scale=3), nullable=False),
        sa.Column(
            "movement",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("recorded_by", sa.BigInteger(), nullable=False),
        sa.Column("recorded_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column(
            "received_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "movement IN ('INSTALLED', 'RETRIEVED', 'DAMAGED', 'LOST', 'ADJUSTMENT')",
            name=op.f("ck_site_material_movements_movement"),
        ),
        sa.CheckConstraint(
            "quantity > 0", name=op.f("ck_site_material_movements_quantity_positive")
        ),
        sa.ForeignKeyConstraint(
            ["assignment_id"],
            ["visit_assignments.id"],
            name=op.f("fk_site_material_movements_assignment_id_visit_assignments"),
        ),
        sa.ForeignKeyConstraint(
            ["catalog_item_id"],
            ["catalog_items.id"],
            name=op.f("fk_site_material_movements_catalog_item_id_catalog_items"),
        ),
        sa.ForeignKeyConstraint(
            ["job_id"], ["jobs.id"], name=op.f("fk_site_material_movements_job_id_jobs")
        ),
        sa.ForeignKeyConstraint(
            ["project_id"],
            ["projects.id"],
            name=op.f("fk_site_material_movements_project_id_projects"),
        ),
        sa.ForeignKeyConstraint(
            ["recorded_by"], ["users.id"], name=op.f("fk_site_material_movements_recorded_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["site_id"], ["sites.id"], name=op.f("fk_site_material_movements_site_id_sites")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_site_material_movements")),
    )
    op.create_index(
        op.f("ix_site_material_movements_project_id"),
        "site_material_movements",
        ["project_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_site_material_movements_site_id"),
        "site_material_movements",
        ["site_id"],
        unique=False,
    )
    op.create_table(
        "assignment_completions",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("assignment_id", sa.BigInteger(), nullable=False),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("completion_location_check_id", sa.UUID(), nullable=True),
        sa.Column("reported_work_seconds", sa.Integer(), nullable=False),
        sa.Column("reported_break_seconds", sa.Integer(), nullable=False),
        sa.Column("work_seconds", sa.Integer(), nullable=False),
        sa.Column("break_seconds", sa.Integer(), nullable=False),
        sa.Column("comment", sa.Text(), nullable=True),
        sa.Column(
            "received_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["assignment_id"],
            ["visit_assignments.id"],
            name=op.f("fk_assignment_completions_assignment_id_visit_assignments"),
        ),
        sa.ForeignKeyConstraint(
            ["completion_location_check_id"],
            ["location_checks.id"],
            name=op.f("fk_assignment_completions_completion_location_check_id_location_checks"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_assignment_completions")),
        sa.UniqueConstraint("assignment_id", name=op.f("uq_assignment_completions_assignment_id")),
    )
    op.create_table(
        "time_entries",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("assignment_id", sa.BigInteger(), nullable=False),
        sa.Column("worker_id", sa.BigInteger(), nullable=False),
        sa.Column(
            "kind",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("start_location_check_id", sa.UUID(), nullable=True),
        sa.Column("client_clock_offset_s", sa.Integer(), nullable=True),
        sa.Column(
            "received_at",
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
            (sa.text("tstzrange(started_at, coalesce(ended_at, 'infinity'))"), "&&"),
            using="gist",
            name="no_time_overlap",
        ),
        sa.CheckConstraint("kind IN ('WORK', 'BREAK')", name=op.f("ck_time_entries_entry_kind")),
        sa.ForeignKeyConstraint(
            ["assignment_id"],
            ["visit_assignments.id"],
            name=op.f("fk_time_entries_assignment_id_visit_assignments"),
        ),
        sa.ForeignKeyConstraint(
            ["start_location_check_id"],
            ["location_checks.id"],
            name=op.f("fk_time_entries_start_location_check_id_location_checks"),
        ),
        sa.ForeignKeyConstraint(
            ["worker_id"], ["workers.id"], name=op.f("fk_time_entries_worker_id_workers")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_time_entries")),
    )
    op.create_index(
        op.f("ix_time_entries_assignment_id"), "time_entries", ["assignment_id"], unique=False
    )
    op.create_index(op.f("ix_time_entries_worker_id"), "time_entries", ["worker_id"], unique=False)

    # Starter catalog of trackable site materials (editable later in the manager app).
    catalog = sa.table(
        "catalog_items",
        sa.column("sku", sa.String),
        sa.column("name_hy", sa.String),
        sa.column("name_ru", sa.String),
        sa.column("name_en", sa.String),
        sa.column("kind", sa.String),
        sa.column("unit", sa.String),
        sa.column("is_trackable", sa.Boolean),
    )
    op.bulk_insert(
        catalog,
        [
            {
                "sku": "NET-10X5",
                "name_hy": "Անվտանգության ցանց 10×5 մ",
                "name_ru": "Защитная сетка 10×5 м",
                "name_en": "Safety net 10×5 m",
                "unit": "pcs",
                **_MATERIAL,
            },
            {
                "sku": "NET-M2",
                "name_hy": "Անվտանգության ցանց",
                "name_ru": "Защитная сетка",
                "name_en": "Safety net",
                "unit": "m2",
                **_MATERIAL,
            },
            {
                "sku": "DUST-M2",
                "name_hy": "Փոշեպաշտպան ցանց",
                "name_ru": "Пылезащитная сетка",
                "name_en": "Dust net",
                "unit": "m2",
                **_MATERIAL,
            },
            {
                "sku": "ANCHOR-M12",
                "name_hy": "Խարիսխ M12",
                "name_ru": "Анкер M12",
                "name_en": "Anchor M12",
                "unit": "pcs",
                **_MATERIAL,
            },
            {
                "sku": "CABLE-8",
                "name_hy": "Պողպատե մալուխ 8 մմ",
                "name_ru": "Стальной трос 8 мм",
                "name_en": "Steel cable 8 mm",
                "unit": "m",
                **_MATERIAL,
            },
        ],
        multiinsert=False,
    )


def downgrade() -> None:
    op.drop_index(op.f("ix_time_entries_worker_id"), table_name="time_entries")
    op.drop_index(op.f("ix_time_entries_assignment_id"), table_name="time_entries")
    op.drop_table("time_entries")
    op.drop_table("assignment_completions")
    op.drop_index(op.f("ix_site_material_movements_site_id"), table_name="site_material_movements")
    op.drop_index(
        op.f("ix_site_material_movements_project_id"), table_name="site_material_movements"
    )
    op.drop_table("site_material_movements")
    op.drop_index(op.f("ix_location_checks_worker_id"), table_name="location_checks")
    op.drop_index(op.f("ix_location_checks_assignment_id"), table_name="location_checks")
    op.drop_table("location_checks")
    op.drop_index("ix_notifications_user_id_id", table_name="notifications")
    op.drop_table("notifications")
    op.drop_index("ix_files_owner", table_name="files")
    op.drop_table("files")
    op.drop_table("catalog_items")
