"""Push delivery and reminders (ARCHITECTURE §26, §37): device tokens, the
notifications-as-queue worker, retries, dead tokens, reminder windows, FCM mapping."""

import json
from datetime import datetime, timedelta
from pathlib import Path

import httpx
import jwt
import pytest
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from httpx import AsyncClient
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.notifications.models import Notification, NotificationType, PushStatus
from app.modules.push import service
from app.modules.push.models import DeviceToken
from app.modules.push.sender import FcmPushSender, Outcome, PushMessage, SendResult
from app.modules.scheduling.models import VisitAssignment
from tests.factories import at, make_visit
from tests.test_worker_api import Crew, make_crew, start_work

LEAD_PHONE = "fcm-token-of-armans-phone-0001"
OTHER_PHONE = "fcm-token-of-armans-tablet-002"


class FakeSender:
    def __init__(self, outcomes: dict[str, Outcome] | None = None) -> None:
        self.outcomes = outcomes or {}
        self.sent: list[PushMessage] = []

    async def send(self, message: PushMessage) -> SendResult:
        self.sent.append(message)
        outcome = self.outcomes.get(message.token, Outcome.OK)
        return SendResult(outcome, None if outcome is Outcome.OK else outcome.value)


async def register(client: AsyncClient, headers: dict[str, str], token: str) -> int:
    r = await client.put(
        f"/api/v1/worker/devices/{token}",
        headers=headers,
        json={"platform": "android", "app_version": "1.0.0"},
    )
    return r.status_code


async def notifications(session: AsyncSession) -> list[Notification]:
    session.expire_all()
    return list(await session.scalars(select(Notification).order_by(Notification.id)))


async def tokens(session: AsyncSession) -> list[tuple[int, str]]:
    session.expire_all()
    rows = await session.execute(select(DeviceToken.user_id, DeviceToken.fcm_token))
    return sorted((u, t) for u, t in rows)


async def test_device_registration_is_idempotent_and_follows_the_login(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)

    assert await register(client, crew.lead, LEAD_PHONE) == 204
    assert await register(client, crew.lead, LEAD_PHONE) == 204  # every app start
    [(arman, _)] = await tokens(session)
    assert await register(client, crew.member, LEAD_PHONE) == 204  # David logs in on it
    [(owner, _)] = await tokens(session)
    foreign = await client.delete(f"/api/v1/worker/devices/{LEAD_PHONE}", headers=crew.lead)
    still = await tokens(session)
    own = await client.delete(f"/api/v1/worker/devices/{LEAD_PHONE}", headers=crew.member)

    assert owner != arman, "the token moved to David"
    assert foreign.status_code == 204 and len(still) == 1, "Arman can't remove David's token"
    assert own.status_code == 204 and await tokens(session) == []


async def test_new_notifications_are_pushed_once_to_every_device(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)  # TASK_ASSIGNED for Arman and David
    await register(client, crew.lead, LEAD_PHONE)
    await register(client, crew.lead, OTHER_PHONE)
    sender = FakeSender()

    handled = await service.deliver_pending(session, sender)
    again = await service.deliver_pending(session, sender)
    rows = await notifications(session)

    assert (handled, again) == (2, 0)
    assert sorted(m.token for m in sender.sent) == [LEAD_PHONE, OTHER_PHONE]
    assert sender.sent[0].data["assignment_id"] == str(crew.lead_task)
    assert sender.sent[0].data["type"] == "TASK_ASSIGNED"
    by_status = {n.push_status for n in rows}
    assert by_status == {PushStatus.SENT, PushStatus.SKIPPED}, "David has no device"


async def test_dead_tokens_are_dropped_and_transient_errors_retry_then_fail(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session, solo=True)
    await register(client, crew.lead, LEAD_PHONE)
    await register(client, crew.lead, OTHER_PHONE)
    sender = FakeSender({LEAD_PHONE: Outcome.UNREGISTERED, OTHER_PHONE: Outcome.RETRY})
    now = datetime.now().astimezone()

    await service.deliver_pending(session, sender, now)
    [n] = await notifications(session)
    assert (n.push_status, n.push_attempts) == (PushStatus.PENDING, 1)
    assert n.next_push_at > now, "backed off"
    assert [t for _, t in await tokens(session)] == [OTHER_PHONE], "dead token removed"

    for minutes in (2, 5, 10, 20):
        await service.deliver_pending(session, sender, now + timedelta(minutes=minutes))
    [n] = await notifications(session)
    assert (n.push_status, n.push_attempts) == (PushStatus.FAILED, 5)


async def test_stale_notifications_are_skipped(client: AsyncClient, session: AsyncSession) -> None:
    crew = await make_crew(client, session, solo=True)
    await register(client, crew.lead, LEAD_PHONE)
    sender = FakeSender()

    await service.deliver_pending(
        session, sender, datetime.now().astimezone() + timedelta(hours=13)
    )

    [n] = await notifications(session)
    assert n.push_status is PushStatus.SKIPPED and n.push_error == "stale"
    assert sender.sent == []


async def reminders(session: AsyncSession) -> list[Notification]:
    return [n for n in await notifications(session) if n.type is NotificationType.TASK_REMINDER]


