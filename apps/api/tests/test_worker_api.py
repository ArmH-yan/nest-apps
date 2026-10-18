"""`/api/v1/worker/*` (ARCHITECTURE §18, §19, §33): isolation, idempotent replays,
server-side GPS/time checks and flags, completion guards and side effects."""

import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any

import pytest
from httpx import AsyncClient, Response
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.materials.models import CatalogItem
from app.modules.scheduling.models import VisitAssignment
from app.modules.users.models import User
from tests.factories import (
    FakeStorage,
    Scene,
    at,
    iso,
    make_scene,
    make_visit,
    make_worker,
    post,
    token,
)

SITE = (40.2262, 44.4930)  # make_scene's pin
NEAR = (40.2265, 44.4932)  # ~38 m away
FAR = (40.2340, 44.4930)  # ~870 m away


@dataclass
class Crew:
    scene: Scene
    visit_id: int
    lead_task: int
    member_task: int
    lead: dict[str, str]
    member: dict[str, str]


async def make_crew(
    client: AsyncClient, session: AsyncSession, job_type: str = "INSTALLATION", solo: bool = False
) -> Crew:
    scene = await make_scene(client, session, job_type=job_type)
    arman = await make_worker(session, "+37491000007")
    david = await make_worker(session, "+37491000011", first="David")
    visit = await make_visit(client, scene, at(0), at(8))
    members = [{"worker_id": arman.id, "role": "LEAD", "pay_amount": "25000"}]
    if not solo:
        members.append({"worker_id": david.id, "role": "MEMBER", "pay_amount": "20000"})
    response = await client.put(
        f"/api/v1/visits/{visit['id']}/crew", headers=scene.manager, json={"members": members}
    )
    ids = {m["worker_id"]: m["assignment_id"] for m in response.json()["crew"]}
    return Crew(
        scene,
        visit["id"],
        ids[arman.id],
        ids.get(david.id, 0),
        await token(client, "+37491000007"),
        await token(client, "+37491000011"),
    )


def check_body(task_id: int, where: tuple[float, float] = NEAR, **extra: Any) -> dict[str, Any]:
    return {
        "task_id": task_id,
        "purpose": "START",
        "latitude": where[0],
        "longitude": where[1],
        "accuracy_m": 8.0,
        "is_mocked": False,
        "captured_at": iso(at(0)),
        "distance_m": 38.0,
        "radius_m": 150.0,
        "verified": True,
    } | extra


async def put(client: AsyncClient, url: str, headers: dict[str, str], body: Any) -> Response:
    return await client.put(url, headers=headers, json=body)


async def start_work(client: AsyncClient, task_id: int, headers: dict[str, str]) -> str:
    """START check + open WORK entry. Returns the entry id."""
    check_id = str(uuid.uuid4())
    r = await put(
        client, f"/api/v1/worker/location-checks/{check_id}", headers, check_body(task_id)
    )
    assert r.status_code == 200, r.text
    entry_id = str(uuid.uuid4())
    r = await put(
        client,
        f"/api/v1/worker/time-entries/{entry_id}",
        headers,
        {
            "task_id": task_id,
            "kind": "WORK",
            "started_at": iso(at(0)),
            "start_location_check_id": check_id,
        },
    )
    assert r.status_code == 200, r.text
    return entry_id


async def upload_photo(
    client: AsyncClient, storage: FakeStorage, task_id: int, headers: dict[str, str]
) -> str:
    photo_id = str(uuid.uuid4())
    presigned = await post(
        client,
        f"/api/v1/worker/files/{photo_id}/presign",
        headers,
        {"task_id": task_id, "size_bytes": 120_000, "mime_type": "image/jpeg"},
    )
    storage.upload(presigned["upload_url"].removeprefix("http://storage.test/"))
    await post(client, f"/api/v1/worker/files/{photo_id}/confirm", headers, None)
    return photo_id


async def install(client: AsyncClient, task_id: int, headers: dict[str, str]) -> None:
    item = 2  # NET-M2 from the seeded catalog
    r = await put(
        client,
        f"/api/v1/worker/material-movements/{uuid.uuid4()}",
        headers,
        {"task_id": task_id, "catalog_item_id": item, "quantity": "420", "movement": "INSTALLED"},
    )
    assert r.status_code == 200, r.text


def completion(photos: list[str], work: int = 8 * 3600, brk: int = 0) -> dict[str, Any]:
    return {
        "completed_at": iso(at(8)),
        "reported_work_seconds": work,
        "reported_break_seconds": brk,
        "photo_ids": photos,
        "comment": "Net on floors 6-9.",
    }


# --- reads and isolation -----------------------------------------------------------


