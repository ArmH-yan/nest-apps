from http import HTTPStatus
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.crud import get_or_404
from app.db.session import get_session
from app.modules.auth.dependencies import ManagerAuth
from app.modules.projects import service
from app.modules.projects.models import Project, ProjectStatus
from app.modules.projects.schemas import ProjectIn, ProjectOut, ProjectPatch

router = APIRouter(prefix="/projects", tags=["projects"])
Session = Annotated[AsyncSession, Depends(get_session)]


@router.post("", status_code=HTTPStatus.CREATED)
async def create_project(body: ProjectIn, auth: ManagerAuth, session: Session) -> ProjectOut:
    return ProjectOut.model_validate(await service.create_project(session, body, auth.user.id))


@router.get("")
async def list_projects(
    _: ManagerAuth,
    session: Session,
    status: ProjectStatus | None = None,
    site_id: int | None = None,
    limit: Annotated[int, Query(ge=1, le=200)] = 50,
    offset: int = 0,
) -> list[ProjectOut]:
    rows = await service.list_projects(session, status, site_id, limit, offset)
    return [ProjectOut.model_validate(p) for p in rows]


@router.get("/{project_id}")
async def get_project(project_id: int, _: ManagerAuth, session: Session) -> ProjectOut:
    return ProjectOut.model_validate(await get_or_404(session, Project, project_id, "project"))


@router.patch("/{project_id}")
async def update_project(
    project_id: int, body: ProjectPatch, auth: ManagerAuth, session: Session
) -> ProjectOut:
    return ProjectOut.model_validate(
        await service.update_project(session, project_id, body, auth.user)
    )
