"""Imports every module's models so `Base.metadata` is complete for Alembic.

Add one import line per module as models are created.
"""

from app.db.base import Base
from app.modules.audit import models as audit_models  # noqa: F401
from app.modules.auth import models as auth_models  # noqa: F401
from app.modules.users import models as users_models  # noqa: F401

__all__ = ["Base"]
