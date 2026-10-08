"""Login, refresh-token rotation, logout and password change (ARCHITECTURE §7).

Every function owns its transaction and writes its audit entry in it (§31).
"""

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from http import HTTPStatus

from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.errors import AppError
from app.core.security import (
    AccessClaims,
    create_access_token,
    hash_password,
    hash_refresh_token,
    new_refresh_token,
    password_needs_rehash,
    verify_password,
)
from app.modules.audit import service as audit
from app.modules.audit.models import AuditLog
from app.modules.auth.models import RefreshToken
from app.modules.users.models import User
from app.modules.users.service import normalize_email, normalize_phone


@dataclass(frozen=True)
class ClientInfo:
    ip: str | None
    user_agent: str | None
    device_id: str | None = None


@dataclass(frozen=True)
class IssuedTokens:
    access_token: str
    refresh_token: str
    expires_in: int


def _now() -> datetime:
    return datetime.now(UTC)


def _invalid_credentials() -> AppError:
    return AppError(
        "INVALID_CREDENTIALS",
        "Wrong phone number or password.",
        status_code=HTTPStatus.UNAUTHORIZED,
    )


def _account_disabled() -> AppError:
    return AppError(
        "ACCOUNT_DISABLED",
        "This account has been deactivated.",
        status_code=HTTPStatus.FORBIDDEN,
    )


def _issue(
    session: AsyncSession, user: User, family_id: uuid.UUID, client: ClientInfo
) -> tuple[RefreshToken, IssuedTokens]:
    settings = get_settings()
    raw = new_refresh_token()
    row = RefreshToken(
        user_id=user.id,
        family_id=family_id,
        token_hash=hash_refresh_token(raw),
        expires_at=_now() + timedelta(days=settings.refresh_token_ttl_days),
        user_agent=client.user_agent[:255] if client.user_agent else None,
        device_id=client.device_id,
    )
    session.add(row)
    access = create_access_token(
        AccessClaims(user_id=user.id, role=user.role.value, family_id=family_id)
    )
    return row, IssuedTokens(
        access_token=access,
        refresh_token=raw,
        expires_in=settings.access_token_ttl_minutes * 60,
    )


async def _recent_failures(session: AsyncSession, login_key: str) -> int:
    settings = get_settings()
    since = _now() - timedelta(minutes=settings.login_failure_window_minutes)
    count = await session.scalar(
        select(func.count())
        .select_from(AuditLog)
        .where(
            AuditLog.action == "auth.login_failed",
            AuditLog.created_at >= since,
            AuditLog.meta["login"].astext == login_key,
        )
    )
    return count or 0


async def login(
    session: AsyncSession,
    *,
    phone: str | None,
    email: str | None,
    password: str,
    client: ClientInfo,
) -> tuple[User, IssuedTokens]:
    if phone is not None:
        login_key = normalize_phone(phone)
        condition = User.phone == login_key
    else:
        login_key = normalize_email(email or "")
        condition = User.email == login_key

    # Rate limit (§29): counted from the audit log, so it survives restarts and
    # works across API processes.
    if await _recent_failures(session, login_key) >= get_settings().login_max_failures:
        raise AppError(
            "TOO_MANY_LOGIN_ATTEMPTS",
            "Too many failed attempts. Try again in a few minutes.",
            status_code=HTTPStatus.TOO_MANY_REQUESTS,
        )

    user = await session.scalar(select(User).where(condition))
    # Always verifies a hash, so unknown accounts take as long as known ones.
    if not verify_password(user.password_hash if user else None, password):
        audit.record(
            session,
            "auth.login_failed",
            user_id=user.id if user else None,
            metadata={"login": login_key},
            ip=client.ip,
        )
        await session.commit()
        raise _invalid_credentials()
    assert user is not None  # noqa: S101 — verify_password(None, …) is always False
    if not user.is_active:
        raise _account_disabled()

    if password_needs_rehash(user.password_hash):
        user.password_hash = hash_password(password)
    _, tokens = _issue(session, user, uuid.uuid4(), client)
    audit.record(
        session,
        "auth.login",
        user_id=user.id,
        entity_type="user",
        entity_id=user.id,
        metadata={"device_id": client.device_id} if client.device_id else None,
        ip=client.ip,
    )
    await session.commit()
    return user, tokens