async def test_tasks_show_my_assignments_with_site_and_crew(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)

    response = await client.get(
        "/api/v1/worker/tasks",
        headers=crew.lead,
        params={"from": iso(at(-24)), "to": iso(at(24))},
    )

    assert response.status_code == 200, response.text
    [task] = response.json()
    assert task["id"] == crew.lead_task
    assert task["title"] == "Install Safety Net"
    assert task["project_name"] == "Davtashen Residential"
    assert task["customer_name"] == "Arm Build LLC"
    assert (task["latitude"], task["longitude"]) == SITE
    assert task["geofence_radius_m"] == 150
    assert task["role"] == "LEAD"
    assert task["status"] == "ASSIGNED"
    assert [m["role"] for m in task["crew"]] == ["LEAD", "MEMBER"]


async def test_another_workers_task_is_404_and_managers_get_403(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)

    foreign = await client.get(f"/api/v1/worker/tasks/{crew.member_task}", headers=crew.lead)
    write = await put(
        client,
        f"/api/v1/worker/time-entries/{uuid.uuid4()}",
        crew.lead,
        {"task_id": crew.member_task, "kind": "WORK", "started_at": iso(at(0))},
    )
    manager = await client.get("/api/v1/worker/config", headers=crew.scene.manager)

    assert foreign.status_code == 404
    assert write.status_code == 404
    assert manager.status_code == 403


async def test_config_comes_from_settings(client: AsyncClient, session: AsyncSession) -> None:
    crew = await make_crew(client, session)

    config = (await client.get("/api/v1/worker/config", headers=crew.lead)).json()

    assert config == {
        "default_geofence_radius_m": 150,
        "max_location_accuracy_m": 100,
        "min_completion_photos": 1,
        "start_window_minutes_before": 120,
        "min_supported_app_version": "1.0.0",
        "telegram_bot_username": None,
    }


# --- GPS checks --------------------------------------------------------------------


async def test_server_recomputes_gps_and_flags_without_rejecting(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)

    near = await put(
        client,
        f"/api/v1/worker/location-checks/{uuid.uuid4()}",
        crew.lead,
        check_body(crew.lead_task),
    )
    assert near.json()["server_verified"] is True
    assert 30 < near.json()["server_distance_m"] < 45
    assert near.json()["review_flags"] == []

    # the phone claims "verified" from far away with a mocked fix: stored, flagged
    far = await put(
        client,
        f"/api/v1/worker/location-checks/{uuid.uuid4()}",
        crew.lead,
        check_body(crew.lead_task, FAR, is_mocked=True, accuracy_m=250.0, purpose="RESUME"),
    )
    assert far.status_code == 200
    body = far.json()
    assert body["server_verified"] is False
    assert 800 < body["server_distance_m"] < 950
    assert body["review_flags"] == ["LOW_ACCURACY", "MOCK_LOCATION", "OUTSIDE_GEOFENCE"]


async def test_clock_skew_is_flagged_from_the_device_time_header(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)
    skewed = crew.lead | {
        "X-Device-Time": (datetime.now().astimezone() - timedelta(hours=1)).isoformat()
    }

    r = await put(
        client, f"/api/v1/worker/location-checks/{uuid.uuid4()}", skewed, check_body(crew.lead_task)
    )

    assert r.json()["review_flags"] == ["CLOCK_SKEW"]


async def test_location_check_replay(client: AsyncClient, session: AsyncSession) -> None:
    crew = await make_crew(client, session)
    url = f"/api/v1/worker/location-checks/{uuid.uuid4()}"
    body = check_body(crew.lead_task)

    first = await put(client, url, crew.lead, body)
    again = await put(client, url, crew.lead, body)
    changed = await put(client, url, crew.lead, body | {"latitude": 40.3})

    assert again.status_code == 200 and again.json()["id"] == first.json()["id"]
    assert changed.json()["error"]["code"] == "LOCATION_CHECK_FINALIZED"


# --- time entries ------------------------------------------------------------------


async def test_first_work_entry_starts_task_and_job(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)

    await start_work(client, crew.lead_task, crew.lead)

    task = (await client.get(f"/api/v1/worker/tasks/{crew.lead_task}", headers=crew.lead)).json()
    job = (await client.get(f"/api/v1/jobs/{crew.scene.job_id}", headers=crew.scene.manager)).json()
    assert task["status"] == "IN_PROGRESS"
    assert job["status"] == "IN_PROGRESS"


