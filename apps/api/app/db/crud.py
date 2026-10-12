"""Small helpers shared by services."""

from http import HTTPStatus
from typing import Any

from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.db.base import Base


def not_found(entity: str) -> AppError:
    return AppError(
        "NOT_FOUND",
        f"The {entity} was not found.",
        status_code=HTTPStatus.NOT_FOUND,
        details={"entity": entity},
    )


async def get_or_404[M: Base](session: AsyncSession, model: type[M], id_: Any, entity: str) -> M:
    obj = await session.get(model, id_)
    if obj is None:
        raise not_found(entity)
    return obj


def apply_patch(obj: Base, patch: BaseModel, exclude: set[str] | None = None) -> dict[str, Any]:
    """Copies the fields the client actually sent (minus `exclude`, which the caller
    handles itself). Returns them, e.g. for the audit log."""
    changes = patch.model_dump(exclude_unset=True, exclude=exclude)
    for name, value in changes.items():
        setattr(obj, name, value)
    return changes
