"""Push transport (ARCHITECTURE §26). Firebase Cloud Messaging is only the delivery
pipe: what to send, to whom, and read state live in PostgreSQL.

- `LogPushSender`: development default (no Firebase project needed); logs each push.
- `FcmPushSender`: FCM HTTP v1 with a service account. The OAuth token is an RS256
  JWT exchanged at Google's token endpoint (no Google SDK needed) and cached ~1 h.
"""

import json
import logging
import time
from dataclasses import dataclass
from enum import StrEnum
from functools import lru_cache
from pathlib import Path
from typing import Protocol

import httpx
import jwt

from app.core.config import get_settings

log = logging.getLogger(__name__)

FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
TOKEN_URL = "https://oauth2.googleapis.com/token"  # noqa: S105 — an endpoint, not a secret


@dataclass(frozen=True)
class PushMessage:
    token: str
    title: str
    body: str
    data: dict[str, str]  # FCM data values must be strings


class Outcome(StrEnum):
    OK = "OK"
    UNREGISTERED = "UNREGISTERED"  # the token is dead: delete it
    RETRY = "RETRY"  # transient (network, 429, 5xx): try again later
    REJECTED = "REJECTED"  # permanent for this message (bad request)


@dataclass(frozen=True)
class SendResult:
    outcome: Outcome
    error: str | None = None


class PushSender(Protocol):
    async def send(self, message: PushMessage) -> SendResult: ...


class LogPushSender:
    async def send(self, message: PushMessage) -> SendResult:
        log.info(
            "push (log only): %s | %s | %s",
            message.token[:12] + "…",
            message.title,
            message.data,
        )
        return SendResult(Outcome.OK)


class FcmPushSender:
    def __init__(self, credentials_file: Path, client: httpx.AsyncClient | None = None) -> None:
        info = json.loads(credentials_file.read_text(encoding="utf-8"))
        self._project = info["project_id"]
        self._email = info["client_email"]
        self._key = info["private_key"]
        self._client = client or httpx.AsyncClient(timeout=15)
        self._token: str | None = None
        self._token_expires = 0.0

    async def _access_token(self) -> str:
        now = time.time()
        if self._token and now < self._token_expires - 60:
            return self._token
        assertion = jwt.encode(
            {
                "iss": self._email,
                "scope": FCM_SCOPE,
                "aud": TOKEN_URL,
                "iat": int(now),
                "exp": int(now) + 3600,
            },
            self._key,
            algorithm="RS256",
        )
        r = await self._client.post(
            TOKEN_URL,
            data={
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": assertion,
            },
        )
        r.raise_for_status()
        body = r.json()
        self._token = str(body["access_token"])
        self._token_expires = now + float(body.get("expires_in", 3600))
        return self._token

    async def send(self, message: PushMessage) -> SendResult:
        try:
            token = await self._access_token()
            r = await self._client.post(
                f"https://fcm.googleapis.com/v1/projects/{self._project}/messages:send",
                headers={"Authorization": f"Bearer {token}"},
                json={
                    "message": {
                        "token": message.token,
                        "notification": {"title": message.title, "body": message.body},
                        "data": message.data,
                        "android": {"priority": "high"},
                    }
                },
            )
        except httpx.HTTPError as exc:
            return SendResult(Outcome.RETRY, f"network: {exc}")
        if r.is_success:
            return SendResult(Outcome.OK)
        status = _fcm_error_status(r)
        if r.status_code == 404 or status == "UNREGISTERED":
            return SendResult(Outcome.UNREGISTERED, status)
        if r.status_code == 401:
            self._token = None  # expired early: fetch a new one next time
            return SendResult(Outcome.RETRY, "unauthorized")
        if r.status_code == 429 or r.status_code >= 500:
            return SendResult(Outcome.RETRY, f"{r.status_code} {status}")
        if status == "INVALID_ARGUMENT" and "token" in r.text.lower():
            return SendResult(Outcome.UNREGISTERED, status)
        return SendResult(Outcome.REJECTED, f"{r.status_code} {status}: {r.text[:300]}")


def _fcm_error_status(response: httpx.Response) -> str:
    """The FCM error code, e.g. UNREGISTERED (from details) or NOT_FOUND."""
    try:
        error = response.json().get("error", {})
    except ValueError:
        return "UNKNOWN"
    for detail in error.get("details", []):
        if detail.get("errorCode"):
            return str(detail["errorCode"])
    return str(error.get("status", "UNKNOWN"))


@lru_cache
def get_sender() -> PushSender:
    settings = get_settings()
    if settings.push_provider == "fcm":
        if settings.fcm_credentials_file is None:
            raise RuntimeError("PUSH_PROVIDER=fcm needs FCM_CREDENTIALS_FILE.")
        return FcmPushSender(Path(settings.fcm_credentials_file))
    return LogPushSender()
