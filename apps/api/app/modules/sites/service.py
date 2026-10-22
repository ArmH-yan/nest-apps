from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.crud import apply_patch, get_or_404
from app.modules.audit import service as audit
from app.modules.companies.models import Company
from app.modules.sites.models import Site
from app.modules.sites.schemas import SiteIn, SitePatch

# GPS checks are measured against these, so changes are audited (§25).
_GEOFENCE_FIELDS = {"latitude", "longitude", "geofence_radius_m", "location_confirmed"}


async def create_site(
    session: AsyncSession, data: SiteIn, user_id: int, *, commit: bool = True
) -> Site:
    if data.company_id is not None:
        await get_or_404(session, Company, data.company_id, "company")
    site = Site(**data.model_dump())
    session.add(site)
    await session.flush()
    audit.record(session, "site.created", user_id=user_id, entity_type="site", entity_id=site.id)
    await (session.commit() if commit else session.flush())
    return site


async def list_sites(
    session: AsyncSession, company_id: int | None, q: str | None, limit: int, offset: int
) -> list[Site]:
    stmt = select(Site).order_by(Site.name).limit(limit).offset(offset)
    if company_id is not None:
        stmt = stmt.where(Site.company_id == company_id)
    if q:
        stmt = stmt.where(Site.name.ilike(f"%{q}%") | Site.address.ilike(f"%{q}%"))
    return list(await session.scalars(stmt))


async def update_site(session: AsyncSession, site_id: int, patch: SitePatch, user_id: int) -> Site:
    site = await get_or_404(session, Site, site_id, "site")
    if patch.company_id is not None:
        await get_or_404(session, Company, patch.company_id, "company")
    before = {f: str(getattr(site, f)) for f in _GEOFENCE_FIELDS}
    changes = apply_patch(site, patch)
    if moved := _GEOFENCE_FIELDS & changes.keys():
        audit.record(
            session,
            "site.geofence_changed",
            user_id=user_id,
            entity_type="site",
            entity_id=site.id,
            metadata={f: {"before": before[f], "after": str(changes[f])} for f in sorted(moved)},
        )
    await session.commit()
    return site
