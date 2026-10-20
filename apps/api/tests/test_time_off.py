"""Worker time off (ARCHITECTURE §8 worker_time_off, §14): whole days, no overlaps per
worker, a warning (booked tasks) rather than a block, audited."""

from datetime import timedelta
from typing import Any

from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.audit.models import AuditLog
from tests.factories import at
from tests.test_worker_api import Crew, make_crew

TODAY = at(0).date()


def day(n: int) -> str:
    return (TODAY + timedelta(days=n)).isoformat()


async def worker_ids(client: AsyncClient, crew: Crew) -> list[int]:
    workers = (await client.get("/api/v1/workers", headers=crew.scene.manager)).json()
    return sorted(w["id"] for w in workers)


async def add(
    client: AsyncClient, crew: Crew, worker_id: int, first: int, last: int, reason: str = "VACATION"
) -> tuple[int, dict[str, Any]]:
    r = await client.post(
        f"/api/v1/workers/{worker_id}/time-off",
        headers=crew.scene.manager,
        json={"first_day": day(first), "last_day": day(last), "reason": reason, "note": "Family"},
    )
    return r.status_code, r.json()


async def test_time_off_warns_about_tasks_already_booked(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)  # both workers have a task today
    arman, david = await worker_ids(client, crew)

    status, created = await add(client, crew, arman, 0, 2)
    _, later = await add(client, crew, david, 5, 6, "SICK")
    listed = (
        await client.get(f"/api/v1/workers/{arman}/time-off", headers=crew.scene.manager)
    ).json()

    assert status == 201
    assert (created["first_day"], created["last_day"]) == (day(0), day(2))
    assert created["booked_tasks"] == 1, "a warning, not a block"
    assert later["booked_tasks"] == 0
    assert [t["id"] for t in listed] == [created["id"]]
    assert await session.scalar(select(AuditLog.id).where(AuditLog.action == "time_off.created"))


async def test_overlapping_time_off_is_refused_but_adjacent_days_are_fine(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)
    arman, david = await worker_ids(client, crew)
    await add(client, crew, arman, 3, 5)

    overlap, body = await add(client, crew, arman, 5, 7)
    adjacent, _ = await add(client, crew, arman, 6, 7)
    other_worker, _ = await add(client, crew, david, 3, 5)

    assert overlap == 409 and body["error"]["code"] == "TIME_OFF_OVERLAP"
    assert adjacent == 201 and other_worker == 201


async def test_window_listing_and_delete(client: AsyncClient, session: AsyncSession) -> None:
    crew = await make_crew(client, session)
    arman, david = await worker_ids(client, crew)
    _, soon = await add(client, crew, arman, 1, 1)
    await add(client, crew, david, 20, 22)
    url = "/api/v1/workers/time-off"

    window = (
        await client.get(url, headers=crew.scene.manager, params={"from": day(0), "to": day(7)})
    ).json()
    deleted = await client.delete(f"{url}/{soon['id']}", headers=crew.scene.manager)
    again = await client.delete(f"{url}/{soon['id']}", headers=crew.scene.manager)
    after = (
        await client.get(url, headers=crew.scene.manager, params={"from": day(0), "to": day(30)})
    ).json()

    assert [(t["worker_name"], t["first_day"]) for t in window] == [("Arman Test", day(1))]
    assert deleted.status_code == 204 and again.status_code == 404
    assert [t["first_day"] for t in after] == [day(20)]
    assert await session.scalar(select(AuditLog.id).where(AuditLog.action == "time_off.deleted"))


async def test_time_off_validation_and_access(client: AsyncClient, session: AsyncSession) -> None:
    crew = await make_crew(client, session)
    arman, _ = await worker_ids(client, crew)

    backwards, _ = await add(client, crew, arman, 3, 1)
    unknown, _ = await add(client, crew, 999999, 1, 1)
    worker = await client.get(f"/api/v1/workers/{arman}/time-off", headers=crew.lead)

    assert backwards == 422 and unknown == 404
    assert worker.status_code == 403
