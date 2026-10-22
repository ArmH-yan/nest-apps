"""`/api/v1/worker/*` (ARCHITECTURE §18). Scoped to the signed-in worker; another
worker's object is a 404. PUTs are idempotent by client UUID (safe to replay)."""

import re
import uuid
from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Path, Query, Response
from pydantic import AwareDatetime
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.db.session import get_session
from app.modules.files import service as files
from app.modules.files.storage import Storage, get_storage
from app.modules.materials import service as materials
from app.modules.notifications import service as notifications
from app.modules.push import service as push
from app.modules.timetracking import service as timetracking
from app.modules.worker_api import service
from app.modules.worker_api.access import own_task
from app.modules.worker_api.dependencies import CurrentWorker
from app.modules.worker_api.schemas import (
    CatalogItemOut,
    CompletionIn,
    CompletionOut,
    DeviceIn,
    EarningsOut,
    ExpectedMaterialOut,
    FileOut,
    HistoryPageOut,
    LocationCheckIn,
    LocationCheckOut,
    MaterialMovementIn,
    MaterialMovementOut,
    NotificationPageOut,
    PresignIn,
    PresignOut,
    TaskOut,
    TimeEntryIn,
    TimeEntryOut,
    WorkerConfigOut,
)

router = APIRouter(prefix="/worker", tags=["worker"])
Session = Annotated[AsyncSession, Depends(get_session)]
StorageDep = Annotated[Storage, Depends(get_storage)]
_MONTH = re.compile(r"^(\d{4})-(0[1-9]|1[0-2])$")


@router.get("/config")
async def config(_: CurrentWorker, session: Session) -> WorkerConfigOut:
    return await service.config(session)


@router.get("/tasks")
async def tasks(
    me: CurrentWorker,
    session: Session,
    from_: Annotated[AwareDatetime, Query(alias="from")],
    to: AwareDatetime,
) -> list[TaskOut]:
    if (to - from_).days > 62:
        raise AppError("RANGE_TOO_LARGE", "Ask for at most two months at a time.")
    return await service.tasks(session, me.worker.id, from_, to)


@router.get("/tasks/{task_id}")
async def task(task_id: int, me: CurrentWorker, session: Session) -> TaskOut:
    return await service.task(session, me.worker.id, task_id)


@router.get("/tasks/{task_id}/expected-materials")
async def expected_materials(
    task_id: int, me: CurrentWorker, session: Session
) -> list[ExpectedMaterialOut]:
    return await service.expected_materials(session, me.worker.id, task_id, me.user.locale.value)


@router.get("/catalog")
async def catalog(me: CurrentWorker, session: Session) -> list[CatalogItemOut]:
    return await service.catalog(session, me.user.locale.value)


@router.put("/location-checks/{check_id}")
async def put_location_check(
    check_id: uuid.UUID, body: LocationCheckIn, me: CurrentWorker, session: Session
) -> LocationCheckOut:
    check = await timetracking.put_location_check(session, me, check_id, body)
    ctx = await own_task(session, me.worker.id, check.assignment_id)
    return LocationCheckOut(
        id=check.id,
        server_distance_m=check.server_distance_m,
        radius_m=check.radius_m,
        server_verified=check.server_verified,
        review_flags=list(ctx.assignment.review_flags),
    )


@router.put("/time-entries/{entry_id}")
async def put_time_entry(
    entry_id: uuid.UUID, body: TimeEntryIn, me: CurrentWorker, session: Session
) -> TimeEntryOut:
    entry, status = await timetracking.put_time_entry(session, me, entry_id, body)
    return TimeEntryOut(
        id=entry.id,
        task_id=entry.assignment_id,
        kind=entry.kind,
        started_at=entry.started_at,
        ended_at=entry.ended_at,
        task_status=status,
    )


