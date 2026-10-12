from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.crud import get_or_404
from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.sites import service
from app.modules.sites.models import Site
from app.modules.sites.schemas import SiteIn, SiteOut, SitePatch

router = APIRouter(prefix="/sites", tags=["sites"])
Session = Annotated[AsyncSession, Depends(get_session)]


@router.post("", status_code=HTTPStatus.CREATED)
async def create_site(body: SiteIn, auth: ManagerAuth, session: Session) -> SiteOut:
    return SiteOut.model_validate(await service.create_site(session, body, auth.user.id))


@router.get("")
async def list_sites(
    _: ManagerAuth,
    session: Session,
    company_id: int | None = None,
    q: str | None = None,
    limit: Annotated[int, Query(ge=1, le=200)] = 50,
    offset: int = 0,
) -> list[SiteOut]:
    rows = await service.list_sites(session, company_id, q, limit, offset)
    return [SiteOut.model_validate(s) for s in rows]


@router.get("/{site_id}")
async def get_site(site_id: int, _: ManagerAuth, session: Session) -> SiteOut:
    return SiteOut.model_validate(await get_or_404(session, Site, site_id, "site"))


@router.patch("/{site_id}")
async def update_site(
    site_id: int, body: SitePatch, auth: ManagerAuth, session: Session
) -> SiteOut:
    return SiteOut.model_validate(await service.update_site(session, site_id, body, auth.user.id))
