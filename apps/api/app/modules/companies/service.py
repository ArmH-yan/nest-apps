from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.crud import apply_patch, get_or_404
from app.modules.companies.models import Company, Contact
from app.modules.companies.schemas import CompanyIn, CompanyPatch, ContactIn, ContactPatch


async def create_company(session: AsyncSession, data: CompanyIn) -> Company:
    company = Company(**data.model_dump())
    session.add(company)
    await session.commit()
    return company


async def list_companies(
    session: AsyncSession, q: str | None, limit: int, offset: int
) -> list[Company]:
    stmt = select(Company).order_by(Company.name).limit(limit).offset(offset)
    if q:
        stmt = stmt.where(Company.name.ilike(f"%{q}%"))
    return list(await session.scalars(stmt))


async def update_company(session: AsyncSession, company_id: int, patch: CompanyPatch) -> Company:
    company = await get_or_404(session, Company, company_id, "company")
    apply_patch(company, patch)
    await session.commit()
    return company


async def create_contact(session: AsyncSession, data: ContactIn) -> Contact:
    if data.company_id is not None:
        await get_or_404(session, Company, data.company_id, "company")
    contact = Contact(**data.model_dump())
    session.add(contact)
    await session.commit()
    return contact


async def list_contacts(
    session: AsyncSession, company_id: int | None, limit: int, offset: int
) -> list[Contact]:
    stmt = select(Contact).order_by(Contact.full_name).limit(limit).offset(offset)
    if company_id is not None:
        stmt = stmt.where(Contact.company_id == company_id)
    return list(await session.scalars(stmt))


async def update_contact(session: AsyncSession, contact_id: int, patch: ContactPatch) -> Contact:
    contact = await get_or_404(session, Contact, contact_id, "contact")
    if patch.company_id is not None:
        await get_or_404(session, Company, patch.company_id, "company")
    apply_patch(contact, patch)
    await session.commit()
    return contact