async def test_time_entry_replays_and_finalization(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)
    entry = await start_work(client, crew.lead_task, crew.lead)
    url = f"/api/v1/worker/time-entries/{entry}"
    open_body = {"task_id": crew.lead_task, "kind": "WORK", "started_at": iso(at(0))}
    closed = open_body | {"ended_at": iso(at(3))}

    replay_open = await put(client, url, crew.lead, open_body | {"start_location_check_id": None})
    close = await put(client, url, crew.lead, closed)
    replay_closed = await put(client, url, crew.lead, closed)
    moved = await put(client, url, crew.lead, closed | {"ended_at": iso(at(4))})

    assert replay_open.status_code == 200
    assert close.json()["ended_at"] is not None
    assert replay_closed.status_code == 200
    assert moved.status_code == 409
    assert moved.json()["error"]["code"] == "TIME_ENTRY_FINALIZED"


async def test_overlapping_sessions_are_rejected(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)
    await start_work(client, crew.lead_task, crew.lead)  # open since 09:00

    overlap = await put(
        client,
        f"/api/v1/worker/time-entries/{uuid.uuid4()}",
        crew.lead,
        {"task_id": crew.lead_task, "kind": "BREAK", "started_at": iso(at(2))},
    )

    assert overlap.status_code == 409
    assert overlap.json()["error"]["code"] == "TIME_ENTRY_OVERLAP"


async def test_cancelled_task_rejects_new_work(client: AsyncClient, session: AsyncSession) -> None:
    crew = await make_crew(client, session)
    await client.post(
        f"/api/v1/jobs/{crew.scene.job_id}/cancel", headers=crew.scene.manager, json={"reason": "x"}
    )

    r = await put(
        client,
        f"/api/v1/worker/time-entries/{uuid.uuid4()}",
        crew.lead,
        {"task_id": crew.lead_task, "kind": "WORK", "started_at": iso(at(0))},
    )

    assert r.status_code == 409
    assert r.json()["error"]["code"] == "TASK_CANCELLED"


# --- materials and photos ----------------------------------------------------------


async def test_only_the_lead_records_materials_and_replays_are_safe(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)
    movement = {
        "task_id": crew.member_task,
        "catalog_item_id": 2,
        "quantity": "10",
        "movement": "INSTALLED",
    }

    member = await put(
        client, f"/api/v1/worker/material-movements/{uuid.uuid4()}", crew.member, movement
    )
    url = f"/api/v1/worker/material-movements/{uuid.uuid4()}"
    lead_body = movement | {"task_id": crew.lead_task}
    first = await put(client, url, crew.lead, lead_body)
    replay = await put(client, url, crew.lead, lead_body | {"quantity": "10.000"})
    changed = await put(client, url, crew.lead, lead_body | {"quantity": "11"})

    assert member.json()["error"]["code"] == "NOT_CREW_LEAD"
    assert first.status_code == 200 and replay.status_code == 200
    assert changed.json()["error"]["code"] == "MATERIAL_FINALIZED"


async def test_catalog_and_expected_materials_follow_the_ledger(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)
    await install(client, crew.lead_task, crew.lead)
    await put(
        client,
        f"/api/v1/worker/material-movements/{uuid.uuid4()}",
        crew.lead,
        {"task_id": crew.lead_task, "catalog_item_id": 2, "quantity": "20", "movement": "DAMAGED"},
    )

    catalog = (await client.get("/api/v1/worker/catalog", headers=crew.lead)).json()
    expected = (
        await client.get(
            f"/api/v1/worker/tasks/{crew.lead_task}/expected-materials", headers=crew.lead
        )
    ).json()

    assert catalog[0] == {
        "id": 1,
        "name": "Անվտանգության ցանց 10×5 մ",  # noqa: RUF001 — the real product name
        "unit": "pcs",
    }  # user locale hy
    assert expected == [
        {"item": {"id": 2, "name": "Անվտանգության ցանց", "unit": "m2"}, "quantity": "400.000"}
    ]


