"""Test setup: point the app at TEST_DATABASE_URL (a real PostgreSQL, never SQLite)
and migrate it to head once per session."""

import os
from collections.abc import AsyncIterator, Iterator
from pathlib import Path

import pytest
from alembic.config import Config
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from alembic import command
from app.core.config import get_settings
from app.db.session import get_engine, get_sessionmaker

API_DIR = Path(__file__).resolve().parents[1]


def _use_test_database() -> None:
    test_url = get_settings().test_database_url
    if test_url is None:
        pytest.exit("TEST_DATABASE_URL is not set (see .env.example).", returncode=2)
    if test_url == get_settings().database_url:
        pytest.exit("TEST_DATABASE_URL must differ from DATABASE_URL.", returncode=2)
    os.environ["DATABASE_URL"] = str(test_url)
    os.environ["APP_ENV"] = "test"
    get_settings.cache_clear()
    get_engine.cache_clear()
    get_sessionmaker.cache_clear()


_use_test_database()


@pytest.fixture(scope="session", autouse=True)
def migrated_database() -> Iterator[None]:
    cfg = Config(str(API_DIR / "alembic.ini"))
    command.upgrade(cfg, "head")
    yield


# Business tables emptied after every test (add new ones here).
_TABLES = ("audit_logs", "refresh_tokens", "workers", "users")


@pytest.fixture(autouse=True)
async def clean_tables() -> AsyncIterator[None]:
    yield
    async with get_sessionmaker()() as session:
        await session.execute(text(f"TRUNCATE {', '.join(_TABLES)} RESTART IDENTITY CASCADE"))
        await session.commit()


@pytest.fixture
async def session() -> AsyncIterator[AsyncSession]:
    async with get_sessionmaker()() as s:
        yield s


@pytest.fixture
def app() -> FastAPI:
    from app.main import create_app

    return create_app()


@pytest.fixture
async def client(app: FastAPI) -> AsyncIterator[AsyncClient]:
    # raise_app_exceptions=False lets us assert on the 500 response body.
    transport = ASGITransport(app=app, raise_app_exceptions=False)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
