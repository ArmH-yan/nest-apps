"""Imports every module's models so `Base.metadata` is complete for Alembic.

Add one import line per module as models are created.
"""

from app.db import references  # noqa: F401
from app.db.base import Base
from app.modules.audit import models as audit_models  # noqa: F401
from app.modules.auth import models as auth_models  # noqa: F401
from app.modules.companies import models as companies_models  # noqa: F401
from app.modules.files import models as files_models  # noqa: F401
from app.modules.materials import models as materials_models  # noqa: F401
from app.modules.notifications import models as notifications_models  # noqa: F401
from app.modules.projects import models as projects_models  # noqa: F401
from app.modules.scheduling import models as scheduling_models  # noqa: F401
from app.modules.settings import models as settings_models  # noqa: F401
from app.modules.sites import models as sites_models  # noqa: F401
from app.modules.timetracking import models as timetracking_models  # noqa: F401
from app.modules.users import models as users_models  # noqa: F401
from app.modules.workers import models as workers_models  # noqa: F401

__all__ = ["Base"]
