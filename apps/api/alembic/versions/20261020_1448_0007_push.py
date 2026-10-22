"""push: device tokens, push state on notifications (ARCHITECTURE §26)

Revision ID: 0007
Revises: 0006
Create Date: 2026-10-20 14:48:42.969359+00:00

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0007"
down_revision: str | None = "0006"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "device_tokens",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("fcm_token", sa.Text(), nullable=False),
        sa.Column(
            "platform",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("app_version", sa.String(length=32), nullable=True),
        sa.Column(
            "last_seen_at",
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
        sa.CheckConstraint(
            "platform IN ('android', 'ios')", name=op.f("ck_device_tokens_device_platform")
        ),
        sa.ForeignKeyConstraint(
            ["user_id"], ["users.id"], name=op.f("fk_device_tokens_user_id_users")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_device_tokens")),
        sa.UniqueConstraint("fcm_token", name=op.f("uq_device_tokens_fcm_token")),
    )
    op.create_index(op.f("ix_device_tokens_user_id"), "device_tokens", ["user_id"], unique=False)
    op.add_column("notifications", sa.Column("dedupe_key", sa.String(length=120), nullable=True))
    op.add_column(
        "notifications",
        sa.Column(
            "push_status",
            sa.String(length=16),
            server_default="PENDING",
            nullable=False,
        ),
    )
    op.add_column(
        "notifications",
        sa.Column("push_attempts", sa.Integer(), server_default="0", nullable=False),
    )
    op.add_column(
        "notifications",
        sa.Column(
            "next_push_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
    )
    op.create_check_constraint(
        op.f("ck_notifications_push_status"),
        "notifications",
        "push_status IN ('PENDING', 'SENT', 'SKIPPED', 'FAILED')",
    )
    # notifications from before push existed are never pushed
    op.execute("UPDATE notifications SET push_status = 'SKIPPED'")
    op.add_column(
        "notifications", sa.Column("pushed_at", sa.DateTime(timezone=True), nullable=True)
    )
    op.add_column("notifications", sa.Column("push_error", sa.Text(), nullable=True))
    op.create_index(
        "ix_notifications_push_pending",
        "notifications",
        ["next_push_at"],
        unique=False,
        postgresql_where=sa.text("push_status = 'PENDING'"),
    )
    op.create_unique_constraint(
        op.f("uq_notifications_dedupe_key"), "notifications", ["dedupe_key"]
    )


def downgrade() -> None:
    op.drop_constraint(op.f("uq_notifications_dedupe_key"), "notifications", type_="unique")
    op.drop_index(
        "ix_notifications_push_pending",
        table_name="notifications",
        postgresql_where=sa.text("push_status = 'PENDING'"),
    )
    op.drop_column("notifications", "push_error")
    op.drop_column("notifications", "pushed_at")
    op.drop_column("notifications", "next_push_at")
    op.drop_column("notifications", "push_attempts")
    op.drop_constraint(op.f("ck_notifications_push_status"), "notifications", type_="check")
    op.drop_column("notifications", "push_status")
    op.drop_column("notifications", "dedupe_key")
    op.drop_index(op.f("ix_device_tokens_user_id"), table_name="device_tokens")
    op.drop_table("device_tokens")
