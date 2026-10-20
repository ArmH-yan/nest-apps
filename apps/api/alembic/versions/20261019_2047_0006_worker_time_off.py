"""worker time off

Revision ID: 0006
Revises: 0005
Create Date: 2026-10-19 20:47:25.592280+00:00

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0006"
down_revision: str | None = "0005"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "worker_time_off",
        sa.Column("id", sa.BigInteger(), sa.Identity(always=False), nullable=False),
        sa.Column("worker_id", sa.BigInteger(), nullable=False),
        sa.Column("period", postgresql.TSTZRANGE(), nullable=False),
        sa.Column(
            "reason",
            sa.String(length=16),
            nullable=False,
        ),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("created_by", sa.BigInteger(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        postgresql.ExcludeConstraint(
            (sa.column("worker_id"), "="),
            (sa.column("period"), "&&"),
            using="gist",
            name="no_time_off_overlap",
        ),
        sa.CheckConstraint(
            "reason IN ('VACATION', 'SICK', 'OTHER')",
            name=op.f("ck_worker_time_off_time_off_reason"),
        ),
        sa.ForeignKeyConstraint(
            ["created_by"], ["users.id"], name=op.f("fk_worker_time_off_created_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["worker_id"], ["workers.id"], name=op.f("fk_worker_time_off_worker_id_workers")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_worker_time_off")),
    )
    op.create_index(
        op.f("ix_worker_time_off_worker_id"), "worker_time_off", ["worker_id"], unique=False
    )


def downgrade() -> None:
    op.drop_index(op.f("ix_worker_time_off_worker_id"), table_name="worker_time_off")
    op.drop_table("worker_time_off")
