from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Request, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.modules.auth import service
from app.modules.auth.dependencies import PasswordChangeAuth
from app.modules.auth.schemas import (
    ChangePasswordRequest,
    LoginRequest,
    LoginResponse,
    RefreshRequest,
    TokenResponse,
)
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
