"""Companies → sites → projects → jobs → visits → crews (ARCHITECTURE §8, §11, §14)."""

from datetime import UTC, datetime
from typing import Any

import pytest
from httpx import AsyncClient, Response
from sqlalchemy import select, update
from sqlalchemy.dialects.postgresql import Range
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.audit.models import AuditLog
from app.modules.scheduling.models import (
    AssignmentRole,
    JobStatusHistory,
    VisitAssignment,
)
from app.modules.users.models import UserRole
from tests.factories import (
    Scene,
    at,
    iso,
    make_scene,
    make_user,
    make_visit,
    make_worker,
    post,
    token,
)


async def crew(
    client: AsyncClient, scene: Scene, visit_id: int, members: list[dict[str, Any]]
) -> Response:
    return await client.put(
        f"/api/v1/visits/{visit_id}/crew", headers=scene.manager, json={"members": members}
    )


def lead(worker_id: int, pay: str | None = None) -> dict[str, Any]:
    return {"worker_id": worker_id, "role": "LEAD", "pay_amount": pay}


def member(worker_id: int, pay: str | None = None) -> dict[str, Any]:
    return {"worker_id": worker_id, "role": "MEMBER", "pay_amount": pay}


async def job_status(client: AsyncClient, scene: Scene, job_id: int | None = None) -> str:
    response = await client.get(f"/api/v1/jobs/{job_id or scene.job_id}", headers=scene.manager)
    return str(response.json()["status"])


# --- access --------------------------------------------------------------------------


async def test_manager_endpoints_are_closed_to_workers_and_anonymous(
    client: AsyncClient, session: AsyncSession
) -> None:
    await make_worker(session, "+37491000007")
    worker = await token(client, "+37491000007")

    for url in ("/api/v1/companies", "/api/v1/sites", "/api/v1/projects", "/api/v1/jobs"):
        assert (await client.get(url)).status_code == 401
        denied = await client.get(url, headers=worker)
        assert denied.status_code == 403
        assert denied.json()["error"]["code"] == "FORBIDDEN"


# --- projects ------------------------------------------------------------------------


async def test_projects_get_sequential_references(
    client: AsyncClient, session: AsyncSession
) -> None:
    scene = await make_scene(client, session)
    second = await post(
        client,
        "/api/v1/projects",
        scene.manager,
        {"name": "Second", "site_id": scene.site_id, "service_slug": "dust-protection"},
    )
    first = (await client.get(f"/api/v1/projects/{scene.project_id}", headers=scene.manager)).json()

    year = datetime.now(UTC).year
    assert first["reference"].startswith(f"P-{year}-")
    assert int(second["reference"][-4:]) == int(first["reference"][-4:]) + 1


async def test_project_status_follows_the_transition_table(
    client: AsyncClient, session: AsyncSession
) -> None:
    scene = await make_scene(client, session)
    url = f"/api/v1/projects/{scene.project_id}"

    skip = await client.patch(url, headers=scene.manager, json={"status": "INSTALLED"})
    lost = await client.patch(url, headers=scene.manager, json={"status": "LOST"})

    assert skip.status_code == 409
    assert skip.json()["error"]["code"] == "INVALID_TRANSITION"
    assert lost.json()["status"] == "LOST"


async def test_unknown_service_and_site_are_404(client: AsyncClient, session: AsyncSession) -> None:
    scene = await make_scene(client, session)

    bad_service = await client.post(
        "/api/v1/projects",
        headers=scene.manager,
        json={"name": "X", "site_id": scene.site_id, "service_slug": "nope"},
    )
    bad_site = await client.post(
        "/api/v1/projects",
        headers=scene.manager,
        json={"name": "X", "site_id": 999, "service_slug": "safety-system"},
    )

    assert bad_service.status_code == 404
    assert bad_site.json()["error"]["details"] == {"entity": "site"}


