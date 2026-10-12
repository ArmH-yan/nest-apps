from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.crud import get_or_404
from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.companies import service
from app.modules.companies.models import Company
from app.modules.companies.schemas import (
    CompanyIn,
    CompanyOut,
    CompanyPatch,
    ContactIn,
    ContactOut,
    ContactPatch,
)

router = APIRouter(tags=["companies"])
Session = Annotated[AsyncSession, Depends(get_session)]
Limit = Annotated[int, Query(ge=1, le=200)]


@router.post("/companies", status_code=HTTPStatus.CREATED)
async def create_company(body: CompanyIn, _: ManagerAuth, session: Session) -> CompanyOut:
    return CompanyOut.model_validate(await service.create_company(session, body))


@router.get("/companies")
async def list_companies(
    _: ManagerAuth, session: Session, q: str | None = None, limit: Limit = 50, offset: int = 0
) -> list[CompanyOut]:
    rows = await service.list_companies(session, q, limit, offset)
    return [CompanyOut.model_validate(c) for c in rows]


@router.get("/companies/{company_id}")
async def get_company(company_id: int, _: ManagerAuth, session: Session) -> CompanyOut:
    return CompanyOut.model_validate(await get_or_404(session, Company, company_id, "company"))


@router.patch("/companies/{company_id}")
async def update_company(
    company_id: int, body: CompanyPatch, _: ManagerAuth, session: Session
) -> CompanyOut:
    return CompanyOut.model_validate(await service.update_company(session, company_id, body))


@router.post("/contacts", status_code=HTTPStatus.CREATED)
async def create_contact(body: ContactIn, _: ManagerAuth, session: Session) -> ContactOut:
    return ContactOut.model_validate(await service.create_contact(session, body))


@router.get("/contacts")
async def list_contacts(
    _: ManagerAuth,
    session: Session,
    company_id: int | None = None,
    limit: Limit = 50,
    offset: int = 0,
) -> list[ContactOut]:
    rows = await service.list_contacts(session, company_id, limit, offset)
    return [ContactOut.model_validate(c) for c in rows]


@router.patch("/contacts/{contact_id}")
async def update_contact(
    contact_id: int, body: ContactPatch, _: ManagerAuth, session: Session
) -> ContactOut:
    return ContactOut.model_validate(await service.update_contact(session, contact_id, body))