async def test_one_hour_reminder_once_per_task_and_not_after_starting(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)  # visit today 09:00 Yerevan

    early = await service.create_reminders(session, at(-2))
    added = await service.create_reminders(session, at(-0.5))
    again = await service.create_reminders(session, at(-0.25))
    rows = await reminders(session)

    assert (early, added, again) == (0, 2, 0)
    assert {n.data["reminder"] for n in rows} == {"soon"}
    assert any("09:00" in n.body and "Building A" in n.body for n in rows)

    other = await make_crew_tomorrow(client, crew)
    await start_work(client, other, crew.lead)  # already working: no reminder
    assert await service.create_reminders(session, at(23.5)) == 1, "only David's"


async def make_crew_tomorrow(client: AsyncClient, crew: Crew) -> int:
    """A second visit tomorrow 09:00 for the same crew; returns Arman's task id."""
    visit = await make_visit(client, crew.scene, at(0, day=1), at(8, day=1))
    workers = (await client.get("/api/v1/workers", headers=crew.scene.manager)).json()
    ids = sorted(w["id"] for w in workers)
    r = await client.put(
        f"/api/v1/visits/{visit['id']}/crew",
        headers=crew.scene.manager,
        json={
            "members": [
                {"worker_id": ids[0], "role": "LEAD", "pay_amount": "25000"},
                {"worker_id": ids[1], "role": "MEMBER", "pay_amount": "20000"},
            ]
        },
    )
    assert r.status_code == 200, r.text
    return int(next(m["assignment_id"] for m in r.json()["crew"] if m["role"] == "LEAD"))


async def test_evening_reminder_for_tomorrow_only_if_assigned_before_19(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)
    await make_crew_tomorrow(client, crew)
    # pretend tomorrow's tasks were assigned this morning
    tomorrow = await session.scalars(
        select(VisitAssignment.id).where(VisitAssignment.id > crew.member_task)
    )
    ids = list(tomorrow)
    await session.execute(
        update(VisitAssignment).where(VisitAssignment.id.in_(ids)).values(created_at=at(-3))
    )
    await session.commit()

    before_19 = await service.create_reminders(session, at(9.5))  # 18:30 Yerevan
    evening = await service.create_reminders(session, at(10.5))  # 19:30 Yerevan
    rows = await reminders(session)

    assert (before_19, evening) == (0, 2)
    assert {n.data["reminder"] for n in rows} == {"tomorrow"}
    assert all("09:00" in n.body for n in rows)


async def test_logout_and_deactivation_forget_devices(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)
    await register(client, crew.lead, LEAD_PHONE)
    await register(client, crew.member, OTHER_PHONE)

    await client.post("/api/v1/auth/logout", headers=crew.lead)
    after_logout = [t for _, t in await tokens(session)]
    david = (await client.get("/api/v1/workers", headers=crew.scene.manager)).json()
    david_id = next(w["id"] for w in david if w["phone"] == "+37491000011")
    await client.patch(
        f"/api/v1/workers/{david_id}", headers=crew.scene.manager, json={"is_active": False}
    )

    assert after_logout == [OTHER_PHONE]
    assert await tokens(session) == []


# --- the FCM sender, against a fake Google -------------------------------------------


@pytest.fixture
def service_account(tmp_path: Path) -> tuple[Path, rsa.RSAPublicKey]:
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    pem = key.private_bytes(
        serialization.Encoding.PEM,
        serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption(),
    ).decode()
    path = tmp_path / "sa.json"
    path.write_text(
        json.dumps(
            {
                "project_id": "nest-test",
                "client_email": "push@nest-test.iam.gserviceaccount.com",
                "private_key": pem,
            }
        )
    )
    return path, key.public_key()


async def test_fcm_sender_signs_in_once_and_maps_errors(
    service_account: tuple[Path, rsa.RSAPublicKey],
) -> None:
    path, public_key = service_account
    calls: list[httpx.Request] = []

    def google(request: httpx.Request) -> httpx.Response:
        calls.append(request)
        if request.url.host == "oauth2.googleapis.com":
            assertion = dict(httpx.QueryParams(request.content.decode()))["assertion"]
            claims = jwt.decode(
                assertion, public_key, algorithms=["RS256"], audience=str(request.url)
            )
            assert claims["scope"].endswith("firebase.messaging")
            return httpx.Response(200, json={"access_token": "ya29.test", "expires_in": 3600})
        assert request.headers["Authorization"] == "Bearer ya29.test"
        assert request.url.path == "/v1/projects/nest-test/messages:send"
        token = json.loads(request.content)["message"]["token"]
        if token == "dead":
            return httpx.Response(
                404,
                json={
                    "error": {
                        "status": "NOT_FOUND",
                        "details": [{"errorCode": "UNREGISTERED"}],
                    }
                },
            )
        if token == "busy":
            return httpx.Response(503, json={"error": {"status": "UNAVAILABLE"}})
        return httpx.Response(200, json={"name": "projects/nest-test/messages/1"})

    sender = FcmPushSender(path, httpx.AsyncClient(transport=httpx.MockTransport(google)))
    message = PushMessage("alive", "Reminder", "Install · 09:00", {"assignment_id": "7"})

    ok = await sender.send(message)
    dead = await sender.send(PushMessage("dead", "t", "b", {}))
    busy = await sender.send(PushMessage("busy", "t", "b", {}))

    assert ok.outcome is Outcome.OK
    assert dead.outcome is Outcome.UNREGISTERED
    assert busy.outcome is Outcome.RETRY
    assert sum(c.url.host == "oauth2.googleapis.com" for c in calls) == 1, "token cached"