async def test_photo_upload_steps_are_resumable(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await make_crew(client, session)
    photo = str(uuid.uuid4())
    body = {"task_id": crew.lead_task, "size_bytes": 120_000}

    first = await post(client, f"/api/v1/worker/files/{photo}/presign", crew.lead, body)
    early = await client.post(f"/api/v1/worker/files/{photo}/confirm", headers=crew.lead)
    again = await post(client, f"/api/v1/worker/files/{photo}/presign", crew.lead, body)
    storage.upload(first["upload_url"].removeprefix("http://storage.test/"))
    confirmed = await post(client, f"/api/v1/worker/files/{photo}/confirm", crew.lead, None)
    after = await post(client, f"/api/v1/worker/files/{photo}/presign", crew.lead, body)

    assert early.json()["error"]["code"] == "FILE_NOT_UPLOADED"
    assert again["upload_url"] == first["upload_url"], "same object key on retry"
    assert confirmed["status"] == "UPLOADED"
    assert after["already_uploaded"] is True
    too_big = await client.post(
        f"/api/v1/worker/files/{uuid.uuid4()}/presign",
        headers=crew.lead,
        json=body | {"size_bytes": 50_000_000},
    )
    assert too_big.json()["error"]["code"] == "FILE_TOO_LARGE"


# --- completion --------------------------------------------------------------------


async def test_full_submission_completes_visit_job_and_project(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await make_crew(client, session, solo=True)
    for status in ("QUOTED", "WON"):  # quotes are Phase 5; move by hand
        await client.patch(
            f"/api/v1/projects/{crew.scene.project_id}",
            headers=crew.scene.manager,
            json={"status": status},
        )
    entry = await start_work(client, crew.lead_task, crew.lead)
    await put(
        client,
        f"/api/v1/worker/time-entries/{entry}",
        crew.lead,
        {
            "task_id": crew.lead_task,
            "kind": "WORK",
            "started_at": iso(at(0)),
            "ended_at": iso(at(3)),
        },
    )
    await put(
        client,
        f"/api/v1/worker/time-entries/{uuid.uuid4()}",
        crew.lead,
        {
            "task_id": crew.lead_task,
            "kind": "BREAK",
            "started_at": iso(at(3)),
            "ended_at": iso(at(3.5)),
        },
    )
    await put(  # still open: closed by the server at completed_at
        client,
        f"/api/v1/worker/time-entries/{uuid.uuid4()}",
        crew.lead,
        {"task_id": crew.lead_task, "kind": "WORK", "started_at": iso(at(3.5))},
    )
    await install(client, crew.lead_task, crew.lead)
    photo = await upload_photo(client, storage, crew.lead_task, crew.lead)
    url = f"/api/v1/worker/tasks/{crew.lead_task}/completion/{uuid.uuid4()}"
    body = completion([photo], work=int(7.5 * 3600), brk=1800)

    done = await put(client, url, crew.lead, body)
    replay = await put(client, url, crew.lead, body)
    other = await put(
        client, f"/api/v1/worker/tasks/{crew.lead_task}/completion/{uuid.uuid4()}", crew.lead, body
    )

    assert done.status_code == 200, done.text
    assert done.json() | {"id": None} == {
        "id": None,
        "task_id": crew.lead_task,
        "task_status": "SUBMITTED",
        "work_seconds": int(7.5 * 3600),
        "break_seconds": 1800,
        "review_flags": [],
    }
    assert replay.status_code == 200
    assert other.json()["error"]["code"] == "TASK_ALREADY_SUBMITTED"
    job = (await client.get(f"/api/v1/jobs/{crew.scene.job_id}", headers=crew.scene.manager)).json()
    project = (
        await client.get(f"/api/v1/projects/{crew.scene.project_id}", headers=crew.scene.manager)
    ).json()
    assert job["visits"][0]["status"] == "DONE"
    assert job["status"] == "COMPLETED"
    assert project["status"] == "INSTALLED"

    history = (await client.get("/api/v1/worker/history", headers=crew.lead)).json()
    assert [(h["task"]["id"], h["work_seconds"], h["photo_count"]) for h in history["items"]] == [
        (crew.lead_task, int(7.5 * 3600), 1)
    ]


@pytest.mark.parametrize("missing", ["start_check", "photo", "materials"])
async def test_completion_guards(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage, missing: str
) -> None:
    crew = await make_crew(client, session)
    if missing == "start_check":
        await put(
            client,
            f"/api/v1/worker/time-entries/{uuid.uuid4()}",
            crew.lead,
            {"task_id": crew.lead_task, "kind": "WORK", "started_at": iso(at(0))},
        )
    else:
        await start_work(client, crew.lead_task, crew.lead)
    if missing != "materials":
        await install(client, crew.lead_task, crew.lead)
    photos = (
        []
        if missing == "photo"
        else [await upload_photo(client, storage, crew.lead_task, crew.lead)]
    )

    r = await put(
        client,
        f"/api/v1/worker/tasks/{crew.lead_task}/completion/{uuid.uuid4()}",
        crew.lead,
        completion(photos),
    )

    expected = {
        "start_check": "START_CHECK_MISSING",
        "photo": "NOT_ENOUGH_PHOTOS",
        "materials": "MATERIALS_REQUIRED",
    }[missing]
    assert r.status_code == 409
    assert r.json()["error"]["code"] == expected


async def test_unconfirmed_photo_and_member_without_materials(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await make_crew(client, session)
    await start_work(client, crew.member_task, crew.member)
    pending = str(uuid.uuid4())
    await post(
        client,
        f"/api/v1/worker/files/{pending}/presign",
        crew.member,
        {"task_id": crew.member_task, "size_bytes": 1000},
    )
    url = f"/api/v1/worker/tasks/{crew.member_task}/completion/{uuid.uuid4()}"

    blocked = await put(client, url, crew.member, completion([pending]))
    storage.upload(storage.signed[-1])
    await post(client, f"/api/v1/worker/files/{pending}/confirm", crew.member, None)
    ok = await put(client, url, crew.member, completion([pending], work=4 * 3600))

    assert blocked.json()["error"]["code"] == "PHOTOS_NOT_UPLOADED"
    assert blocked.json()["error"]["details"] == {"photo_ids": [pending]}
    assert ok.status_code == 200, "members don't record materials"
    assert ok.json()["review_flags"] == ["TOTALS_MISMATCH"], "8h recorded vs 4h reported"
    job = (await client.get(f"/api/v1/jobs/{crew.scene.job_id}", headers=crew.scene.manager)).json()
    assert job["visits"][0]["status"] == "PLANNED", "the lead hasn't submitted yet"


# --- earnings and notifications ----------------------------------------------------


async def test_earnings_count_only_approved_tasks(
    client: AsyncClient, session: AsyncSession, storage: FakeStorage
) -> None:
    crew = await make_crew(client, session)
    await start_work(client, crew.member_task, crew.member)
    photo = await upload_photo(client, storage, crew.member_task, crew.member)
    await put(
        client,
        f"/api/v1/worker/tasks/{crew.member_task}/completion/{uuid.uuid4()}",
        crew.member,
        completion([photo]),
    )
    month = (at(0) + timedelta(hours=4)).strftime("%Y-%m")

    before = (
        await client.get("/api/v1/worker/earnings", headers=crew.member, params={"month": month})
    ).json()
    await session.execute(
        update(VisitAssignment)
        .where(VisitAssignment.id == crew.member_task)
        .values(reviewed_at=at(10))
    )
    await session.commit()
    after = (
        await client.get("/api/v1/worker/earnings", headers=crew.member, params={"month": month})
    ).json()
    bad = await client.get(
        "/api/v1/worker/earnings", headers=crew.member, params={"month": "2026-13"}
    )

    assert before == {
        "month": month,
        "approved_tasks": 0,
        "approved_amount": "0.00",
        "currency": "AMD",
    }
    assert after == {
        "month": month,
        "approved_tasks": 1,
        "approved_amount": "20000.00",
        "currency": "AMD",
    }
    assert bad.status_code == 422


async def test_crew_changes_notify_workers_in_their_language(
    client: AsyncClient, session: AsyncSession
) -> None:
    crew = await make_crew(client, session)
    await session.execute(update(User).where(User.phone == "+37491000011").values(locale="hi"))
    await session.commit()
    await client.patch(
        f"/api/v1/visits/{crew.visit_id}",
        headers=crew.scene.manager,
        json={"starts_at": iso(at(1)), "ends_at": iso(at(9))},
    )

    lead_page = (await client.get("/api/v1/worker/notifications", headers=crew.lead)).json()
    member_page = (await client.get("/api/v1/worker/notifications", headers=crew.member)).json()

    assert [n["title"] for n in lead_page["items"]] == [
        "Առաջադրանքի ժամը փոխվել է",
        "Նոր առաջադրանք",
    ]
    assert member_page["items"][0]["title"] == "काम का समय बदल गया"
    assert member_page["items"][0]["task_id"] == crew.member_task
    assert "Install Safety Net" in member_page["items"][0]["body"]

    newest = lead_page["items"][0]["id"]
    read = await client.post(f"/api/v1/worker/notifications/{newest}/read", headers=crew.lead)
    foreign = await client.post(f"/api/v1/worker/notifications/{newest}/read", headers=crew.member)
    assert read.status_code == 204
    assert foreign.status_code == 404
    page = (await client.get("/api/v1/worker/notifications", headers=crew.lead)).json()
    assert page["items"][0]["read_at"] is not None


async def test_catalog_names_fall_back_to_english_for_hi_and_id(session: AsyncSession) -> None:
    item = await session.scalar(select(CatalogItem).where(CatalogItem.sku == "ANCHOR-M12"))
    assert item is not None
    assert [item.name(lang) for lang in ("hy", "ru", "en", "hi", "id")] == [
        "Խարիսխ M12",
        "Анкер M12",
        "Anchor M12",
        "Anchor M12",
        "Anchor M12",
    ]
