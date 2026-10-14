"""The committed API contract (apps/api/openapi.json, ARCHITECTURE §40) must match the
code. The worker app's DTO contract test reads this file.

Fix a failure with:  .venv/Scripts/python -m app.cli export-openapi
"""

from app.cli import OPENAPI_PATH, openapi_json


def test_committed_openapi_is_up_to_date() -> None:
    assert OPENAPI_PATH.exists(), "run `python -m app.cli export-openapi`"
    assert OPENAPI_PATH.read_text(encoding="utf-8") == openapi_json(), (
        "openapi.json is stale: run `python -m app.cli export-openapi`"
    )
