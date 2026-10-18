import uuid
from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Query, Response
from pydantic import AwareDatetime
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.files.storage import Storage, get_storage
from app.modules.timesheets import service
from app.modules.timesheets.schemas import AdjustIn, OverrideIn, TimesheetDetailOut, TimesheetRowOut

router = APIRouter(tags=["timesheets"])
Session = Annotated[AsyncSession, Depends(get_session)]
From = Annotated[AwareDatetime, Query(alias="from")]


@router.get("/timesheets")
async def list_timesheets(
    _: ManagerAuth,
    session: Session,
    from_: From,
    to: AwareDatetime,
    worker_id: int | None = None,
    flagged: bool | None = None,
    reviewed: bool | None = None,
) -> list[TimesheetRowOut]:
    return await service.list_timesheets(
        session, start=from_, end=to, worker_id=worker_id, flagged=flagged, reviewed=reviewed
    )


@router.get("/timesheets/export.csv")
async def export_csv(_: ManagerAuth, session: Session, from_: From, to: AwareDatetime) -> Response:
    body = await service.export_csv(session, from_, to)
    name = f"nest-timesheets-{from_.date()}-{to.date()}.csv"
    # BOM so Excel opens Armenian/Russian names correctly
    return Response(
        content="﻿" + body,
        media_type="text/csv; charset=utf-8",
        headers={"Content-Disposition": f'attachment; filename="{name}"'},
    )


@router.get("/timesheets/assignments/{assignment_id}")
async def get_timesheet(
    assignment_id: int,
    _: ManagerAuth,
    session: Session,
    storage: Annotated[Storage, Depends(get_storage)],
) -> TimesheetDetailOut:
    return await service.detail(session, storage, assignment_id)


@router.post("/timesheets/assignments/{assignment_id}/approve", status_code=HTTPStatus.NO_CONTENT)
async def approve(assignment_id: int, auth: ManagerAuth, session: Session) -> Response:
    await service.approve(session, assignment_id, auth.user)
    return Response(status_code=HTTPStatus.NO_CONTENT)


@router.post("/timesheets/assignments/{assignment_id}/adjust", status_code=HTTPStatus.NO_CONTENT)
async def adjust(
    assignment_id: int, body: AdjustIn, auth: ManagerAuth, session: Session
) -> Response:
    await service.adjust(session, assignment_id, body, auth.user)
    return Response(status_code=HTTPStatus.NO_CONTENT)


@router.post("/location-checks/{check_id}/override", status_code=HTTPStatus.NO_CONTENT)
async def override_location(
    check_id: uuid.UUID, body: OverrideIn, auth: ManagerAuth, session: Session
) -> Response:
    await service.override_location(session, check_id, body.reason, auth.user)
    return Response(status_code=HTTPStatus.NO_CONTENT)
