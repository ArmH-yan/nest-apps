"""Authentication, token rotation/reuse detection, roles and audit (ARCHITECTURE §7, §30, §31)."""

import uuid
from collections.abc import Awaitable, Callable
from datetime import UTC, datetime, timedelta
from typing import Any

import pytest
from fastapi import Depends, FastAPI
from httpx import AsyncClient
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.security import AccessClaims, create_access_token
from app.modules.audit.models import AuditLog
from app.modules.auth.dependencies import AuthContext, CurrentAuth, require_roles
from app.modules.auth.models import RefreshToken
from app.modules.users.models import User, UserRole
from app.modules.users.service import create_user

PASSWORD = "first-pass-123"
PHONE = "+37491000007"

MakeUser = Callable[..., Awaitable[User]]


@pytest.fixture
def make_user(session: AsyncSession) -> MakeUser:
    async def make(
        *,
        phone: str = PHONE,
        role: UserRole = UserRole.WORKER,
        must_change_password: bool = False,
        email: str | None = None,
    ) -> User:
        return await create_user(
            session,
            phone=phone,
            password=PASSWORD,
            first_name="Arman",
            last_name="Harutyunyan",
            role=role,
            email=email,
            must_change_password=must_change_password,
            employee_code=f"NEST-{phone[-3:]}" if role is UserRole.WORKER else None,
        )

    return make


@pytest.fixture
def app_with_probes(app: FastAPI) -> FastAPI:
    @app.get("/_test/protected")
    async def protected(auth: CurrentAuth) -> dict[str, int]:
        return {"user_id": auth.user.id}

    @app.get("/_test/managers")
    async def managers(
        auth: AuthContext = Depends(require_roles(UserRole.MANAGER, UserRole.ADMIN)),  # noqa: B008
    ) -> dict[str, str]:
        return {"role": auth.user.role.value}

    return app


async def login(client: AsyncClient, phone: str = PHONE, password: str = PASSWORD) -> Any:
    return await client.post("/api/v1/auth/login", json={"phone": phone, "password": password})


