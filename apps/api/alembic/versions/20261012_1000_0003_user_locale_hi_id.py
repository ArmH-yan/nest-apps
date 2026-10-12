"""users.locale: add Hindi (hi) and Indonesian (id)

Revision ID: 0003
Revises: 0002
Create Date: 2026-10-12 10:00:00

"""

from collections.abc import Sequence

from alembic import op

revision: str = "0003"
down_revision: str | None = "0002"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.drop_constraint(op.f("ck_users_user_locale"), "users", type_="check")
    op.create_check_constraint(
        op.f("ck_users_user_locale"), "users", "locale IN ('hy', 'ru', 'en', 'hi', 'id')"
    )


def downgrade() -> None:
    op.execute("UPDATE users SET locale = 'en' WHERE locale IN ('hi', 'id')")
    op.drop_constraint(op.f("ck_users_user_locale"), "users", type_="check")
    op.create_check_constraint(
        op.f("ck_users_user_locale"), "users", "locale IN ('hy', 'ru', 'en')"
    )
