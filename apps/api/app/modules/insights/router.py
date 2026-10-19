from datetime import date
from typing import Annotated

from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.time import YEREVAN, utcnow
from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.insights import service
from app.modules.insights.schemas import CompanyInsightsOut, CompanyJobRowOut, WorkerInsightsOut
from app.modules.timesheets.schemas import TimesheetRowOut

router = APIRouter(prefix="/insights", tags=["insights"])
Session = Annotated[AsyncSession, Depends(get_session)]
From = Annotated[date | None, Query(alias="from")]


def _window(from_: date | None, to: date | None) -> tuple[date, date]:
    """Yerevan dates, both inclusive; default: the last 12 months."""
    start, end = service.default_window(utcnow().astimezone(YEREVAN).date())
    start, end = from_ or start, to or end
    if end < start:
        raise AppError("VALIDATION_ERROR", "`to` must not be before `from`.", status_code=422)
    return start, end


def _csv(body: str, name: str) -> Response:
    return Response(
        content=body,
        media_type="text/csv; charset=utf-8",
        headers={"Content-Disposition": f'attachment; filename="{name}"'},
    )


@router.get("/workers/{worker_id}")
async def worker_insights(
    worker_id: int, _: ManagerAuth, session: Session, from_: From = None, to: date | None = None
) -> WorkerInsightsOut:
    return await service.worker_insights(session, worker_id, *_window(from_, to))


@router.get("/workers/{worker_id}/tasks")
async def worker_tasks(
    worker_id: int, _: ManagerAuth, session: Session, from_: From = None, to: date | None = None
) -> list[TimesheetRowOut]:
    return await service.worker_tasks(session, worker_id, *_window(from_, to))


@router.get("/workers/{worker_id}/tasks.csv")
async def worker_tasks_csv(
    worker_id: int, _: ManagerAuth, session: Session, from_: From = None, to: date | None = None
) -> Response:
    start, end = _window(from_, to)
    rows = await service.worker_tasks(session, worker_id, start, end)
    return _csv(service.worker_tasks_csv(rows), f"nest-worker-{worker_id}-{start}-{end}.csv")


@router.get("/companies/{company_id}")
async def company_insights(
    company_id: int, _: ManagerAuth, session: Session, from_: From = None, to: date | None = None
) -> CompanyInsightsOut:
    return await service.company_insights(session, company_id, *_window(from_, to))


@router.get("/companies/{company_id}/jobs")
async def company_jobs(
    company_id: int, _: ManagerAuth, session: Session, from_: From = None, to: date | None = None
) -> list[CompanyJobRowOut]:
    return await service.company_jobs(session, company_id, *_window(from_, to))


@router.get("/companies/{company_id}/jobs.csv")
async def company_jobs_csv(
    company_id: int, _: ManagerAuth, session: Session, from_: From = None, to: date | None = None
) -> Response:
    start, end = _window(from_, to)
    rows = await service.company_jobs(session, company_id, start, end)
    return _csv(service.company_jobs_csv(rows), f"nest-company-{company_id}-{start}-{end}.csv")
