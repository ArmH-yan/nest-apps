"""Authentication and role dependencies for routers (ARCHITECTURE §7, §30).

    CurrentAuth          signed-in, active user who has set their own password
    PasswordChangeAuth   also allows `must_change_password` users (only for
                         /me, /auth/change-password and /auth/logout)
    require_roles(...)   role check on top of CurrentAuth → 403

Object-level authorization (`WHERE worker_id = :me`) belongs in each service query.
"""

import uuid
from collections.abc import Awaitable, Callable
from dataclasses import dataclass
from http import HTTPStatus
from typing import Annotated

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.security import InvalidTokenError, decode_access_token
from app.db.session import get_session
from app.modules.users.models import User, UserRole

# auto_error=False: missing credentials go through our own error format.
_bearer = HTTPBearer(auto_error=False)


@dataclass(frozen=True)
class AuthContext:
    user: User
    # Refresh-token family of this session, e.g. to keep it on password change.
    family_id: uuid.UUID


def _unauthorized(code: str, message: str) -> AppError:
    return AppError(code, message, status_code=HTTPStatus.UNAUTHORIZED)


async def _authenticate(
    session: Annotated[AsyncSession, Depends(get_session)],
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
) -> AuthContext:
    if credentials is None:
        raise _unauthorized("NOT_AUTHENTICATED", "Sign in to continue.")
    try:
        claims = decode_access_token(credentials.credentials)
    except InvalidTokenError as exc:
        if exc.expired:
            raise _unauthorized("TOKEN_EXPIRED", "The access token has expired.") from exc
        raise _unauthorized("INVALID_TOKEN", "The access token is not valid.") from exc

    user = await session.get(User, claims.user_id)
    if user is None:
        raise _unauthorized("INVALID_TOKEN", "The access token is not valid.")
    if not user.is_active:
        raise _unauthorized("ACCOUNT_DISABLED", "This account has been deactivated.")
    return AuthContext(user=user, family_id=claims.family_id)


PasswordChangeAuth = Annotated[AuthContext, Depends(_authenticate)]


async def _require_password_changed(auth: PasswordChangeAuth) -> AuthContext:
    if auth.user.must_change_password:
        raise AppError(
            "PASSWORD_CHANGE_REQUIRED",
            "Set a new password before continuing.",
            status_code=HTTPStatus.FORBIDDEN,
        )
    return auth


CurrentAuth = Annotated[AuthContext, Depends(_require_password_changed)]


def require_roles(*roles: UserRole) -> Callable[[AuthContext], Awaitable[AuthContext]]:
    """`Depends(require_roles(UserRole.MANAGER, UserRole.ADMIN))`."""

    async def dependency(auth: CurrentAuth) -> AuthContext:
        if auth.user.role not in roles:
            raise AppError(
                "FORBIDDEN",
                "You do not have access to this resource.",
                status_code=HTTPStatus.FORBIDDEN,
            )
        return auth

    return dependency