async def test_site_pin_changes_are_audited(client: AsyncClient, session: AsyncSession) -> None:
    scene = await make_scene(client, session)

    await client.patch(
        f"/api/v1/sites/{scene.site_id}", headers=scene.manager, json={"latitude": "40.230000"}
    )

    entry = await session.scalar(select(AuditLog).where(AuditLog.action == "site.geofence_changed"))
    assert entry is not None
    assert entry.meta["latitude"] == {"before": "40.226200", "after": "40.230000"}


# --- crews and job status ------------------------------------------------------------


async def test_assigning_a_crew_schedules_the_job_and_removing_it_reverts(
    client: AsyncClient, session: AsyncSession
) -> None:
    scene = await make_scene(client, session)
    arman = await make_worker(session, "+37491000007")
    david = await make_worker(session, "+37491000011", first="David")
    visit = await make_visit(client, scene, at(0), at(8))
    assert await job_status(client, scene) == "DRAFT"

    response = await crew(client, scene, visit["id"], [lead(arman.id, "25000"), member(david.id)])

    assert response.status_code == 200, response.text
    body = response.json()
    assert [(m["worker_id"], m["role"], m["pay_amount"]) for m in body["crew"]] == [
        (arman.id, "LEAD", "25000.00"),
        (david.id, "MEMBER", None),
    ]
    assert await job_status(client, scene) == "SCHEDULED"

    await crew(client, scene, visit["id"], [])
    assert await job_status(client, scene) == "DRAFT"
    history = list(
        await session.scalars(select(JobStatusHistory.new_status).order_by(JobStatusHistory.id))
    )
    assert [h.value for h in history] == ["DRAFT", "SCHEDULED", "DRAFT"]


async def test_survey_crew_moves_the_project_to_survey(
    client: AsyncClient, session: AsyncSession
) -> None:
    scene = await make_scene(client, session, job_type="SURVEY")
    worker = await make_worker(session, "+37491000007")
    visit = await make_visit(client, scene, at(0), at(2))

    await crew(client, scene, visit["id"], [lead(worker.id)])

    project = (
        await client.get(f"/api/v1/projects/{scene.project_id}", headers=scene.manager)
    ).json()
    assert project["status"] == "SURVEY"


@pytest.mark.parametrize(
    ("members", "code"),
    [
        (lambda w: [lead(w), lead(w + 1000)], "VALIDATION_ERROR"),  # two leads
        (lambda w: [member(w)], "VALIDATION_ERROR"),  # no lead
        (lambda w: [lead(w), member(w)], "VALIDATION_ERROR"),  # listed twice
        (lambda w: [lead(999_999)], "WORKER_NOT_FOUND"),
    ],
)
async def test_invalid_crews(
    client: AsyncClient, session: AsyncSession, members: object, code: str
) -> None:
    scene = await make_scene(client, session)
    worker = await make_worker(session, "+37491000007")
    visit = await make_visit(client, scene, at(0), at(8))

    response = await crew(client, scene, visit["id"], members(worker.id))  # type: ignore[operator]

    assert response.json()["error"]["code"] == code


async def test_lead_can_be_swapped(client: AsyncClient, session: AsyncSession) -> None:
    scene = await make_scene(client, session)
    a = await make_worker(session, "+37491000007")
    b = await make_worker(session, "+37491000011")
    visit = await make_visit(client, scene, at(0), at(8))
    await crew(client, scene, visit["id"], [lead(a.id), member(b.id)])

    response = await crew(client, scene, visit["id"], [member(a.id), lead(b.id)])

    assert response.status_code == 200, response.text
    roles = {m["worker_id"]: m["role"] for m in response.json()["crew"]}
    assert roles == {a.id: "MEMBER", b.id: "LEAD"}


