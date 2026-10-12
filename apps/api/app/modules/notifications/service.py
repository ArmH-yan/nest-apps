"""In-app notifications (ARCHITECTURE §26). Rows are added in the same transaction as
the change that causes them. Push delivery (FCM) is added in Phase 3 and will read
these rows; nothing else changes then."""

from typing import Any

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.time import utcnow
from app.db.crud import not_found
from app.modules.notifications.models import Notification, NotificationType
from app.modules.notifications.templates import render
from app.modules.users.models import User, Worker


async def notify_worker(
    session: AsyncSession,
    worker_id: int,
    type_: NotificationType,
    *,
    data: dict[str, Any],
    **params: str,
) -> None:
    """Adds a notification for the worker's user, in the user's language."""
    row = (
        await session.execute(
            select(User.id, User.locale)
            .join(Worker, Worker.user_id == User.id)
            .where(Worker.id == worker_id)
        )
    ).first()
    if row is None:
        return
    title, body = render(type_, row.locale.value, **params)
    session.add(Notification(user_id=row.id, type=type_, title=title, body=body, data=data))


async def list_for_user(
    session: AsyncSession, user_id: int, before_id: int | None, limit: int
) -> list[Notification]:
    stmt = (
        select(Notification)
        .where(Notification.user_id == user_id)
        .order_by(Notification.id.desc())
        .limit(limit)
    )
    if before_id is not None:
        stmt = stmt.where(Notification.id < before_id)
    return list(await session.scalars(stmt))


async def mark_read(session: AsyncSession, user_id: int, notification_id: int) -> None:
    result = await session.execute(
        update(Notification)
        .where(Notification.id == notification_id, Notification.user_id == user_id)
        .where(Notification.read_at.is_(None))
        .values(read_at=utcnow())
        .returning(Notification.id)
    )
    if result.first() is None:
        # already read is fine; someone else's (or missing) is 404
        exists = await session.scalar(
            select(Notification.id).where(
                Notification.id == notification_id, Notification.user_id == user_id
            )
        )
        if exists is None:
            raise not_found("notification")
    await session.commit()
