"""Planning timeline (ARCHITECTURE §14a): window, crews, on-site period, dismantle flags."""

from datetime import datetime, timedelta
from typing import Any

from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from tests.factories import FakeStorage, Scene, at, make_visit
from tests.test_timesheets import submit_lead
from tests.test_worker_api import make_crew

TODAY = at(0).date()


def window(start_days: int = -7, end_days: int = 30) -> dict[str, str]:
    return {
        "from": (TODAY + timedelta(days=start_days)).isoformat(),
        "to": (TODAY + timedelta(days=end_days)).isoformat(),
    }


async def won(client: AsyncClient, scene: Scene, **patch: str) -> None:
    url = f"/api/v1/projects/{scene.project_id}"
    for status in ("QUOTED", "WON"):
        r = await client.patch(url, headers=scene.manager, json={"status": status})
        assert r.status_code == 200, r.text
    if patch:
        r = await client.patch(url, headers=scene.manager, json=patch)
        assert r.status_code == 200, r.text


async def planning(client: AsyncClient, scene: Scene, **params: str) -> list[dict[str, Any]]:
    r = await client.get(
        "/api/v1/planning/projects", headers=scene.manager, params=params or window()
    )
    assert r.status_code == 200, r.text
    rows: list[dict[str, Any]] = r.json()
    return rows


async def test_project_row_has_jobs_visits_crews_and_unstaffed_count(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)
    await won(client, crew.scene)
    await make_visit(client, crew.scene, at(0, day=2), at(8, day=2))  # no crew yet

    [row] = await planning(client, crew.scene)

    assert row["status"] == "WON"
    [job] = row["jobs"]
    assert job["job_type"] == "INSTALLATION"
    assert [v["crew"] for v in job["visits"]] == [["Arman Test", "David Test"], []]
    assert row["unstaffed_visits"] == 1
    assert row["on_site_from"] is None


async def test_window_and_status_decide_which_projects_show(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)  # project still LEAD: not planned work

    assert await planning(client, crew.scene) == []

    await won(client, crew.scene)
    assert await planning(client, crew.scene, **window(10, 40)) == [], "visit is today"

    await won_dates(client, crew.scene, install=15, dismantle=60)
    [row] = await planning(client, crew.scene, **window(10, 40))
    assert row["jobs"] == [], "shown for its planned period only"


async def won_dates(client: AsyncClient, scene: Scene, install: int, dismantle: int) -> None:
    r = await client.patch(
        f"/api/v1/projects/{scene.project_id}",
        headers=scene.manager,
        json={
            "expected_install_date": (TODAY + timedelta(days=install)).isoformat(),
            "expected_dismantle_date": (TODAY + timedelta(days=dismantle)).isoformat(),
        },
    )
    assert r.status_code == 200, r.text


async def test_done_installation_starts_on_site_period_and_flags_dismantling(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await make_crew(client, session, solo=True)
    await won(client, crew.scene)
    await submit_lead(client, crew, storage)  # visit DONE → job COMPLETED → INSTALLED

    await won_dates(client, crew.scene, install=0, dismantle=-1)
    [overdue] = await planning(client, crew.scene)
    await won_dates(client, crew.scene, install=0, dismantle=5)
    [soon] = await planning(client, crew.scene)

    assert overdue["status"] == "INSTALLED"
    assert datetime.fromisoformat(overdue["on_site_from"]) == at(0)
    assert overdue["on_site_to"] is None, "still on site"
    assert (overdue["dismantle_overdue"], overdue["dismantle_soon"]) == (True, False)
    assert (soon["dismantle_overdue"], soon["dismantle_soon"]) == (False, True)
    assert overdue["jobs"][0]["visits"][0]["status"] == "DONE"


async def test_planning_is_for_managers_and_checks_the_window(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)

    worker = await client.get("/api/v1/planning/projects", headers=crew.lead)
    backwards = await client.get(
        "/api/v1/planning/projects", headers=crew.scene.manager, params=window(5, 1)
    )
    too_long = await client.get(
        "/api/v1/planning/projects", headers=crew.scene.manager, params=window(0, 500)
    )

    assert worker.status_code == 403
    assert backwards.status_code == 422 and too_long.status_code == 422
