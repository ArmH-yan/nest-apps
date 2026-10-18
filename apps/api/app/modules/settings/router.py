from typing import Annotated

from fastapi import APIRouter, Depends
from pydantic import BaseModel, ConfigDict
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.settings.models import Service

router = APIRouter(tags=["settings"])


class ServiceOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    slug: str
    name_hy: str
    name_ru: str
    name_en: str


@router.get("/services")
async def list_services(
    _: ManagerAuth, session: Annotated[AsyncSession, Depends(get_session)]
) -> list[ServiceOut]:
    """Services offered (slugs match the website, CLAUDE.md)."""
    rows = await session.scalars(select(Service).where(Service.is_active).order_by(Service.id))
    return [ServiceOut.model_validate(s) for s in rows]