async def test_removed_worker_is_cancelled_and_can_come_back(
    client: AsyncClient, session: AsyncSession
) -> None:
    scene = await make_scene(client, session)
    a = await make_worker(session, "+37491000007")
    b = await make_worker(session, "+37491000011")
    visit = await make_visit(client, scene, at(0), at(8))
    await crew(client, scene, visit["id"], [lead(a.id), member(b.id)])

    removed = await crew(client, scene, visit["id"], [lead(a.id)])
    back = await crew(client, scene, visit["id"], [lead(a.id), member(b.id)])

    assert [m["worker_id"] for m in removed.json()["crew"]] == [a.id]
    assert {m["worker_id"] for m in back.json()["crew"]} == {a.id, b.id}
    rows = list(
        await session.scalars(select(VisitAssignment).where(VisitAssignment.worker_id == b.id))
    )
    assert len(rows) == 1, "the cancelled row is reused, not duplicated"


# --- double booking ------------------------------------------------------------------


async def test_double_booking_is_rejected(client: AsyncClient, session: AsyncSession) -> None:
    scene = await make_scene(client, session)
    worker = await make_worker(session, "+37491000007")
    other_job = await post(
        client,
        "/api/v1/jobs",
        scene.manager,
        {"project_id": scene.project_id, "job_type": "INSPECTION", "title": "Inspection"},
    )
    morning = await make_visit(client, scene, at(0), at(4))
    overlapping = await make_visit(client, scene, at(3), at(6), job_id=other_job["id"])
    afterwards = await make_visit(client, scene, at(4), at(6), job_id=other_job["id"])
    await crew(client, scene, morning["id"], [lead(worker.id)])

    clash = await crew(client, scene, overlapping["id"], [lead(worker.id)])
    adjacent = await crew(client, scene, afterwards["id"], [lead(worker.id)])

    assert clash.status_code == 409
    error = clash.json()["error"]
    assert error["code"] == "WORKER_ALREADY_BOOKED"
    assert error["details"]["conflicting_visit_id"] == morning["id"]
    assert adjacent.status_code == 200, "back-to-back visits ([) ranges) don't overlap"


async def test_database_constraint_blocks_overlap_even_without_the_service(
    client: AsyncClient, session: AsyncSession
) -> None:
    scene = await make_scene(client, session)
    worker = await make_worker(session, "+37491000007")
    a = await make_visit(client, scene, at(0), at(4))
    b = await make_visit(client, scene, at(2), at(6))
    period = Range(at(0), at(4), bounds="[)")
    session.add(
        VisitAssignment(
            visit_id=a["id"], worker_id=worker.id, role=AssignmentRole.LEAD, period=period
        )
    )
    await session.commit()

    session.add(
        VisitAssignment(
            visit_id=b["id"],
            worker_id=worker.id,
            role=AssignmentRole.LEAD,
            period=Range(at(2), at(6), bounds="[)"),
        )
    )
    with pytest.raises(IntegrityError, match="no_worker_overlap"):
        await session.commit()
    await session.rollback()


async def test_moving_a_visit_moves_the_crew_and_rechecks_bookings(
    client: AsyncClient, session: AsyncSession
) -> None:
    scene = await make_scene(client, session)
    worker = await make_worker(session, "+37491000007")
    today = await make_visit(client, scene, at(0), at(8))
    tomorrow = await make_visit(client, scene, at(0, day=1), at(8, day=1))
    await crew(client, scene, today["id"], [lead(worker.id)])
    await crew(client, scene, tomorrow["id"], [lead(worker.id)])

    clash = await client.patch(
        f"/api/v1/visits/{tomorrow['id']}",
        headers=scene.manager,
        json={"starts_at": iso(at(6)), "ends_at": iso(at(10))},
    )
    moved = await client.patch(
        f"/api/v1/visits/{tomorrow['id']}",
        headers=scene.manager,
        json={"starts_at": iso(at(1, day=2)), "ends_at": iso(at(5, day=2))},
    )

    assert clash.json()["error"]["code"] == "WORKER_ALREADY_BOOKED"
    assert moved.status_code == 200
    row = await session.scalar(
        select(VisitAssignment).where(VisitAssignment.visit_id == tomorrow["id"])
    )
    assert row is not None and row.period.lower == at(1, day=2)


