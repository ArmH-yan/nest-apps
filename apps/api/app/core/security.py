"""Password hashing (Argon2id) and tokens (ARCHITECTURE §7, §29).

- Access token: short-lived JWT (HS256) carrying the user id, role and refresh family.
- Refresh token: random opaque string. Only its SHA-256 hash is stored.
"""

import hashlib
import secrets
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError

from app.core.config import get_settings

_hasher = PasswordHasher()  # argon2-cffi defaults are Argon2id (RFC 9106 low-memory profile)

# Verified against when the login identifier is unknown, so the response takes the
# same time whether or not the account exists.
_DUMMY_HASH = _hasher.hash(secrets.token_urlsafe(16))

_ALGORITHM = "HS256"


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def verify_password(password_hash: str | None, password: str) -> bool:
    try:
        return _hasher.verify(password_hash or _DUMMY_HASH, password) and bool(password_hash)
    except (VerificationError, InvalidHashError):
        return False


def password_needs_rehash(password_hash: str) -> bool:
    return _hasher.check_needs_rehash(password_hash)


@dataclass(frozen=True)
class AccessClaims:
    user_id: int
    role: str
    family_id: uuid.UUID


class InvalidTokenError(Exception):
    def __init__(self, *, expired: bool) -> None:
        super().__init__("expired" if expired else "invalid")
        self.expired = expired


def create_access_token(claims: AccessClaims, *, now: datetime | None = None) -> str:
    settings = get_settings()
    issued = now or datetime.now(UTC)
    payload = {
        "sub": str(claims.user_id),
        "role": claims.role,
        "fid": str(claims.family_id),
        "typ": "access",
        "iat": issued,
        "exp": issued + timedelta(minutes=settings.access_token_ttl_minutes),
    }
    return jwt.encode(payload, settings.jwt_secret.get_secret_value(), algorithm=_ALGORITHM)


def decode_access_token(token: str) -> AccessClaims:
    secret = get_settings().jwt_secret.get_secret_value()
    try:
        payload = jwt.decode(
            token,
            secret,
            algorithms=[_ALGORITHM],
            options={"require": ["sub", "exp", "iat", "fid", "typ"]},
        )
        if payload["typ"] != "access":
            raise InvalidTokenError(expired=False)
        return AccessClaims(
            user_id=int(payload["sub"]),
            role=str(payload["role"]),
            family_id=uuid.UUID(payload["fid"]),
        )
    except jwt.ExpiredSignatureError as exc:
        raise InvalidTokenError(expired=True) from exc
    except (jwt.InvalidTokenError, KeyError, ValueError) as exc:
        raise InvalidTokenError(expired=False) from exc


def new_refresh_token() -> str:
    return secrets.token_urlsafe(32)


def hash_refresh_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()
