"""`CurrentWorker`: the signed-in worker for `/worker/*` (ARCHITECTURE §18, §30)."""

from dataclasses import dataclass
from datetime import datetime
from http import HTTPStatus
from typing import Annotated

from fastapi import Depends, Header
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.time import utcnow
from app.db.session import get_session
from app.modules.auth.dependencies import AuthContext, require_roles
from app.modules.users.models import User, UserRole, Worker
from app.modules.users.service import get_worker_for_user


@dataclass(frozen=True)
class WorkerContext:
    user: User
    worker: Worker
    # server_now - device_now in seconds, from X-Device-Time; None if not sent/invalid
    clock_offset_s: int | None


def _clock_offset(device_time: str | None) -> int | None:
    if not device_time:
        return None
    try:
        parsed = datetime.fromisoformat(device_time)
    except ValueError:
        return None
    if parsed.tzinfo is None:
        return None
    return round((utcnow() - parsed).total_seconds())


async def _current_worker(
    auth: Annotated[AuthContext, Depends(require_roles(UserRole.WORKER))],
    session: Annotated[AsyncSession, Depends(get_session)],
    x_device_time: Annotated[str | None, Header()] = None,
) -> WorkerContext:
    worker = await get_worker_for_user(session, auth.user.id)
    if worker is None or not worker.is_active:
        raise AppError(
            "ACCOUNT_DISABLED",
            "This worker profile is not active.",
            status_code=HTTPStatus.FORBIDDEN,
        )
    return WorkerContext(auth.user, worker, _clock_offset(x_device_time))


CurrentWorker = Annotated[WorkerContext, Depends(_current_worker)]
