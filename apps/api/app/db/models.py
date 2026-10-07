"""Imports every module's models so `Base.metadata` is complete for Alembic.

Add one import line per module as models are created, e.g.:
    from app.modules.users import models as users_models  # noqa: F401
"""

from app.db.base import Base

__all__ = ["Base"]
