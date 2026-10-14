"""The demo seed must keep working as the schema evolves (it is the field-test setup)."""

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.seed import PASSWORD, SeedRefused, seed_demo
from tests.factories import at, iso


async def test_seed_demo_gives_arman_a_working_day(
    client: AsyncClient, session: AsyncSession
) -> None:
    await seed_demo(session, reset=False)
    with pytest.raises(SeedRefused):
        await seed_demo(session, reset=False)  # data exists and no --reset

    login = await client.post(
        "/api/v1/auth/login", json={"phone": "+37491000007", "password": PASSWORD}
    )
    arman = {"Authorization": f"Bearer {login.json()['access_token']}"}
    tasks = (
        await client.get(
            "/api/v1/worker/tasks", headers=arman, params={"from": iso(at(-48)), "to": iso(at(96))}
        )
    ).json()
    titles = [t["title"] for t in tasks]
    assert "Install Safety Net - Building A" in titles
    assert "Dismantle Safety Net - Building E" in titles
    dismantle = next(t for t in tasks if t["job_type"] == "DISMANTLING")
    expected = (
        await client.get(
            f"/api/v1/worker/tasks/{dismantle['id']}/expected-materials", headers=arman
        )
    ).json()
    assert {e["item"]["unit"]: e["quantity"] for e in expected} == {
        "m2": "300.000",
        "pcs": "40.000",
    }
    history = (await client.get("/api/v1/worker/history", headers=arman)).json()
    assert len(history["items"]) == 2
    notifications = (await client.get("/api/v1/worker/notifications", headers=arman)).json()
    assert len(notifications["items"]) == 4, "one TASK_ASSIGNED per scheduled task"
