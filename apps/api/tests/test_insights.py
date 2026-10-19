"""Manager "Info" views (ARCHITECTURE §13a): worker and company totals, averages, raw rows."""

from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from tests.factories import FakeStorage, at
from tests.test_timesheets import submit_lead
from tests.test_worker_api import Crew, make_crew, start_work

TODAY = at(0).date().isoformat()
WINDOW = {"from": TODAY, "to": TODAY}


async def approved_crew(client: AsyncClient, session: AsyncSession, storage: FakeStorage) -> Crew:
    """Lead: submitted and approved (8 h, 25 000). Member: still working."""
    crew = await make_crew(client, session)
    await submit_lead(client, crew, storage)
    await start_work(client, crew.member_task, crew.member)
    r = await client.post(
        f"/api/v1/timesheets/assignments/{crew.lead_task}/approve", headers=crew.scene.manager
    )
    assert r.status_code == 204
    return crew


async def worker_id(client: AsyncClient, crew: Crew, task_id: int) -> int:
    r = await client.get(f"/api/v1/timesheets/assignments/{task_id}", headers=crew.scene.manager)
    return int(r.json()["worker_id"])


async def test_worker_info_sums_and_averages_approved_work(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await approved_crew(client, session, storage)
    lead = await worker_id(client, crew, crew.lead_task)

    info = (
        await client.get(
            f"/api/v1/insights/workers/{lead}", headers=crew.scene.manager, params=WINDOW
        )
    ).json()

    assert (info["tasks_assigned"], info["tasks_submitted"], info["tasks_approved"]) == (1, 1, 1)
    assert info["approved_pay"] == "25000.00"
    assert info["mean_pay_per_task"] == "25000.00"
    assert info["mean_work_seconds_per_task"] == 8 * 3600
    assert info["approval_rate"] == 1.0
    year = (
        await client.get(f"/api/v1/insights/workers/{lead}", headers=crew.scene.manager)
    ).json()  # default window: 12 months, but only this one has work
    assert len(year["months"]) == 12
    assert year["mean_monthly_pay"] == "25000.00"
    assert [m["month"] for m in info["months"]] == [TODAY[:7]]


async def test_worker_raw_tasks_include_every_status_and_export_csv(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await approved_crew(client, session, storage)
    member = await worker_id(client, crew, crew.member_task)

    rows = (
        await client.get(
            f"/api/v1/insights/workers/{member}/tasks", headers=crew.scene.manager, params=WINDOW
        )
    ).json()
    csv = await client.get(
        f"/api/v1/insights/workers/{member}/tasks.csv", headers=crew.scene.manager, params=WINDOW
    )

    assert [r["status"] for r in rows] == ["IN_PROGRESS"]
    lines = csv.text.lstrip("﻿").strip().splitlines()
    assert lines[0].startswith("scheduled_start,scheduled_end,job")
    assert len(lines) == 2 and ",IN_PROGRESS," in lines[1]


async def test_company_info_counts_jobs_hours_pay_and_materials(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await approved_crew(client, session, storage)
    project = (
        await client.get(f"/api/v1/projects/{crew.scene.project_id}", headers=crew.scene.manager)
    ).json()
    url = f"/api/v1/insights/companies/{project['company_id']}"

    info = (await client.get(url, headers=crew.scene.manager, params=WINDOW)).json()
    jobs = (await client.get(f"{url}/jobs", headers=crew.scene.manager, params=WINDOW)).json()

    assert info["projects"] == 1 and info["sites"] == 1
    assert info["jobs_by_type"] == [{"job_type": "INSTALLATION", "jobs": 1}]
    assert info["tasks_submitted"] == 1
    assert info["work_seconds"] == 8 * 3600
    assert info["crew_pay"] == "25000.00"
    assert info["mean_work_seconds_per_visit"] == 8 * 3600, "member still working"
    assert info["materials"][0]["installed"] == "420.000"
    assert len(jobs) == 1 and jobs[0]["tasks_submitted"] == 1


async def test_info_is_for_managers_only(client: AsyncClient, session: AsyncSession) -> None:
    crew = await make_crew(client, session)

    r = await client.get("/api/v1/insights/workers/1", headers=crew.lead)
    missing = await client.get("/api/v1/insights/companies/999999", headers=crew.scene.manager)

    assert r.status_code == 403
    assert missing.status_code == 404
