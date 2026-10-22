from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.transitions import SYSTEM, Actor
from app.db.crud import apply_patch, get_or_404, not_found
from app.db.references import next_reference
from app.modules.audit import service as audit
from app.modules.companies.models import Company, Contact
from app.modules.projects.models import Project, ProjectStatus
from app.modules.projects.schemas import ProjectIn, ProjectPatch
from app.modules.projects.transitions import PROJECT_TRANSITIONS
from app.modules.settings.models import Service
from app.modules.sites.models import Site
from app.modules.users.models import User


async def _check_refs(
    session: AsyncSession,
    *,
    site_id: int | None = None,
    company_id: int | None = None,
    contact_id: int | None = None,
    manager_id: int | None = None,
    service_slug: str | None = None,
) -> None:
    if site_id is not None:
        await get_or_404(session, Site, site_id, "site")
    if company_id is not None:
        await get_or_404(session, Company, company_id, "company")
    if contact_id is not None:
        await get_or_404(session, Contact, contact_id, "contact")
    if manager_id is not None:
        await get_or_404(session, User, manager_id, "user")
    if service_slug is not None and (
        await session.scalar(select(Service.id).where(Service.slug == service_slug)) is None
    ):
        raise not_found("service")


async def create_project(
    session: AsyncSession, data: ProjectIn, user_id: int, *, commit: bool = True
) -> Project:
    await _check_refs(
        session,
        site_id=data.site_id,
        company_id=data.company_id,
        contact_id=data.primary_contact_id,
        manager_id=data.manager_id,
        service_slug=data.service_slug,
    )
    project = Project(**data.model_dump(), reference=await next_reference(session, "P"))
    session.add(project)
    await session.flush()
    audit.record(
        session,
        "project.created",
        user_id=user_id,
        entity_type="project",
        entity_id=project.id,
        metadata={"reference": project.reference},
    )
    await (session.commit() if commit else session.flush())
    return project


async def list_projects(
    session: AsyncSession,
    status: ProjectStatus | None,
    site_id: int | None,
    limit: int,
    offset: int,
) -> list[Project]:
    stmt = select(Project).order_by(Project.id.desc()).limit(limit).offset(offset)
    if status is not None:
        stmt = stmt.where(Project.status == status)
    if site_id is not None:
        stmt = stmt.where(Project.site_id == site_id)
    return list(await session.scalars(stmt))


def change_status(
    session: AsyncSession,
    project: Project,
    target: ProjectStatus,
    actor: Actor,
    user_id: int | None,
) -> None:
    """Validates against the transition table and records it. The caller commits."""
    if project.status == target:
        return
    PROJECT_TRANSITIONS.check(project.status, target, actor)
    audit.record(
        session,
        "project.status_changed",
        user_id=user_id,
        entity_type="project",
        entity_id=project.id,
        metadata={"from": project.status.value, "to": target.value, "by": str(actor)},
    )
    project.status = target


def advance_if_allowed(session: AsyncSession, project: Project, target: ProjectStatus) -> None:
    """SYSTEM side effect (e.g. a survey job got a crew → SURVEY). Silently does
    nothing when the project is already past that point."""
    if PROJECT_TRANSITIONS.can(project.status, target, SYSTEM):
        change_status(session, project, target, SYSTEM, None)


async def update_project(
    session: AsyncSession, project_id: int, patch: ProjectPatch, user: User
) -> Project:
    project = await get_or_404(session, Project, project_id, "project")
    await _check_refs(session, contact_id=patch.primary_contact_id, manager_id=patch.manager_id)
    if patch.status is not None:
        change_status(session, project, patch.status, user.role, user.id)
    apply_patch(project, patch, exclude={"status"})
    await session.commit()
    return project
