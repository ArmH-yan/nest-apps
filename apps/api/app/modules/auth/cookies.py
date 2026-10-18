"""Browser sessions for the manager web app (ARCHITECTURE §7): HttpOnly cookies plus a
double-submit CSRF token.

    nest_access   access JWT          HttpOnly, path /
    nest_refresh  refresh token       HttpOnly, path /api/v1/auth/web (sent nowhere else)
    nest_csrf     random CSRF token   readable by the page; echoed in X-CSRF-Token

A request authenticated by cookie that changes state (POST/PUT/PATCH/DELETE) must
send X-CSRF-Token equal to the nest_csrf cookie. SameSite=Lax already stops most
cross-site requests; the token covers the rest. The worker app keeps using Bearer
tokens, which need no CSRF token.
"""

import hmac
import secrets
from datetime import timedelta
from http import HTTPStatus

from fastapi import Request, Response

from app.core.config import get_settings
from app.core.errors import AppError

ACCESS_COOKIE = "nest_access"
REFRESH_COOKIE = "nest_refresh"
CSRF_COOKIE = "nest_csrf"
CSRF_HEADER = "X-CSRF-Token"
REFRESH_PATH = "/api/v1/auth/web"
_SAFE_METHODS = {"GET", "HEAD", "OPTIONS"}


def set_session_cookies(
    response: Response, *, access_token: str, refresh_token: str, csrf_token: str | None = None
) -> str:
    """Sets all three cookies. Returns the CSRF token (kept across refreshes)."""
    settings = get_settings()
    csrf = csrf_token or secrets.token_urlsafe(32)
    refresh_age = int(timedelta(days=settings.refresh_token_ttl_days).total_seconds())

    def put(name: str, value: str, *, max_age: int, http_only: bool, path: str) -> None:
        response.set_cookie(
            name,
            value,
            max_age=max_age,
            httponly=http_only,
            path=path,
            secure=settings.is_production,
            samesite="lax",
            domain=settings.cookie_domain,
        )

    put(
        ACCESS_COOKIE,
        access_token,
        max_age=settings.access_token_ttl_minutes * 60,
        http_only=True,
        path="/",
    )
    put(REFRESH_COOKIE, refresh_token, max_age=refresh_age, http_only=True, path=REFRESH_PATH)
    put(CSRF_COOKIE, csrf, max_age=refresh_age, http_only=False, path="/")
    return csrf


def clear_session_cookies(response: Response) -> None:
    domain = get_settings().cookie_domain
    response.delete_cookie(ACCESS_COOKIE, path="/", domain=domain)
    response.delete_cookie(REFRESH_COOKIE, path=REFRESH_PATH, domain=domain)
    response.delete_cookie(CSRF_COOKIE, path="/", domain=domain)


def check_csrf(request: Request) -> None:
    """403 CSRF_FAILED unless the header matches the cookie (state-changing requests)."""
    if request.method in _SAFE_METHODS:
        return
    cookie = request.cookies.get(CSRF_COOKIE, "")
    header = request.headers.get(CSRF_HEADER, "")
    if not cookie or not hmac.compare_digest(cookie, header):
        raise AppError(
            "CSRF_FAILED",
            "The request is missing a valid CSRF token. Reload the page.",
            status_code=HTTPStatus.FORBIDDEN,
        )
