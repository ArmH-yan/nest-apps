from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.modules.health import service
from app.modules.health.schemas import HealthResponse

router = APIRouter(tags=["health"])


@router.get("/health")
async def health(session: Annotated[AsyncSession, Depends(get_session)]) -> HealthResponse:
    """Liveness + database connectivity. Used by uptime checks (ARCHITECTURE §36)."""
    await service.check_database(session)
    return HealthResponse(status="ok", database="ok")
