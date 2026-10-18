"""Timesheet review (ARCHITECTURE §13): list, detail, approve, adjust, override, CSV."""

import uuid
from datetime import timedelta

from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.audit.models import AuditLog
from tests.factories import FakeStorage, at, iso
from tests.test_worker_api import (
    FAR,
    Crew,
    check_body,
    completion,
    install,
    make_crew,
    put,
    start_work,
    upload_photo,
)

RANGE = {"from": iso(at(-24)), "to": iso(at(48))}


async def submit_lead(client: AsyncClient, crew: Crew, fake: FakeStorage) -> None:
    await start_work(client, crew.lead_task, crew.lead)
    await install(client, crew.lead_task, crew.lead)
    photo = await upload_photo(client, fake, crew.lead_task, crew.lead)
    r = await put(
        client,
        f"/api/v1/worker/tasks/{crew.lead_task}/completion/{uuid.uuid4()}",
        crew.lead,
        completion([photo]),
    )
    assert r.status_code == 200, r.text


async def test_list_shows_recomputed_hours_and_review_state(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await make_crew(client, session)
    await submit_lead(client, crew, storage)
    await start_work(client, crew.member_task, crew.member)  # still working

    rows = (await client.get("/api/v1/timesheets", headers=crew.scene.manager, params=RANGE)).json()

    by_task = {r["assignment_id"]: r for r in rows}
    lead = by_task[crew.lead_task]
    assert lead["status"] == "SUBMITTED"
    assert lead["work_seconds"] == 8 * 3600, "09:00 → completed_at 17:00"
    assert lead["pay_amount"] == "25000.00"
    assert lead["reviewed_at"] is None
    assert by_task[crew.member_task]["status"] == "IN_PROGRESS"


async def test_approval_makes_pay_earned_and_is_audited(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await make_crew(client, session)
    await submit_lead(client, crew, storage)
    month = (at(0) + timedelta(hours=4)).strftime("%Y-%m")
    url = f"/api/v1/timesheets/assignments/{crew.lead_task}/approve"

    early = await client.post(
        f"/api/v1/timesheets/assignments/{crew.member_task}/approve", headers=crew.scene.manager
    )
    ok = await client.post(url, headers=crew.scene.manager)
    again = await client.post(url, headers=crew.scene.manager)
    earnings = (
        await client.get("/api/v1/worker/earnings", headers=crew.lead, params={"month": month})
    ).json()
    pending = (
        await client.get(
            "/api/v1/timesheets", headers=crew.scene.manager, params=RANGE | {"reviewed": False}
        )
    ).json()

    assert early.json()["error"]["code"] == "NOT_SUBMITTED"
    assert ok.status_code == 204 and again.status_code == 204, "approve is idempotent"
    assert earnings["approved_tasks"] == 1 and earnings["approved_amount"] == "25000.00"
    assert crew.lead_task not in [r["assignment_id"] for r in pending]
    assert await session.scalar(select(AuditLog.id).where(AuditLog.action == "timesheet.approved"))


async def test_detail_has_entries_checks_photos_and_materials(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await make_crew(client, session)
    await submit_lead(client, crew, storage)

    d = (
        await client.get(
            f"/api/v1/timesheets/assignments/{crew.lead_task}", headers=crew.scene.manager
        )
    ).json()

    assert (d["site_latitude"], d["site_radius_m"]) == (40.2262, 150.0)
    assert [e["kind"] for e in d["entries"]] == ["WORK"]
    assert d["checks"][0]["server_verified"] is True
    assert d["photos"][0]["url"].endswith("?download")
    assert d["materials"][0]["quantity"] == "420.000"
    assert d["comment"] == "Net on floors 6-9."


async def test_adjust_recomputes_totals_and_locks_after_approval(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await make_crew(client, session)
    await submit_lead(client, crew, storage)
    url = f"/api/v1/timesheets/assignments/{crew.lead_task}"
    entry = (await client.get(url, headers=crew.scene.manager)).json()["entries"][0]
    body = {
        "time_entry_id": entry["id"],
        "started_at": iso(at(0)),
        "ended_at": iso(at(7.5)),
        "reason": "Left at 16:30, forgot to finish",
    }

    adjusted = await client.post(f"{url}/adjust", headers=crew.scene.manager, json=body)
    after = (await client.get(url, headers=crew.scene.manager)).json()
    await client.post(f"{url}/approve", headers=crew.scene.manager)
    locked = await client.post(f"{url}/adjust", headers=crew.scene.manager, json=body)

    assert adjusted.status_code == 204, adjusted.text
    assert after["work_seconds"] == int(7.5 * 3600)
    assert locked.json()["error"]["code"] == "ASSIGNMENT_REVIEWED"
    log = await session.scalar(select(AuditLog).where(AuditLog.action == "timesheet.adjusted"))
    assert log is not None and log.meta["reason"] == "Left at 16:30, forgot to finish"


async def test_override_clears_outside_geofence(client: AsyncClient, session: AsyncSession) -> None:
    crew = await make_crew(client, session)
    check_id = str(uuid.uuid4())
    await put(
        client,
        f"/api/v1/worker/location-checks/{check_id}",
        crew.lead,
        check_body(crew.lead_task, FAR),
    )
    await put(
        client,
        f"/api/v1/worker/time-entries/{uuid.uuid4()}",
        crew.lead,
        {"task_id": crew.lead_task, "kind": "WORK", "started_at": iso(at(0))},
    )
    rows = (
        await client.get(
            "/api/v1/timesheets", headers=crew.scene.manager, params=RANGE | {"flagged": True}
        )
    ).json()
    assert [r["review_flags"] for r in rows] == [["OUTSIDE_GEOFENCE"]]

    r = await client.post(
        f"/api/v1/location-checks/{check_id}/override",
        headers=crew.scene.manager,
        json={"reason": "Pin was on the wrong building"},
    )
    detail = (
        await client.get(
            f"/api/v1/timesheets/assignments/{crew.lead_task}", headers=crew.scene.manager
        )
    ).json()

    assert r.status_code == 204
    assert detail["review_flags"] == []
    assert detail["checks"][0]["override_reason"] == "Pin was on the wrong building"


async def test_csv_export_lists_approved_tasks(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await make_crew(client, session)
    await submit_lead(client, crew, storage)
    await client.post(
        f"/api/v1/timesheets/assignments/{crew.lead_task}/approve", headers=crew.scene.manager
    )

    r = await client.get("/api/v1/timesheets/export.csv", headers=crew.scene.manager, params=RANGE)

    assert r.headers["content-type"].startswith("text/csv")
    assert "attachment" in r.headers["content-disposition"]
    lines = r.text.lstrip("﻿").strip().splitlines()
    assert lines[0].startswith("date,employee_code,worker")
    assert len(lines) == 2
    assert ",8.00,0.00,25000.00,AMD," in lines[1]


async def test_workers_cannot_see_timesheets(client: AsyncClient, session: AsyncSession) -> None:
    crew = await make_crew(client, session)

    r = await client.get("/api/v1/timesheets", headers=crew.lead, params=RANGE)

    assert r.status_code == 403
