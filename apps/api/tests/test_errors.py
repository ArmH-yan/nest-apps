"""Every error response must use {"error": {"code", "message", "details"}}."""

from http import HTTPStatus

import pytest
from fastapi import FastAPI
from httpx import AsyncClient

from app.core.errors import AppError


@pytest.fixture
def app_with_probe_routes(app: FastAPI) -> FastAPI:
    @app.get("/_test/app-error")
    async def app_error() -> None:
        raise AppError(
            "JOB_NOT_ASSIGNABLE",
            "The job is already completed.",
            status_code=HTTPStatus.CONFLICT,
            details={"job_id": 5},
        )

    @app.get("/_test/validated")
    async def validated(count: int) -> dict[str, int]:
        return {"count": count}

    @app.get("/_test/crash")
    async def crash() -> None:
        raise RuntimeError("secret internal detail")

    return app


def assert_error_shape(body: dict[str, object]) -> dict[str, object]:
    assert set(body) == {"error"}
    error = body["error"]
    assert isinstance(error, dict)
    assert set(error) == {"code", "message", "details"}
    assert isinstance(error["details"], dict)
    return error


async def test_app_error(app_with_probe_routes: FastAPI, client: AsyncClient) -> None:
    response = await client.get("/_test/app-error")

    assert response.status_code == 409
    error = assert_error_shape(response.json())
    assert error["code"] == "JOB_NOT_ASSIGNABLE"
    assert error["details"] == {"job_id": 5}


async def test_not_found(client: AsyncClient) -> None:
    response = await client.get("/does-not-exist")

    assert response.status_code == 404
    assert assert_error_shape(response.json())["code"] == "NOT_FOUND"


async def test_method_not_allowed(client: AsyncClient) -> None:
    response = await client.post("/health")

    assert response.status_code == 405
    assert assert_error_shape(response.json())["code"] == "METHOD_NOT_ALLOWED"


async def test_validation_error(app_with_probe_routes: FastAPI, client: AsyncClient) -> None:
    response = await client.get("/_test/validated", params={"count": "abc"})

    assert response.status_code == 422
    error = assert_error_shape(response.json())
    assert error["code"] == "VALIDATION_ERROR"
    details = error["details"]
    assert isinstance(details, dict)
    assert details["fields"][0]["loc"] == ["query", "count"]


async def test_unhandled_error_hides_internals(
    app_with_probe_routes: FastAPI, client: AsyncClient
) -> None:
    response = await client.get("/_test/crash", headers={"X-Request-ID": "req-123"})

    assert response.status_code == 500
    error = assert_error_shape(response.json())
    assert error["code"] == "INTERNAL_ERROR"
    assert "secret" not in response.text
    assert error["details"] == {"request_id": "req-123"}


async def test_request_id_is_echoed(client: AsyncClient) -> None:
    response = await client.get("/health", headers={"X-Request-ID": "abc-42"})

    assert response.headers["X-Request-ID"] == "abc-42"
