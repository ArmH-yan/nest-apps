"""Worker management (§20 Workers): create, list, edit, deactivate, reset password."""

from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.users.models import UserRole
from tests.factories import make_user, token

NEW = {
    "phone": "+374 99 123 456",
    "first_name": "Ravi",
    "last_name": "Kumar",
    "employee_code": "NEST-021",
    "initial_password": "temporary-1",
    "locale": "hi",
    "skills": ["safety_net"],
}


async def manager(client: AsyncClient, session: AsyncSession) -> dict[str, str]:
    await make_user(session, "+37491000001", UserRole.MANAGER)
    return await token(client, "+37491000001")


async def test_create_list_and_first_login(client: AsyncClient, session: AsyncSession) -> None:
    headers = await manager(client, session)

    created = await client.post("/api/v1/workers", headers=headers, json=NEW)
    duplicate = await client.post("/api/v1/workers", headers=headers, json=NEW)
    listed = await client.get("/api/v1/workers", headers=headers, params={"q": "ravi"})
    login = await client.post(
        "/api/v1/auth/login", json={"phone": "+37499123456", "password": "temporary-1"}
    )

    assert created.status_code == 201, created.text
    body = created.json()
    assert (body["phone"], body["locale"], body["skills"]) == ("+37499123456", "hi", ["safety_net"])
    assert body["must_change_password"] is True
    assert duplicate.json()["error"]["code"] == "USER_ALREADY_EXISTS"
    assert [w["employee_code"] for w in listed.json()] == ["NEST-021"]
    assert login.json()["user"]["must_change_password"] is True


async def test_deactivating_signs_the_worker_out(
    client: AsyncClient, session: AsyncSession
) -> None:
    headers = await manager(client, session)
    worker = (await client.post("/api/v1/workers", headers=headers, json=NEW)).json()
    login = await client.post(
        "/api/v1/auth/login", json={"phone": "+37499123456", "password": "temporary-1"}
    )

    off = await client.patch(
        f"/api/v1/workers/{worker['id']}", headers=headers, json={"is_active": False}
    )
    refresh = await client.post(
        "/api/v1/auth/refresh", json={"refresh_token": login.json()["refresh_token"]}
    )
    inactive = await client.get("/api/v1/workers", headers=headers, params={"active": False})

    assert off.json()["is_active"] is False
    assert refresh.status_code in (401, 403)
    assert [w["id"] for w in inactive.json()] == [worker["id"]]


async def test_reset_password_forces_a_change(client: AsyncClient, session: AsyncSession) -> None:
    headers = await manager(client, session)
    worker = (await client.post("/api/v1/workers", headers=headers, json=NEW)).json()

    reset = await client.post(
        f"/api/v1/workers/{worker['id']}/reset-password",
        headers=headers,
        json={"new_password": "another-temp-2"},
    )
    old = await client.post(
        "/api/v1/auth/login", json={"phone": "+37499123456", "password": "temporary-1"}
    )
    new = await client.post(
        "/api/v1/auth/login", json={"phone": "+37499123456", "password": "another-temp-2"}
    )

    assert reset.status_code == 204
    assert old.status_code == 401
    assert new.json()["user"]["must_change_password"] is True


async def test_workers_cannot_manage_workers(client: AsyncClient, session: AsyncSession) -> None:
    await make_user(session, "+37491000007", UserRole.WORKER)
    worker = await token(client, "+37491000007")

    assert (await client.get("/api/v1/workers", headers=worker)).status_code == 403
