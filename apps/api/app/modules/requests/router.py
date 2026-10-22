from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Header, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.requests import service
from app.modules.requests.models import RequestStatus
from app.modules.requests.schemas import (
    ConvertIn,
    ManualRequestIn,
    PublicRequestIn,
    PublicRequestOut,
    RejectIn,
    RequestCountsOut,
    RequestOut,
    RequestPatch,
)

router = APIRouter(tags=["requests"])
Session = Annotated[AsyncSession, Depends(get_session)]


@router.post("/public/assessment-requests", status_code=HTTPStatus.CREATED)
async def submit(
    body: PublicRequestIn,
    session: Session,
    x_service_key: Annotated[str | None, Header()] = None,
) -> PublicRequestOut:
    """nest_web's contact form (§12), server to server with `X-Service-Key`."""
    service.check_service_key(x_service_key)
    request = await service.submit_public(session, body)
    return PublicRequestOut(reference=request.reference)


@router.get("/assessment-requests")
async def list_requests(
    _: ManagerAuth,
    session: Session,
    status: Annotated[list[RequestStatus] | None, Query()] = None,
    q: str | None = None,
    limit: Annotated[int, Query(ge=1, le=200)] = 100,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> list[RequestOut]:
    rows = await service.list_requests(session, statuses=status, q=q, limit=limit, offset=offset)
    return [RequestOut.model_validate(r) for r in rows]


@router.get("/assessment-requests/counts")
async def request_counts(_: ManagerAuth, session: Session) -> RequestCountsOut:
    return await service.counts(session)


@router.post("/assessment-requests", status_code=HTTPStatus.CREATED)
async def create_request(body: ManualRequestIn, auth: ManagerAuth, session: Session) -> RequestOut:
    """A lead taken by phone or in person."""
    return RequestOut.model_validate(await service.create_manual(session, body, auth.user))


@router.get("/assessment-requests/{request_id}")
async def get_request(request_id: int, _: ManagerAuth, session: Session) -> RequestOut:
    return RequestOut.model_validate(await service.get_request(session, request_id))


@router.patch("/assessment-requests/{request_id}")
async def update_request(
    request_id: int, body: RequestPatch, auth: ManagerAuth, session: Session
) -> RequestOut:
    return RequestOut.model_validate(
        await service.update_request(session, request_id, body, auth.user)
    )


@router.post("/assessment-requests/{request_id}/reject")
async def reject(
    request_id: int, body: RejectIn, auth: ManagerAuth, session: Session
) -> RequestOut:
    return RequestOut.model_validate(await service.reject(session, request_id, body, auth.user))


@router.post("/assessment-requests/{request_id}/convert")
async def convert(
    request_id: int, body: ConvertIn, auth: ManagerAuth, session: Session
) -> RequestOut:
    """Creates or links company, contact, site and project in one transaction (§9)."""
    return RequestOut.model_validate(await service.convert(session, request_id, body, auth.user))