async def test_visit_times_are_validated(client: AsyncClient, session: AsyncSession) -> None:
    scene = await make_scene(client, session)

    backwards = await client.post(
        f"/api/v1/jobs/{scene.job_id}/visits",
        headers=scene.manager,
        json={"starts_at": iso(at(8)), "ends_at": iso(at(0))},
    )
    naive = await client.post(
        f"/api/v1/jobs/{scene.job_id}/visits",
        headers=scene.manager,
        json={"starts_at": "2026-10-12T09:00:00", "ends_at": "2026-10-12T17:00:00"},
    )

    assert backwards.status_code == 422
    assert naive.status_code == 422, "times without a timezone are rejected"


# --- cancellation, pay, schedule ----------------------------------------------------


async def test_cancelling_a_job_cancels_visits_and_assignments(
    client: AsyncClient, session: AsyncSession
) -> None:
    scene = await make_scene(client, session)
    worker = await make_worker(session, "+37491000007")
    visit = await make_visit(client, scene, at(0), at(8))
    await crew(client, scene, visit["id"], [lead(worker.id)])

    response = await client.post(
        f"/api/v1/jobs/{scene.job_id}/cancel",
        headers=scene.manager,
        json={"reason": "Client postponed"},
    )

    assert response.json()["status"] == "CANCELLED"
    detail = (await client.get(f"/api/v1/jobs/{scene.job_id}", headers=scene.manager)).json()
    assert detail["visits"][0]["status"] == "CANCELLED"
    assert detail["visits"][0]["crew"] == []
    again = await crew(client, scene, visit["id"], [lead(worker.id)])
    assert again.json()["error"]["code"] == "VISIT_NOT_PLANNED"


async def test_pay_changes_are_audited_and_locked_after_review(
    client: AsyncClient, session: AsyncSession
) -> None:
    scene = await make_scene(client, session)
    worker = await make_worker(session, "+37491000007")
    visit = await make_visit(client, scene, at(0), at(8))
    await crew(client, scene, visit["id"], [lead(worker.id, "20000")])

    await crew(client, scene, visit["id"], [lead(worker.id, "25000")])
    await session.execute(update(VisitAssignment).values(reviewed_at=at(10)))
    await session.commit()
    locked = await crew(client, scene, visit["id"], [lead(worker.id, "30000")])

    entry = await session.scalar(
        select(AuditLog).where(AuditLog.action == "assignment.pay_changed")
    )
    assert entry is not None and entry.meta == {"before": "20000.00", "after": "25000"}
    assert locked.json()["error"]["code"] == "ASSIGNMENT_REVIEWED"


async def test_schedule_lists_assignments_in_range(
    client: AsyncClient, session: AsyncSession
) -> None:
    scene = await make_scene(client, session)
    arman = await make_worker(session, "+37491000007")
    david = await make_worker(session, "+37491000011", first="David")
    today = await make_visit(client, scene, at(0), at(8))
    next_week = await make_visit(client, scene, at(0, day=7), at(8, day=7))
    await crew(client, scene, today["id"], [lead(arman.id), member(david.id)])
    await crew(client, scene, next_week["id"], [lead(arman.id)])

    response = await client.get(
        "/api/v1/schedule",
        headers=scene.manager,
        params={"from": iso(at(-5)), "to": iso(at(19)), "worker_id": arman.id},
    )

    entries = response.json()
    assert [(e["visit_id"], e["role"], e["job_title"]) for e in entries] == [
        (today["id"], "LEAD", "Install Safety Net")
    ]


async def test_manager_role_is_required_even_for_admins_listing(
    client: AsyncClient, session: AsyncSession
) -> None:
    await make_user(session, "+37491000002", UserRole.ADMIN)
    admin = await token(client, "+37491000002")

    assert (await client.get("/api/v1/jobs", headers=admin)).status_code == 200
