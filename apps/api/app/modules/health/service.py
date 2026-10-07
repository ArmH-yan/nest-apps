import logging
from http import HTTPStatus

from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError

logger = logging.getLogger(__name__)


async def check_database(session: AsyncSession) -> None:
    """Raise `DATABASE_UNAVAILABLE` (503) if PostgreSQL cannot answer a trivial query."""
    try:
        await session.execute(text("SELECT 1"))
    except (SQLAlchemyError, OSError) as exc:
        logger.warning("Database health check failed: %s", exc)
        raise AppError(
            "DATABASE_UNAVAILABLE",
            "The database is not reachable.",
            status_code=HTTPStatus.SERVICE_UNAVAILABLE,
        ) from exc