@router.put("/material-movements/{movement_id}")
async def put_material_movement(
    movement_id: uuid.UUID, body: MaterialMovementIn, me: CurrentWorker, session: Session
) -> MaterialMovementOut:
    m = await materials.put_movement(session, me, movement_id, body)
    assert m.assignment_id is not None  # noqa: S101 — worker movements always have one
    return MaterialMovementOut(
        id=m.id,
        task_id=m.assignment_id,
        catalog_item_id=m.catalog_item_id,
        quantity=m.quantity,
        movement=m.movement,
    )


@router.post("/files/{file_id}/presign")
async def presign_file(
    file_id: uuid.UUID, body: PresignIn, me: CurrentWorker, session: Session, storage: StorageDep
) -> PresignOut:
    upload, done = await files.presign_photo(session, storage, me, file_id, body)
    return PresignOut(
        upload_url=upload.url,
        headers=upload.headers,
        expires_at=upload.expires_at,
        already_uploaded=done,
    )


@router.post("/files/{file_id}/confirm")
async def confirm_file(
    file_id: uuid.UUID, me: CurrentWorker, session: Session, storage: StorageDep
) -> FileOut:
    file = await files.confirm_photo(session, storage, me, file_id)
    return FileOut(id=file.id, status=file.status.value, size_bytes=file.size_bytes)


@router.put("/tasks/{task_id}/completion/{completion_id}")
async def put_completion(
    task_id: int,
    completion_id: uuid.UUID,
    body: CompletionIn,
    me: CurrentWorker,
    session: Session,
) -> CompletionOut:
    completion, ctx = await timetracking.put_completion(session, me, task_id, completion_id, body)
    return CompletionOut(
        id=completion.id,
        task_id=task_id,
        task_status=ctx.assignment.status,
        work_seconds=completion.work_seconds,
        break_seconds=completion.break_seconds,
        review_flags=list(ctx.assignment.review_flags),
    )


@router.get("/history")
async def history(
    me: CurrentWorker,
    session: Session,
    cursor: int | None = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 30,
) -> HistoryPageOut:
    return await service.history(session, me.worker.id, cursor, limit)


@router.get("/earnings")
async def earnings(
    me: CurrentWorker, session: Session, month: Annotated[str, Query(pattern=_MONTH.pattern)]
) -> EarningsOut:
    match = _MONTH.match(month)
    assert match is not None  # noqa: S101 — validated by the Query pattern
    return await service.earnings(session, me.worker.id, int(match[1]), int(match[2]))


@router.get("/notifications")
async def list_notifications(
    me: CurrentWorker,
    session: Session,
    cursor: int | None = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 50,
) -> NotificationPageOut:
    return await service.notification_page(session, me.user.id, cursor, limit)


@router.post("/notifications/{notification_id}/read", status_code=HTTPStatus.NO_CONTENT)
async def read_notification(notification_id: int, me: CurrentWorker, session: Session) -> Response:
    await notifications.mark_read(session, me.user.id, notification_id)
    return Response(status_code=HTTPStatus.NO_CONTENT)


FcmToken = Annotated[str, Path(min_length=20, max_length=4096)]


@router.put("/devices/{fcm_token}", status_code=HTTPStatus.NO_CONTENT)
async def register_device(
    fcm_token: FcmToken, body: DeviceIn, me: CurrentWorker, session: Session
) -> Response:
    """Idempotent: the app calls it at every start and when FCM rotates the token."""
    await push.register_device(session, me.user.id, fcm_token, body.platform, body.app_version)
    return Response(status_code=HTTPStatus.NO_CONTENT)


@router.delete("/devices/{fcm_token}", status_code=HTTPStatus.NO_CONTENT)
async def unregister_device(fcm_token: FcmToken, me: CurrentWorker, session: Session) -> Response:
    """Called by the app before logout, so the next person on the phone gets no pushes."""
    await push.unregister_device(session, me.user.id, fcm_token)
    return Response(status_code=HTTPStatus.NO_CONTENT)
