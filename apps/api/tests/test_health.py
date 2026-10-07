from collections.abc import AsyncIterator

from fastapi import FastAPI
from httpx import AsyncClient
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine

from app.db.session import get_session, get_sessionmaker


async def test_health_ok(client: AsyncClient) -> None:
    response = await client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "database": "ok"}
    assert response.headers["X-Request-ID"]


async def test_health_reports_unreachable_database(app: FastAPI, client: AsyncClient) -> None:
    # Port 1 on localhost: nothing listens there, so the connection is refused.
    dead_engine = create_async_engine(
        "postgresql+asyncpg://nobody:nothing@127.0.0.1:1/none", connect_args={"timeout": 2}
    )

    async def broken_session() -> AsyncIterator[AsyncSession]:
        async with AsyncSession(dead_engine) as session:
            yield session

    app.dependency_overrides[get_session] = broken_session
    try:
        response = await client.get("/health")
    finally:
        await dead_engine.dispose()

    assert response.status_code == 503
    assert response.json()["error"]["code"] == "DATABASE_UNAVAILABLE"


async def test_migrations_applied() -> None:
    async with get_sessionmaker()() as session:
        version = await session.scalar(text("SELECT version_num FROM alembic_version"))
        has_btree_gist = await session.scalar(
            text("SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'btree_gist')")
        )

    assert version == "0001"
    assert has_btree_gist is True


async def test_connection_uses_utc() -> None:
    async with get_sessionmaker()() as session:
        assert await session.scalar(text("SHOW timezone")) == "UTC"
