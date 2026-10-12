from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Query, Response
from pydantic import AwareDatetime
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.scheduling import service
from app.modules.scheduling.models import JobStatus
from app.modules.scheduling.schemas import (
    CancelIn,
    CrewIn,
    JobDetailOut,
    JobIn,
    JobOut,
    JobPatch,
    ScheduleEntryOut,
    VisitIn,
    VisitOut,
)

router = APIRouter(tags=["scheduling"])
Session = Annotated[AsyncSession, Depends(get_session)]


@router.post("/jobs", status_code=HTTPStatus.CREATED)
async def create_job(body: JobIn, auth: ManagerAuth, session: Session) -> JobOut:
    return service.job_out(await service.create_job(session, body, auth.user))


@router.get("/jobs")
async def list_jobs(
    _: ManagerAuth,
    session: Session,
    status: JobStatus | None = None,
    project_id: int | None = None,
    limit: Annotated[int, Query(ge=1, le=200)] = 50,
    offset: int = 0,
) -> list[JobOut]:
    jobs = await service.list_jobs(
        session, status=status, project_id=project_id, limit=limit, offset=offset
    )
    return [service.job_out(j) for j in jobs]


@router.get("/jobs/{job_id}")
async def get_job(job_id: int, _: ManagerAuth, session: Session) -> JobDetailOut:
    return await service.job_detail(session, job_id)


@router.patch("/jobs/{job_id}")
async def update_job(job_id: int, body: JobPatch, auth: ManagerAuth, session: Session) -> JobOut:
    return service.job_out(await service.update_job(session, job_id, body, auth.user))


@router.post("/jobs/{job_id}/cancel")
async def cancel_job(job_id: int, body: CancelIn, auth: ManagerAuth, session: Session) -> JobOut:
    return service.job_out(await service.cancel_job(session, job_id, body.reason, auth.user))


@router.post("/jobs/{job_id}/visits", status_code=HTTPStatus.CREATED)
async def create_visit(job_id: int, body: VisitIn, auth: ManagerAuth, session: Session) -> VisitOut:
    visit = await service.create_visit(session, job_id, body, auth.user)
    return await service.visit_out(session, visit)


@router.patch("/visits/{visit_id}")
async def update_visit(
    visit_id: int, body: VisitIn, auth: ManagerAuth, session: Session
) -> VisitOut:
    visit = await service.update_visit(session, visit_id, body, auth.user)
    return await service.visit_out(session, visit)


@router.delete("/visits/{visit_id}", status_code=HTTPStatus.NO_CONTENT)
async def cancel_visit(visit_id: int, auth: ManagerAuth, session: Session) -> Response:
    """Cancels the visit (records are never hard-deleted, §8)."""
    await service.cancel_visit(session, visit_id, auth.user)
    return Response(status_code=HTTPStatus.NO_CONTENT)


@router.put("/visits/{visit_id}/crew")
async def set_crew(visit_id: int, body: CrewIn, auth: ManagerAuth, session: Session) -> VisitOut:
    visit = await service.set_crew(session, visit_id, body, auth.user)
    return await service.visit_out(session, visit)


@router.get("/schedule")
async def schedule(
    _: ManagerAuth,
    session: Session,
    from_: Annotated[AwareDatetime, Query(alias="from")],
    to: AwareDatetime,
    worker_id: int | None = None,
) -> list[ScheduleEntryOut]:
    return await service.schedule(session, from_, to, worker_id)
