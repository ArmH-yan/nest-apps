"""The push worker process (ARCHITECTURE §26, §37): `python -m app.cli push-worker`.

Runs next to the API from the same codebase. Every few seconds it delivers pending
notifications; once a minute it adds the task reminders that are due. Several
workers may run at once (rows are claimed with SKIP LOCKED; reminders are deduped).
"""

import asyncio
import logging
import time

from app.db.session import get_sessionmaker
from app.modules.push import service
from app.modules.push.sender import PushSender, get_sender

log = logging.getLogger(__name__)

IDLE_SECONDS = 5
REMINDER_EVERY_SECONDS = 60


async def run_once(sender: PushSender, *, reminders: bool = True) -> int:
    async with get_sessionmaker()() as session:
        if reminders:
            await service.create_reminders(session)
        return await service.deliver_pending(session, sender)


async def run_forever(stop: asyncio.Event | None = None) -> None:
    sender = get_sender()
    log.info("push worker started (%s)", type(sender).__name__)
    last_reminders = 0.0
    while stop is None or not stop.is_set():
        due = time.monotonic() - last_reminders >= REMINDER_EVERY_SECONDS
        try:
            handled = await run_once(sender, reminders=due)
            if due:
                last_reminders = time.monotonic()
        except Exception:  # keep running: the next round retries
            log.exception("push worker round failed")
            handled = 0
        if handled < service.BATCH:  # a full batch means more may be waiting
            await asyncio.sleep(IDLE_SECONDS)