def bearer(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


async def actions(session: AsyncSession) -> list[str]:
    rows = await session.scalars(select(AuditLog.action).order_by(AuditLog.id))
    return list(rows)


# --- login -------------------------------------------------------------------------


async def test_login_returns_tokens_and_worker_profile(
    client: AsyncClient, make_user: MakeUser, session: AsyncSession
) -> None:
    await make_user()

    response = await login(client, phone="+374 91 00-00-07")  # formatting is normalized

    assert response.status_code == 200
    body = response.json()
    assert body["token_type"] == "bearer"
    assert body["expires_in"] == 15 * 60
    assert body["access_token"] and body["refresh_token"]
    assert body["user"]["full_name"] == "Arman Harutyunyan"
    assert body["user"]["role"] == "WORKER"
    assert body["user"]["worker"]["employee_code"] == "NEST-007"
    assert await actions(session) == ["user.created", "auth.login"]


async def test_password_is_hashed_with_argon2id(make_user: MakeUser) -> None:
    user = await make_user()

    assert user.password_hash.startswith("$argon2id$")
    assert PASSWORD not in user.password_hash


async def test_login_by_email(client: AsyncClient, make_user: MakeUser) -> None:
    await make_user(role=UserRole.MANAGER, email="Manager@Nest.am")

    response = await client.post(
        "/api/v1/auth/login", json={"email": "manager@nest.am", "password": PASSWORD}
    )

    assert response.status_code == 200
    assert response.json()["user"]["worker"] is None


@pytest.mark.parametrize(
    "body",
    [
        {"password": PASSWORD},
        {"phone": PHONE, "email": "a@nest.am", "password": PASSWORD},
    ],
)
async def test_login_needs_exactly_one_identifier(
    client: AsyncClient, body: dict[str, str]
) -> None:
    response = await client.post("/api/v1/auth/login", json=body)

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


async def test_wrong_password_and_unknown_phone_look_the_same(
    client: AsyncClient, make_user: MakeUser, session: AsyncSession
) -> None:
    await make_user()

    wrong = await login(client, password="nope-nope")
    unknown = await login(client, phone="+37499999999")

    for response in (wrong, unknown):
        assert response.status_code == 401
        assert response.json()["error"]["code"] == "INVALID_CREDENTIALS"
    assert (await actions(session)).count("auth.login_failed") == 2


async def test_login_is_rate_limited_per_identifier(
    client: AsyncClient, make_user: MakeUser
) -> None:
    await make_user()
    for _ in range(5):
        assert (await login(client, password="wrong-wrong")).status_code == 401

    blocked = await login(client)  # even the right password

    assert blocked.status_code == 429
    assert blocked.json()["error"]["code"] == "TOO_MANY_LOGIN_ATTEMPTS"
    # another phone is not affected
    await make_user(phone="+37491000011")
    assert (await login(client, phone="+37491000011")).status_code == 200


async def test_deactivated_user_cannot_log_in_or_use_tokens(
    client: AsyncClient, make_user: MakeUser, session: AsyncSession
) -> None:
    user = await make_user()
    access = (await login(client)).json()["access_token"]

    await session.execute(update(User).where(User.id == user.id).values(is_active=False))
    await session.commit()

    response = await login(client)
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "ACCOUNT_DISABLED"
    me = await client.get("/api/v1/me", headers=bearer(access))
    assert me.status_code == 401
    assert me.json()["error"]["code"] == "ACCOUNT_DISABLED"


# --- access tokens -----------------------------------------------------------------


async def test_me_requires_a_valid_token(client: AsyncClient, make_user: MakeUser) -> None:
    user = await make_user()
    expired = create_access_token(
        AccessClaims(user_id=user.id, role="WORKER", family_id=uuid.uuid4()),
        now=datetime.now(UTC) - timedelta(hours=1),
    )

    cases = {
        "NOT_AUTHENTICATED": {},
        "INVALID_TOKEN": bearer("not-a-jwt"),
        "TOKEN_EXPIRED": bearer(expired),
    }
    for code, headers in cases.items():
        response = await client.get("/api/v1/me", headers=headers)
        assert response.status_code == 401, code
        assert response.json()["error"]["code"] == code


async def test_me_returns_the_signed_in_user(client: AsyncClient, make_user: MakeUser) -> None:
    await make_user()
    access = (await login(client)).json()["access_token"]

    response = await client.get("/api/v1/me", headers=bearer(access))

    assert response.status_code == 200
    assert response.json()["phone"] == PHONE


# --- refresh rotation ------------------------------------------------------------


async def refresh(client: AsyncClient, token: str) -> Any:
    return await client.post("/api/v1/auth/refresh", json={"refresh_token": token})


async def test_refresh_rotates_the_token(client: AsyncClient, make_user: MakeUser) -> None:
    await make_user()
    first = (await login(client)).json()

    rotated = await refresh(client, first["refresh_token"])

    assert rotated.status_code == 200
    second = rotated.json()
    assert second["refresh_token"] != first["refresh_token"]
    me = await client.get("/api/v1/me", headers=bearer(second["access_token"]))
    assert me.status_code == 200


async def test_reusing_a_rotated_token_revokes_the_whole_family(
    client: AsyncClient, make_user: MakeUser, session: AsyncSession
) -> None:
    await make_user()
    first = (await login(client)).json()["refresh_token"]
    second = (await refresh(client, first)).json()["refresh_token"]

    reuse = await refresh(client, first)  # e.g. a stolen copy

    assert reuse.status_code == 401
    assert reuse.json()["error"]["code"] == "REFRESH_TOKEN_REUSED"
    # the legitimate latest token is dead too
    assert (await refresh(client, second)).json()["error"]["code"] == "REFRESH_TOKEN_REUSED"
    assert "auth.refresh_token_reused" in await actions(session)


async def test_unknown_and_expired_refresh_tokens(
    client: AsyncClient, make_user: MakeUser, session: AsyncSession
) -> None:
    await make_user()
    token = (await login(client)).json()["refresh_token"]
    await session.execute(
        update(RefreshToken).values(expires_at=datetime.now(UTC) - timedelta(seconds=1))
    )
    await session.commit()

    assert (await refresh(client, "made-up")).json()["error"]["code"] == "INVALID_REFRESH_TOKEN"
    assert (await refresh(client, token)).json()["error"]["code"] == "REFRESH_TOKEN_EXPIRED"


async def test_logout_revokes_every_session(client: AsyncClient, make_user: MakeUser) -> None:
    await make_user()
    phone_a = (await login(client)).json()
    phone_b = (await login(client)).json()

    response = await client.post("/api/v1/auth/logout", headers=bearer(phone_a["access_token"]))

    assert response.status_code == 204
    for tokens in (phone_a, phone_b):
        assert (await refresh(client, tokens["refresh_token"])).status_code == 401


# --- password change ---------------------------------------------------------------


async def test_first_login_must_change_password(
    client: AsyncClient, app_with_probes: FastAPI, make_user: MakeUser, session: AsyncSession
) -> None:
    await make_user(must_change_password=True)
    other_device = (await login(client)).json()
    tokens = (await login(client)).json()
    assert tokens["user"]["must_change_password"] is True
    headers = bearer(tokens["access_token"])

    # /me works, everything else is blocked
    assert (await client.get("/api/v1/me", headers=headers)).status_code == 200
    blocked = await client.get("/_test/protected", headers=headers)
    assert blocked.status_code == 403
    assert blocked.json()["error"]["code"] == "PASSWORD_CHANGE_REQUIRED"

    changed = await client.post(
        "/api/v1/auth/change-password",
        headers=headers,
        json={"current_password": PASSWORD, "new_password": "my-own-pass-9"},
    )

    assert changed.status_code == 204
    assert (await client.get("/_test/protected", headers=headers)).status_code == 200
    # this session continues; other sessions are signed out
    assert (await refresh(client, tokens["refresh_token"])).status_code == 200
    assert (await refresh(client, other_device["refresh_token"])).status_code == 401
    assert (await login(client, password="my-own-pass-9")).status_code == 200
    assert "auth.password_changed" in await actions(session)


@pytest.mark.parametrize(
    ("current", "new", "status", "code"),
    [
        ("wrong-current", "my-own-pass-9", 400, "INVALID_CREDENTIALS"),
        (PASSWORD, PASSWORD, 400, "PASSWORD_UNCHANGED"),
        (PASSWORD, "short", 422, "VALIDATION_ERROR"),
    ],
)
async def test_change_password_errors(
    client: AsyncClient, make_user: MakeUser, current: str, new: str, status: int, code: str
) -> None:
    await make_user()
    access = (await login(client)).json()["access_token"]

    response = await client.post(
        "/api/v1/auth/change-password",
        headers=bearer(access),
        json={"current_password": current, "new_password": new},
    )

    assert response.status_code == status
    assert response.json()["error"]["code"] == code


# --- roles and accounts ------------------------------------------------------------


async def test_roles_are_enforced(
    client: AsyncClient, app_with_probes: FastAPI, make_user: MakeUser
) -> None:
    await make_user()
    await make_user(phone="+37491000001", role=UserRole.MANAGER)
    worker = (await login(client)).json()["access_token"]
    manager = (await login(client, phone="+37491000001")).json()["access_token"]

    denied = await client.get("/_test/managers", headers=bearer(worker))
    allowed = await client.get("/_test/managers", headers=bearer(manager))

    assert denied.status_code == 403
    assert denied.json()["error"]["code"] == "FORBIDDEN"
    assert allowed.json() == {"role": "MANAGER"}


async def test_create_user_rules(make_user: MakeUser, session: AsyncSession) -> None:
    await make_user()

    with pytest.raises(AppError) as duplicate:
        await make_user()
    assert duplicate.value.code == "USER_ALREADY_EXISTS"

    with pytest.raises(AppError) as no_code:
        await create_user(
            session,
            phone="+37491000099",
            password=PASSWORD,
            first_name="A",
            last_name="B",
            role=UserRole.WORKER,
        )
    assert no_code.value.code == "EMPLOYEE_CODE_REQUIRED"

    with pytest.raises(AppError) as bad_phone:
        await make_user(phone="call me")
    assert bad_phone.value.code == "INVALID_PHONE"
