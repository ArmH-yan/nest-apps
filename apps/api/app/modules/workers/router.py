from datetime import date
from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.workers import service
from app.modules.workers.schemas import (
    ResetPasswordIn,
    TimeOffIn,
    TimeOffOut,
    WorkerIn,
    WorkerOut,
    WorkerPatch,
)

router = APIRouter(prefix="/workers", tags=["workers"])
Session = Annotated[AsyncSession, Depends(get_session)]


@router.get("")
async def list_workers(
    _: ManagerAuth, session: Session, q: str | None = None, active: bool | None = None
) -> list[WorkerOut]:
    return await service.list_workers(session, q=q, active=active)


@router.post("", status_code=HTTPStatus.CREATED)
async def create_worker(body: WorkerIn, auth: ManagerAuth, session: Session) -> WorkerOut:
    return await service.create_worker(session, body, auth.user)


# /time-off routes come before /{worker_id} so "time-off" isn't read as an id


@router.get("/time-off")
async def all_time_off(
    _: ManagerAuth,
    session: Session,
    from_: Annotated[date, Query(alias="from")],
    to: date,
) -> list[TimeOffOut]:
    """Every worker's time off overlapping [from, to] (Yerevan dates, inclusive),
    for the planning timeline and the crew editor's warnings (§14)."""
    if to < from_:
        raise AppError("VALIDATION_ERROR", "`to` must not be before `from`.", status_code=422)
    return await service.list_time_off(session, worker_id=None, start=from_, end=to)


@router.delete("/time-off/{time_off_id}", status_code=HTTPStatus.NO_CONTENT)
async def delete_time_off(time_off_id: int, auth: ManagerAuth, session: Session) -> Response:
    await service.delete_time_off(session, time_off_id, auth.user)
    return Response(status_code=HTTPStatus.NO_CONTENT)


@router.get("/{worker_id}")
async def get_worker(worker_id: int, _: ManagerAuth, session: Session) -> WorkerOut:
    return await service.get_worker(session, worker_id)


@router.patch("/{worker_id}")
async def update_worker(
    worker_id: int, body: WorkerPatch, auth: ManagerAuth, session: Session
) -> WorkerOut:
    return await service.update_worker(session, worker_id, body, auth.user)


@router.post("/{worker_id}/reset-password", status_code=HTTPStatus.NO_CONTENT)
async def reset_password(
    worker_id: int, body: ResetPasswordIn, auth: ManagerAuth, session: Session
) -> Response:
    await service.reset_password(session, worker_id, body.new_password, auth.user)
    return Response(status_code=HTTPStatus.NO_CONTENT)


@router.get("/{worker_id}/time-off")
async def worker_time_off(worker_id: int, _: ManagerAuth, session: Session) -> list[TimeOffOut]:
    return await service.list_time_off(session, worker_id=worker_id, start=None, end=None)


@router.post("/{worker_id}/time-off", status_code=HTTPStatus.CREATED)
async def create_time_off(
    worker_id: int, body: TimeOffIn, auth: ManagerAuth, session: Session
) -> TimeOffOut:
    return await service.create_time_off(session, worker_id, body, auth.user)