async def _revoke_family(session: AsyncSession, family_id: uuid.UUID) -> None:
    await session.execute(
        update(RefreshToken)
        .where(RefreshToken.family_id == family_id, RefreshToken.revoked_at.is_(None))
        .values(revoked_at=func.now())
    )


async def refresh(session: AsyncSession, raw_token: str, client: ClientInfo) -> IssuedTokens:
    """Rotates a refresh token. Reusing a revoked one revokes its whole family."""
    token = await session.scalar(
        select(RefreshToken)
        .where(RefreshToken.token_hash == hash_refresh_token(raw_token))
        .with_for_update()
    )
    if token is None:
        raise AppError(
            "INVALID_REFRESH_TOKEN",
            "Sign in again.",
            status_code=HTTPStatus.UNAUTHORIZED,
        )
    if token.revoked_at is not None:
        await _revoke_family(session, token.family_id)
        audit.record(
            session,
            "auth.refresh_token_reused",
            user_id=token.user_id,
            entity_type="refresh_token_family",
            entity_id=str(token.family_id),
            ip=client.ip,
        )
        await session.commit()
        raise AppError(
            "REFRESH_TOKEN_REUSED",
            "This session was ended for security reasons. Sign in again.",
            status_code=HTTPStatus.UNAUTHORIZED,
        )
    if token.expires_at <= _now():
        raise AppError(
            "REFRESH_TOKEN_EXPIRED",
            "Your session has expired. Sign in again.",
            status_code=HTTPStatus.UNAUTHORIZED,
        )

    user = await session.get(User, token.user_id)
    if user is None or not user.is_active:
        await _revoke_family(session, token.family_id)
        await session.commit()
        raise _account_disabled()

    device_id = client.device_id or token.device_id
    replacement, tokens = _issue(
        session,
        user,
        token.family_id,
        ClientInfo(ip=client.ip, user_agent=client.user_agent, device_id=device_id),
    )
    await session.flush()
    token.revoked_at = _now()
    token.replaced_by_id = replacement.id
    await session.commit()
    return tokens


async def logout(session: AsyncSession, user: User, client: ClientInfo) -> None:
    """Revokes all of the user's refresh tokens (§7: sign out everywhere)."""
    await session.execute(
        update(RefreshToken)
        .where(RefreshToken.user_id == user.id, RefreshToken.revoked_at.is_(None))
        .values(revoked_at=func.now())
    )
    # FCM device tokens are removed here too once `device_tokens` exists (Phase 3).
    audit.record(
        session, "auth.logout", user_id=user.id, entity_type="user", entity_id=user.id, ip=client.ip
    )
    await session.commit()


async def change_password(
    session: AsyncSession,
    user: User,
    *,
    current_password: str,
    new_password: str,
    keep_family_id: uuid.UUID,
    client: ClientInfo,
) -> None:
    """Sets a new password and signs out every other session."""
    if not verify_password(user.password_hash, current_password):
        # 400, not 401: the session is valid; only the typed password is wrong.
        raise AppError(
            "INVALID_CREDENTIALS",
            "The current password is wrong.",
            status_code=HTTPStatus.BAD_REQUEST,
        )
    if current_password == new_password:
        raise AppError(
            "PASSWORD_UNCHANGED",
            "The new password must differ from the current one.",
        )
    user.password_hash = hash_password(new_password)
    user.must_change_password = False
    await session.execute(
        update(RefreshToken)
        .where(
            RefreshToken.user_id == user.id,
            RefreshToken.family_id != keep_family_id,
            RefreshToken.revoked_at.is_(None),
        )
        .values(revoked_at=func.now())
    )
    audit.record(
        session,
        "auth.password_changed",
        user_id=user.id,
        entity_type="user",
        entity_id=user.id,
        ip=client.ip,
    )
    await session.commit()
