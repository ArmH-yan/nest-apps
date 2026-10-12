"""The real S3 path against the storage container (docker compose `storage`, also a
CI service): presign → PUT → HEAD. Skipped when no storage is reachable."""

import uuid

import httpx
import pytest

from app.core.config import get_settings
from app.modules.files.storage import S3Storage


def _reachable() -> bool:
    try:
        httpx.get(get_settings().s3_endpoint_url, timeout=2)
    except httpx.HTTPError:
        return False
    return True


pytestmark = pytest.mark.skipif(not _reachable(), reason="S3 storage is not running")


async def test_presigned_upload_round_trip() -> None:
    # Sign for the API's own endpoint; the phone-facing host (e.g. 10.0.2.2) isn't
    # reachable from the test process.
    storage = S3Storage(public_endpoint_url=get_settings().s3_endpoint_url)
    storage.ensure_bucket()
    key = f"tests/{uuid.uuid4()}.jpg"
    payload = b"\xff\xd8 fake jpeg"

    assert await storage.head(key) is None
    upload = storage.presign_put(key, "image/jpeg")
    async with httpx.AsyncClient() as http:
        response = await http.put(upload.url, content=payload, headers=upload.headers)

    assert response.status_code == 200, response.text
    stored = await storage.head(key)
    assert stored is not None and stored.size_bytes == len(payload)
