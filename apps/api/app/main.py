"""FastAPI application entry point.

Run locally:  uvicorn app.main:app --reload --port 8000   (from apps/api)
"""

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import APIRouter, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import get_settings
from app.core.errors import register_error_handlers
from app.core.logging import configure_logging
from app.core.middleware import RequestIdMiddleware
from app.db.session import get_engine
from app.modules.auth.router import router as auth_router
from app.modules.health.router import router as health_router
from app.modules.users.router import router as users_router

API_V1_PREFIX = "/api/v1"


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncIterator[None]:
    yield
    await get_engine().dispose()


def create_app() -> FastAPI:
    settings = get_settings()
    configure_logging(settings.log_level)

    app = FastAPI(
        title="NEST API",
        version="0.1.0",
        lifespan=lifespan,
        # interactive docs only outside production
        docs_url=None if settings.is_production else "/docs",
        redoc_url=None,
    )

    app.add_middleware(RequestIdMiddleware)
    if settings.cors_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.cors_origins,
            allow_credentials=True,  # manager web uses HttpOnly cookies
            allow_methods=["*"],
            allow_headers=["*"],
        )

    register_error_handlers(app)

    app.include_router(health_router)

    # Versioned business routers are included here as modules are built.
    api_v1 = APIRouter(prefix=API_V1_PREFIX)
    api_v1.include_router(auth_router)
    api_v1.include_router(users_router)
    app.include_router(api_v1)

    return app


app = create_app()
