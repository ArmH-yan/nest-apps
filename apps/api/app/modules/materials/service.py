"""Materials on site (ARCHITECTURE §16): the crew lead records movements; what is on a
site is the sum of its ledger."""

import uuid
from decimal import Decimal
from http import HTTPStatus

from sqlalchemy import case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.time import utcnow
from app.db.crud import not_found
from app.modules.materials.models import CatalogItem, Movement, SiteMaterialMovement
from app.modules.scheduling.models import AssignmentRole
from app.modules.worker_api.access import ensure_writable, own_task
from app.modules.worker_api.dependencies import WorkerContext
from app.modules.worker_api.schemas import MaterialMovementIn

_ADDS = (Movement.INSTALLED, Movement.ADJUSTMENT)


async def trackable_catalog(session: AsyncSession) -> list[CatalogItem]:
    return list(
        await session.scalars(
            select(CatalogItem)
            .where(CatalogItem.is_trackable, CatalogItem.is_active)
            .order_by(CatalogItem.id)
        )
    )


async def on_site(session: AsyncSession, site_id: int) -> list[tuple[CatalogItem, Decimal]]:
    """Current balance per item (the dismantling crew's list, §8)."""
    signed = case(
        (SiteMaterialMovement.movement.in_(_ADDS), SiteMaterialMovement.quantity),
        else_=-SiteMaterialMovement.quantity,
    )
    balance = func.sum(signed)
    rows = await session.execute(
        select(CatalogItem, balance)
        .join(SiteMaterialMovement, SiteMaterialMovement.catalog_item_id == CatalogItem.id)
        .where(SiteMaterialMovement.site_id == site_id)
        .group_by(CatalogItem.id)
        .having(balance > 0)
        .order_by(CatalogItem.id)
    )
    return [(item, qty) for item, qty in rows]


async def put_movement(
    session: AsyncSession, me: WorkerContext, movement_id: uuid.UUID, body: MaterialMovementIn
) -> SiteMaterialMovement:
    existing = await session.get(SiteMaterialMovement, movement_id)
    if existing is not None:
        if existing.recorded_by != me.user.id:
            raise not_found("material movement")
        same = (
            existing.assignment_id == body.task_id
            and existing.catalog_item_id == body.catalog_item_id
            and existing.quantity == body.quantity
            and existing.movement == body.movement
            and existing.note == body.note
        )
        if not same:
            raise AppError(
                "MATERIAL_FINALIZED",
                "This material entry was already saved.",
                status_code=HTTPStatus.CONFLICT,
            )
        return existing

    ctx = await own_task(session, me.worker.id, body.task_id, lock=True)
    ensure_writable(ctx)
    if ctx.assignment.role is not AssignmentRole.LEAD:
        raise AppError(
            "NOT_CREW_LEAD",
            "Only the crew lead records materials.",
            status_code=HTTPStatus.FORBIDDEN,
        )
    item = await session.get(CatalogItem, body.catalog_item_id)
    if item is None or not item.is_active or not item.is_trackable:
        raise not_found("catalog item")
    movement = SiteMaterialMovement(
        id=movement_id,
        site_id=ctx.site.id,
        project_id=ctx.project.id,
        job_id=ctx.job.id,
        assignment_id=ctx.assignment.id,
        catalog_item_id=item.id,
        quantity=body.quantity,
        movement=body.movement,
        recorded_by=me.user.id,
        recorded_at=body.recorded_at or utcnow(),
        note=body.note,
    )
    session.add(movement)
    await session.commit()
    return movement
