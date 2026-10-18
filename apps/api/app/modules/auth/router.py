from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Request, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError, error_response
from app.db.session import get_session
from app.modules.auth import service
from app.modules.auth.cookies import (
    CSRF_COOKIE,
    REFRESH_COOKIE,
    check_csrf,
    clear_session_cookies,
    set_session_cookies,
)
from app.modules.auth.dependencies import PasswordChangeAuth
from app.modules.auth.schemas import (
    ChangePasswordRequest,
    LoginRequest,
    LoginResponse,
    RefreshRequest,
    TokenResponse,
)
from app.modules.users.models import UserRole
from app.modules.users.schemas import MeResponse
from app.modules.users.service import get_worker_for_user

router = APIRouter(prefix="/auth", tags=["auth"])

Session = Annotated[AsyncSession, Depends(get_session)]


def _client(request: Request, device_id: str | None = None) -> service.ClientInfo:
    return service.ClientInfo(
        ip=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent"),
        device_id=device_id,
    )


@router.post("/login")
async def login(body: LoginRequest, request: Request, session: Session) -> LoginResponse:
    """Phone (or email) + password → access + refresh token. Bearer tokens for the
    worker app; the manager app's HttpOnly-cookie variant comes with Phase 3."""
    user, tokens = await service.login(
        session,
        phone=body.phone,
        email=body.email,
        password=body.password,
        client=_client(request, body.device_id),
    )
    worker = await get_worker_for_user(session, user.id)
    return LoginResponse(
        access_token=tokens.access_token,
        refresh_token=tokens.refresh_token,
        expires_in=tokens.expires_in,
        user=MeResponse.build(user, worker),
    )


@router.post("/refresh")
async def refresh(body: RefreshRequest, request: Request, session: Session) -> TokenResponse:
    tokens = await service.refresh(session, body.refresh_token, _client(request))
    return TokenResponse(
        access_token=tokens.access_token,
        refresh_token=tokens.refresh_token,
        expires_in=tokens.expires_in,
    )


@router.post("/logout", status_code=HTTPStatus.NO_CONTENT)
async def logout(auth: PasswordChangeAuth, request: Request, session: Session) -> Response:
    await service.logout(session, auth.user, _client(request))
    return Response(status_code=HTTPStatus.NO_CONTENT)


@router.post("/change-password", status_code=HTTPStatus.NO_CONTENT)
async def change_password(
    body: ChangePasswordRequest, auth: PasswordChangeAuth, request: Request, session: Session
) -> Response:
    await service.change_password(
        session,
        auth.user,
        current_password=body.current_password,
        new_password=body.new_password,
        keep_family_id=auth.family_id,
        client=_client(request),
    )
    return Response(status_code=HTTPStatus.NO_CONTENT)


# --- manager web app: HttpOnly cookies + CSRF (§7, app/modules/auth/cookies.py) ---------

_WEB_ROLES = frozenset({UserRole.MANAGER, UserRole.ADMIN})


@router.post("/web/login")
async def web_login(
    body: LoginRequest, request: Request, response: Response, session: Session
) -> MeResponse:
    """Same credentials as /auth/login; tokens go into cookies, never into the body."""
    user, tokens = await service.login(
        session,
        phone=body.phone,
        email=body.email,
        password=body.password,
        client=_client(request, body.device_id),
        roles=_WEB_ROLES,
    )
    set_session_cookies(
        response, access_token=tokens.access_token, refresh_token=tokens.refresh_token
    )
    return MeResponse.build(user, None)


@router.post("/web/refresh", status_code=HTTPStatus.NO_CONTENT)
async def web_refresh(request: Request, session: Session) -> Response:
    check_csrf(request)
    raw = request.cookies.get(REFRESH_COOKIE)
    if not raw:
        raise AppError(
            "INVALID_REFRESH_TOKEN", "Sign in again.", status_code=HTTPStatus.UNAUTHORIZED
        )
    try:
        tokens = await service.refresh(session, raw, _client(request))
    except AppError as exc:
        # The session is over: answer with the error AND drop the dead cookies.
        failed = error_response(exc.status_code, exc.code, exc.message, exc.details)
        clear_session_cookies(failed)
        return failed
    response = Response(status_code=HTTPStatus.NO_CONTENT)
    set_session_cookies(
        response,
        access_token=tokens.access_token,
        refresh_token=tokens.refresh_token,
        csrf_token=request.cookies.get(CSRF_COOKIE),
    )
    return response


@router.post("/web/logout", status_code=HTTPStatus.NO_CONTENT)
async def web_logout(auth: PasswordChangeAuth, request: Request, session: Session) -> Response:
    await service.logout(session, auth.user, _client(request))
    response = Response(status_code=HTTPStatus.NO_CONTENT)
    clear_session_cookies(response)
    return response
