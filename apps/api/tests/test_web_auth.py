"""Manager web sessions: HttpOnly cookies + double-submit CSRF (ARCHITECTURE §7)."""

from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.auth.cookies import ACCESS_COOKIE, CSRF_COOKIE, CSRF_HEADER, REFRESH_COOKIE
from app.modules.users.models import UserRole
from tests.factories import PASSWORD, make_user

MANAGER = "+37491000001"


async def web_login(client: AsyncClient, phone: str = MANAGER) -> object:
    return await client.post("/api/v1/auth/web/login", json={"phone": phone, "password": PASSWORD})


def csrf(client: AsyncClient) -> dict[str, str]:
    return {CSRF_HEADER: client.cookies[CSRF_COOKIE]}


async def test_web_login_sets_httponly_cookies_and_no_tokens_in_body(
    client: AsyncClient, session: AsyncSession
) -> None:
    await make_user(session, MANAGER, UserRole.MANAGER)

    response = await client.post(
        "/api/v1/auth/web/login", json={"phone": MANAGER, "password": PASSWORD}
    )

    assert response.status_code == 200, response.text
    assert response.json()["role"] == "MANAGER"
    assert "access_token" not in response.text
    set_cookie = response.headers.get_list("set-cookie")
    by_name = {c.split("=", 1)[0]: c for c in set_cookie}
    assert "HttpOnly" in by_name[ACCESS_COOKIE]
    assert "HttpOnly" in by_name[REFRESH_COOKIE]
    assert "Path=/api/v1/auth/web" in by_name[REFRESH_COOKIE]
    assert "HttpOnly" not in by_name[CSRF_COOKIE], "the page must be able to read it"
    assert all("SameSite=lax" in c for c in set_cookie)


async def test_cookie_session_reads_freely_but_writes_need_csrf(
    client: AsyncClient, session: AsyncSession
) -> None:
    await make_user(session, MANAGER, UserRole.MANAGER)
    await web_login(client)

    me = await client.get("/api/v1/me")
    no_token = await client.post("/api/v1/companies", json={"name": "Arm Build"})
    wrong = await client.post(
        "/api/v1/companies", json={"name": "Arm Build"}, headers={CSRF_HEADER: "nope"}
    )
    ok = await client.post("/api/v1/companies", json={"name": "Arm Build"}, headers=csrf(client))

    assert me.status_code == 200
    assert no_token.status_code == 403
    assert no_token.json()["error"]["code"] == "CSRF_FAILED"
    assert wrong.json()["error"]["code"] == "CSRF_FAILED"
    assert ok.status_code == 201


async def test_workers_cannot_use_the_web_app(client: AsyncClient, session: AsyncSession) -> None:
    await make_user(session, "+37491000007", UserRole.WORKER)

    response = await web_login(client, "+37491000007")

    assert response.status_code == 403  # type: ignore[attr-defined]
    assert response.json()["error"]["code"] == "NOT_A_MANAGER"  # type: ignore[attr-defined]
    assert ACCESS_COOKIE not in client.cookies


async def test_web_refresh_rotates_and_logout_clears(
    client: AsyncClient, session: AsyncSession
) -> None:
    await make_user(session, MANAGER, UserRole.MANAGER)
    await web_login(client)
    first_refresh = client.cookies[REFRESH_COOKIE]
    token = client.cookies[CSRF_COOKIE]

    refreshed = await client.post("/api/v1/auth/web/refresh", headers=csrf(client))

    assert refreshed.status_code == 204
    assert client.cookies[REFRESH_COOKIE] != first_refresh
    assert client.cookies[CSRF_COOKIE] == token, "CSRF token survives a refresh"

    out = await client.post("/api/v1/auth/web/logout", headers=csrf(client))
    assert out.status_code == 204
    assert ACCESS_COOKIE not in client.cookies
    assert (await client.get("/api/v1/me")).status_code == 401


async def test_reused_refresh_cookie_is_rejected_and_cleared(
    client: AsyncClient, session: AsyncSession
) -> None:
    await make_user(session, MANAGER, UserRole.MANAGER)
    await web_login(client)
    stale = client.cookies[REFRESH_COOKIE]
    headers = csrf(client)
    await client.post("/api/v1/auth/web/refresh", headers=headers)

    client.cookies.set(REFRESH_COOKIE, stale, path="/api/v1/auth/web")
    reuse = await client.post("/api/v1/auth/web/refresh", headers=headers)

    assert reuse.status_code == 401
    assert reuse.json()["error"]["code"] == "REFRESH_TOKEN_REUSED"
    assert any(
        c.startswith(f"{ACCESS_COOKIE}=") and "Max-Age=0" in c
        for c in reuse.headers.get_list("set-cookie")
    )


async def test_bearer_clients_need_no_csrf(client: AsyncClient, session: AsyncSession) -> None:
    await make_user(session, MANAGER, UserRole.MANAGER)
    login = await client.post("/api/v1/auth/login", json={"phone": MANAGER, "password": PASSWORD})
    client.cookies.clear()

    created = await client.post(
        "/api/v1/companies",
        json={"name": "Elite Group"},
        headers={"Authorization": f"Bearer {login.json()['access_token']}"},
    )

    assert created.status_code == 201
