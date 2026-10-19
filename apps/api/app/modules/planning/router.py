from datetime import date, timedelta
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.time import YEREVAN, utcnow
from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.planning import service
from app.modules.planning.schemas import PlanningProjectOut

router = APIRouter(prefix="/planning", tags=["planning"])
Session = Annotated[AsyncSession, Depends(get_session)]
MAX_DAYS = 400


@router.get("/projects")
async def planning_projects(
    _: ManagerAuth,
    session: Session,
    from_: Annotated[date | None, Query(alias="from")] = None,
    to: date | None = None,
) -> list[PlanningProjectOut]:
    """Yerevan dates, both inclusive; default: a week back to 12 weeks ahead."""
    today = utcnow().astimezone(YEREVAN).date()
    start = from_ or today - timedelta(days=7)
    end = to or start + timedelta(days=90)
    if end < start or (end - start).days > MAX_DAYS:
        raise AppError(
            "VALIDATION_ERROR",
            f"`to` must be after `from` and at most {MAX_DAYS} days later.",
            status_code=422,
        )
    return await service.projects(session, start, end, today)
