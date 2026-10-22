"""Push delivery and task reminders (ARCHITECTURE §26, §37).

The `notifications` table is the queue: a business change inserts a PENDING row in
its own transaction (`notifications.service.notify_worker`), and the push worker
(`python -m app.cli push-worker`) delivers it. Rows are claimed with
`FOR UPDATE SKIP LOCKED`, so two workers never send the same push.

Reminders (§26 "evening before / morning of"):
- `tomorrow`: from 19:00 Yerevan, for tasks that start tomorrow and were assigned
  before 19:00 (later assignments were just announced by TASK_ASSIGNED);
- `soon`: 1 hour before the visit starts.
Both only for tasks still ASSIGNED on a PLANNED visit, and each exists once per
task and start time (`dedupe_key`), so a rescheduled visit is reminded again.
"""

import logging
from datetime import datetime, time, timedelta

from sqlalchemy import delete, func, select
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.time import YEREVAN, utcnow
from app.modules.notifications.models import Notification, NotificationType, PushStatus
from app.modules.notifications.templates import reminder_when, render
from app.modules.push.models import DeviceToken, Platform
from app.modules.push.sender import Outcome, PushMessage, PushSender
from app.modules.scheduling.models import (
    AssignmentStatus,
    Job,
    JobVisit,
    VisitAssignment,
    VisitStatus,
)
from app.modules.sites.models import Site
from app.modules.users.models import User, Worker

log = logging.getLogger(__name__)

BATCH = 50
MAX_ATTEMPTS = 5
STALE = timedelta(hours=12)  # an old notification is not worth a buzz any more
EVENING = time(19, 0)
SOON = timedelta(hours=1)


# --- devices -------------------------------------------------------------------------


async def register_device(
    session: AsyncSession, user_id: int, token: str, platform: Platform, app_version: str | None
) -> None:
    """Idempotent. A token moves to whoever logged in on that phone last."""
    stmt = insert(DeviceToken).values(
        user_id=user_id, fcm_token=token, platform=platform, app_version=app_version
    )
    await session.execute(
        stmt.on_conflict_do_update(
            index_elements=[DeviceToken.fcm_token],
            set_={
                "user_id": user_id,
                "platform": stmt.excluded.platform,
                "app_version": stmt.excluded.app_version,
                "last_seen_at": func.now(),
            },
        )
    )
    await session.commit()


async def unregister_device(session: AsyncSession, user_id: int, token: str) -> None:
    """Idempotent; only the caller's own token."""
    await session.execute(
        delete(DeviceToken).where(DeviceToken.fcm_token == token, DeviceToken.user_id == user_id)
    )
    await session.commit()


async def forget_devices(session: AsyncSession, user_id: int) -> None:
    """A deactivated user gets no more pushes. The caller commits."""
    await session.execute(delete(DeviceToken).where(DeviceToken.user_id == user_id))


# --- delivery ------------------------------------------------------------------------


def _data(n: Notification) -> dict[str, str]:
    return {
        "notification_id": str(n.id),
        "type": n.type.value,
        **{key: str(value) for key, value in n.data.items()},
    }


async def deliver_pending(
    session: AsyncSession, sender: PushSender, now: datetime | None = None
) -> int:
    """Sends up to BATCH due notifications. Returns how many were handled."""
    now = now or utcnow()
    batch = list(
        await session.scalars(
            select(Notification)
            .where(Notification.push_status == PushStatus.PENDING, Notification.next_push_at <= now)
            .order_by(Notification.id)
            .limit(BATCH)
            .with_for_update(skip_locked=True)
        )
    )
    for n in batch:
        await _deliver_one(session, sender, n, now)
    await session.commit()
    return len(batch)


async def _deliver_one(
    session: AsyncSession, sender: PushSender, n: Notification, now: datetime
) -> None:
    if n.created_at < now - STALE:
        n.push_status, n.push_error = PushStatus.SKIPPED, "stale"
        return
    devices = list(
        await session.scalars(select(DeviceToken).where(DeviceToken.user_id == n.user_id))
    )
    outcomes = []
    errors = []
    for device in devices:
        result = await sender.send(PushMessage(device.fcm_token, n.title, n.body, _data(n)))
        outcomes.append(result.outcome)
        if result.error:
            errors.append(result.error)
        if result.outcome is Outcome.UNREGISTERED:
            await session.delete(device)
    n.push_error = "; ".join(errors)[:1000] or None
    if Outcome.OK in outcomes:
        n.push_status, n.pushed_at = PushStatus.SENT, now
    elif Outcome.RETRY in outcomes:
        n.push_attempts += 1
        if n.push_attempts >= MAX_ATTEMPTS:
            n.push_status = PushStatus.FAILED
        else:
            n.next_push_at = now + timedelta(seconds=30 * 2**n.push_attempts)
    elif Outcome.REJECTED in outcomes:
        n.push_status = PushStatus.FAILED
    else:  # no device, or every token was dead
        n.push_status = PushStatus.SKIPPED
        n.push_error = n.push_error or "no device"


# --- reminders -----------------------------------------------------------------------


async def create_reminders(session: AsyncSession, now: datetime | None = None) -> int:
    """Adds the reminders that are due now. Idempotent. Returns how many were added."""
    now = now or utcnow()
    local = now.astimezone(YEREVAN)
    lower = func.lower(VisitAssignment.period)
    windows: list[tuple[str, datetime, datetime, datetime | None]] = [
        ("soon", now, now + SOON, None)
    ]
    if local.time() >= EVENING:
        tomorrow = local.date() + timedelta(days=1)
        windows.append(
            (
                "tomorrow",
                datetime.combine(tomorrow, time(), YEREVAN),
                datetime.combine(tomorrow + timedelta(days=1), time(), YEREVAN),
                datetime.combine(local.date(), EVENING, YEREVAN),  # assigned before this
            )
        )
    added = 0
    for kind, start, end, assigned_before in windows:
        stmt = (
            select(VisitAssignment, Job.title, Site.name, User.id, User.locale)
            .join(JobVisit, JobVisit.id == VisitAssignment.visit_id)
            .join(Job, Job.id == JobVisit.job_id)
            .join(Site, Site.id == Job.site_id)
            .join(Worker, Worker.id == VisitAssignment.worker_id)
            .join(User, User.id == Worker.user_id)
            .where(
                VisitAssignment.status == AssignmentStatus.ASSIGNED,
                JobVisit.status == VisitStatus.PLANNED,
                lower > start if kind == "soon" else lower >= start,
                lower <= end if kind == "soon" else lower < end,
            )
        )
        if assigned_before is not None:
            stmt = stmt.where(VisitAssignment.created_at < assigned_before)
        for a, title, site, user_id, locale in await session.execute(stmt):
            assert a.period.lower is not None  # noqa: S101
            begins = a.period.lower
            when = reminder_when(
                kind, locale.value, time=begins.astimezone(YEREVAN).strftime("%H:%M"), site=site
            )
            head, body = render(NotificationType.TASK_REMINDER, locale.value, task=title, when=when)
            result = await session.execute(
                insert(Notification)
                .values(
                    user_id=user_id,
                    type=NotificationType.TASK_REMINDER,
                    title=head,
                    body=body,
                    data={"assignment_id": a.id, "reminder": kind},
                    dedupe_key=f"reminder:{a.id}:{kind}:{int(begins.timestamp())}",
                )
                .on_conflict_do_nothing(index_elements=[Notification.dedupe_key])
                .returning(Notification.id)
            )
            added += result.first() is not None
    await session.commit()
    if added:
        log.info("added %d task reminder(s)", added)
    return added
