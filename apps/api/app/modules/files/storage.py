"""Object storage behind a small interface (ARCHITECTURE §24).

`S3Storage` works with any S3-compatible service (RustFS locally, a managed S3 in
production). Uploads go straight from the phone to storage with a presigned PUT,
so file bytes never pass through the API. Tests override `get_storage` with a fake.
"""

import asyncio
from dataclasses import dataclass
from datetime import datetime, timedelta
from functools import lru_cache
from typing import TYPE_CHECKING, Protocol

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError

from app.core.config import get_settings
from app.core.time import utcnow

if TYPE_CHECKING:
    from mypy_boto3_s3 import S3Client

PRESIGN_TTL = timedelta(minutes=30)


@dataclass(frozen=True)
class PresignedUpload:
    url: str
    # headers the client must send with the PUT (they are part of the signature)
    headers: dict[str, str]
    expires_at: datetime


@dataclass(frozen=True)
class StoredObject:
    size_bytes: int
    content_type: str | None


class Storage(Protocol):
    def presign_put(self, key: str, content_type: str) -> PresignedUpload: ...

    async def head(self, key: str) -> StoredObject | None: ...


class S3Storage:
    def __init__(self, public_endpoint_url: str | None = None) -> None:
        settings = get_settings()
        self._bucket = settings.s3_bucket
        self._internal = self._client(settings.s3_endpoint_url)
        # Signatures cover the host, so phones get URLs signed for the host they can reach.
        self._public = self._client(
            public_endpoint_url or settings.s3_public_endpoint_url or settings.s3_endpoint_url
        )

    @staticmethod
    def _client(endpoint: str) -> "S3Client":
        settings = get_settings()
        return boto3.client(
            "s3",
            endpoint_url=endpoint,
            aws_access_key_id=settings.s3_access_key.get_secret_value(),
            aws_secret_access_key=settings.s3_secret_key.get_secret_value(),
            region_name=settings.s3_region,
            config=Config(
                signature_version="s3v4",
                s3={"addressing_style": "path"},
                retries={"max_attempts": 3},
            ),
        )

    def presign_put(self, key: str, content_type: str) -> PresignedUpload:
        # Signing is local computation (no network call).
        url = self._public.generate_presigned_url(
            "put_object",
            Params={"Bucket": self._bucket, "Key": key, "ContentType": content_type},
            ExpiresIn=int(PRESIGN_TTL.total_seconds()),
        )
        return PresignedUpload(url, {"Content-Type": content_type}, utcnow() + PRESIGN_TTL)

    async def head(self, key: str) -> StoredObject | None:
        def _head() -> StoredObject | None:
            try:
                meta = self._internal.head_object(Bucket=self._bucket, Key=key)
            except ClientError as exc:
                if exc.response.get("Error", {}).get("Code") in {"404", "NoSuchKey", "NotFound"}:
                    return None
                raise
            return StoredObject(meta["ContentLength"], meta.get("ContentType"))

        # boto3 is synchronous; keep the event loop free.
        return await asyncio.to_thread(_head)

    def ensure_bucket(self) -> None:
        try:
            self._internal.head_bucket(Bucket=self._bucket)
        except ClientError:
            self._internal.create_bucket(Bucket=self._bucket)


@lru_cache
def get_storage() -> Storage:
    return S3Storage()
