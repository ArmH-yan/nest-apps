"""Photo uploads: presign → PUT to storage → confirm (ARCHITECTURE §23, §24). Each step
is safe to repeat, so the app can resume an interrupted upload."""

import uuid
from http import HTTPStatus

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.errors import AppError
from app.core.time import utcnow
from app.db.crud import not_found
from app.modules.files.models import File, FileOwner, FileStatus
from app.modules.files.storage import PresignedUpload, Storage
from app.modules.worker_api.access import ensure_writable, own_task
from app.modules.worker_api.dependencies import WorkerContext
from app.modules.worker_api.schemas import PresignIn

_EXTENSIONS = {"image/jpeg": "jpg", "image/png": "png", "image/heic": "heic", "image/webp": "webp"}


def _too_large(size: int) -> AppError:
    return AppError(
        "FILE_TOO_LARGE",
        "The photo is too large.",
        status_code=HTTPStatus.UNPROCESSABLE_ENTITY,
        details={"max_bytes": get_settings().max_upload_bytes, "size_bytes": size},
    )


async def presign_photo(
    session: AsyncSession, storage: Storage, me: WorkerContext, file_id: uuid.UUID, body: PresignIn
) -> tuple[PresignedUpload, bool]:
    """Returns the upload URL and whether the file was already confirmed."""
    if body.size_bytes > get_settings().max_upload_bytes:
        raise _too_large(body.size_bytes)
    existing = await session.get(File, file_id)
    if existing is not None:
        if existing.uploaded_by != me.user.id or existing.owner_id != body.task_id:
            raise not_found("file")
        # replay: a fresh URL for the same key (the old one may have expired)
        upload = storage.presign_put(existing.storage_key, existing.mime_type)
        return upload, existing.status is FileStatus.UPLOADED

    ctx = await own_task(session, me.worker.id, body.task_id)
    ensure_writable(ctx)
    key = f"assignments/{ctx.assignment.id}/{file_id}.{_EXTENSIONS[body.mime_type]}"
    session.add(
        File(
            id=file_id,
            owner_type=FileOwner.ASSIGNMENT,
            owner_id=ctx.assignment.id,
            kind=body.kind,
            storage_key=key,
            mime_type=body.mime_type,
            size_bytes=body.size_bytes,
            taken_at=body.taken_at,
            latitude=body.latitude,
            longitude=body.longitude,
            uploaded_by=me.user.id,
        )
    )
    await session.commit()
    return storage.presign_put(key, body.mime_type), False


async def confirm_photo(
    session: AsyncSession, storage: Storage, me: WorkerContext, file_id: uuid.UUID
) -> File:
    file = await session.get(File, file_id)
    if file is None or file.uploaded_by != me.user.id:
        raise not_found("file")
    if file.status is FileStatus.UPLOADED:
        return file
    stored = await storage.head(file.storage_key)
    if stored is None:
        raise AppError(
            "FILE_NOT_UPLOADED",
            "The photo has not reached storage yet. Upload it again.",
            status_code=HTTPStatus.CONFLICT,
        )
    if stored.size_bytes > get_settings().max_upload_bytes:
        raise _too_large(stored.size_bytes)
    file.size_bytes = stored.size_bytes
    file.status = FileStatus.UPLOADED
    file.uploaded_at = utcnow()
    await session.commit()
    return file
