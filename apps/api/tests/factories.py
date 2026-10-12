"""Test data helpers: real rows through the real services."""

from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from typing import Any

from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.users.models import User, UserRole, Worker
from app.modules.users.service import create_user, get_worker_for_user

PASSWORD = "first-pass-123"

# Today 09:00-17:00 Yerevan (UTC+4), as UTC.
DAY = datetime(2026, 10, 12, 5, 0, tzinfo=UTC)


def at(hours: float, day: int = 0) -> datetime:
    return DAY + timedelta(days=day, hours=hours)


def iso(dt: datetime) -> str:
    return dt.isoformat()


async def make_user(
    session: AsyncSession, phone: str, role: UserRole, first: str = "Arman", last: str = "Test"
) -> User:
    return await create_user(
        session,
        phone=phone,
        password=PASSWORD,
        first_name=first,
        last_name=last,
        role=role,
        must_change_password=False,
        employee_code=f"NEST-{phone[-4:]}" if role is UserRole.WORKER else None,
    )


async def make_worker(session: AsyncSession, phone: str, first: str = "Arman") -> Worker:
    user = await make_user(session, phone, UserRole.WORKER, first=first)
    worker = await get_worker_for_user(session, user.id)
    assert worker is not None
    return worker


async def token(client: AsyncClient, phone: str) -> dict[str, str]:
    response = await client.post("/api/v1/auth/login", json={"phone": phone, "password": PASSWORD})
    assert response.status_code == 200, response.text
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


@dataclass
class Scene:
    """A manager, a site, a project and a job, ready for visits."""

    manager: dict[str, str]
    site_id: int
    project_id: int
    job_id: int


async def post(client: AsyncClient, url: str, headers: dict[str, str], body: Any) -> Any:
    response = await client.post(url, headers=headers, json=body)
    assert response.status_code in (200, 201), response.text
    return response.json()


async def make_scene(
    client: AsyncClient, session: AsyncSession, job_type: str = "INSTALLATION"
) -> Scene:
    await make_user(session, "+37491000001", UserRole.MANAGER, first="Mane")
    manager = await token(client, "+37491000001")
    company = await post(client, "/api/v1/companies", manager, {"name": "Arm Build LLC"})
    site = await post(
        client,
        "/api/v1/sites",
        manager,
        {
            "company_id": company["id"],
            "name": "Building A",
            "address": "Davtashen 3rd district, Yerevan",
            "latitude": "40.226200",
            "longitude": "44.493000",
            "geofence_radius_m": 150,
            "location_confirmed": True,
        },
    )
    project = await post(
        client,
        "/api/v1/projects",
        manager,
        {
            "name": "Davtashen Residential",
            "site_id": site["id"],
            "company_id": company["id"],
            "service_slug": "safety-system",
        },
    )
    job = await post(
        client,
        "/api/v1/jobs",
        manager,
        {"project_id": project["id"], "job_type": job_type, "title": "Install Safety Net"},
    )
    return Scene(manager, site["id"], project["id"], job["id"])


async def make_visit(
    client: AsyncClient, scene: Scene, start: datetime, end: datetime, job_id: int | None = None
) -> Any:
    return await post(
        client,
        f"/api/v1/jobs/{job_id or scene.job_id}/visits",
        scene.manager,
        {"starts_at": iso(start), "ends_at": iso(end)},
    )
