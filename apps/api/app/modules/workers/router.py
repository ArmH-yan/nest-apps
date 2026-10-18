from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.workers import service
from app.modules.workers.schemas import ResetPasswordIn, WorkerIn, WorkerOut, WorkerPatch

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
