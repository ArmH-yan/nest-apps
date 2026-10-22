"""Intake (ARCHITECTURE §9, §12): website leads, review, rejection, conversion.

- Public intake is authenticated with the website's service key. What the visitor
  typed is stored as received; the service's display name (in any of the site's
  languages) is matched to a `services.slug` when possible.
- Abuse (§12 "Spam and abuse"): an identical lead (same email or phone and the same
  message) within 24 h returns the first one's reference instead of a new row, and
  more than INTAKE_PER_HOUR leads in an hour are refused with 429. Turnstile and
  the honeypot live in nest_web.
- Conversion creates or links company, contact, site and project in ONE
  transaction, so a failure leaves nothing half-made.
"""

import hmac
from datetime import timedelta
from http import HTTPStatus

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.errors import AppError
from app.core.time import utcnow
from app.db.crud import get_or_404, not_found
from app.db.references import next_reference
from app.modules.audit import service as audit
from app.modules.companies import service as companies
from app.modules.companies.models import Company, Contact
from app.modules.companies.schemas import ContactIn
from app.modules.projects import service as projects
from app.modules.projects.models import ProjectStatus
from app.modules.projects.schemas import ProjectIn
from app.modules.requests.models import AssessmentRequest, RequestSource, RequestStatus
from app.modules.requests.schemas import (
    ConvertIn,
    ManualRequestIn,
    PublicRequestIn,
    RejectIn,
    RequestCountsOut,
    RequestPatch,
)
from app.modules.requests.transitions import REQUEST_TRANSITIONS
from app.modules.settings.models import Service
from app.modules.sites import service as sites
from app.modules.sites.models import Site
from app.modules.sites.schemas import SiteIn
from app.modules.users.models import User, UserLocale

INTAKE_PER_HOUR = 30
DUPLICATE_WINDOW = timedelta(hours=24)

# nest_web/src/config/translations.ts shows each service under these names (hy, en,
# ru); its contact form sends the name, not the slug. Keep in step with the site.
WEBSITE_SERVICE_NAMES: dict[str, str] = {
    "Որսացող Պաշտպանական Ցանցային համակարգի տեղադրում": "safety-system",
    "Safety Catching System Installation": "safety-system",
    "Монтаж системы улавливания безопасности": "safety-system",
    "Փոշու պաշտպանիչ համակարգի տեղադրում": "dust-protection",
    "Suite Dust-Protection System Installation": "dust-protection",
    "Монтаж системы защиты от пыли": "dust-protection",
}


def _blank(value: str | None) -> str | None:
    value = (value or "").strip()
    return value or None


async def _service_slug(session: AsyncSession, submitted: str | None) -> str | None:
    """Website name or slug → slug of an existing service, else None."""
    if not submitted:
        return None
    key = " ".join(submitted.split())
    by_name = {name.casefold(): slug for name, slug in WEBSITE_SERVICE_NAMES.items()}
    slug = by_name.get(key.casefold(), key.lower())
    exists = await session.scalar(select(Service.slug).where(Service.slug == slug))
    return exists


# --- public intake -------------------------------------------------------------------


def check_service_key(provided: str | None) -> None:
    expected = get_settings().intake_service_key
    if (
        expected is None
        or not provided
        or not hmac.compare_digest(provided.encode(), expected.get_secret_value().encode())
    ):
        raise AppError(
            "INVALID_SERVICE_KEY",
            "A valid X-Service-Key header is required.",
            status_code=HTTPStatus.UNAUTHORIZED,
        )


async def submit_public(session: AsyncSession, data: PublicRequestIn) -> AssessmentRequest:
    now = utcnow()
    recent = await session.scalar(
        select(func.count())
        .select_from(AssessmentRequest)
        .where(
            AssessmentRequest.source == RequestSource.WEBSITE,
            AssessmentRequest.created_at > now - timedelta(hours=1),
        )
    )
    if (recent or 0) >= INTAKE_PER_HOUR:
        raise AppError(
            "RATE_LIMITED",
            "Too many requests right now. Please call us instead.",
            status_code=HTTPStatus.TOO_MANY_REQUESTS,
        )
    phone, email = _blank(data.phone), _blank(data.email)
    message = data.message.strip()
    same_person = or_(
        *([AssessmentRequest.submitted_email == email] if email else []),
        *([AssessmentRequest.submitted_phone == phone] if phone else []),
    )
    duplicate = await session.scalar(
        select(AssessmentRequest)
        .where(
            same_person,
            AssessmentRequest.message == message,
            AssessmentRequest.created_at > now - DUPLICATE_WINDOW,
        )
        .order_by(AssessmentRequest.id)
        .limit(1)
    )
    if duplicate is not None:
        return duplicate  # double-click or re-send: same answer, no second lead
    request = AssessmentRequest(
        reference=await next_reference(session, "REQ"),
        source=RequestSource.WEBSITE,
        locale=data.locale,
        submitted_name=data.name.strip(),
        submitted_company=_blank(data.company),
        submitted_phone=phone,
        submitted_email=email,
        submitted_service=_blank(data.service),
        service_slug=await _service_slug(session, _blank(data.service)),
        project_type=_blank(data.project_type),
        message=message,
    )
    session.add(request)
    await session.flush()
    audit.record(
        session,
        "request.received",
        user_id=None,
        entity_type="assessment_request",
        entity_id=request.id,
        metadata={"reference": request.reference, "source": "website"},
    )
    await session.commit()
    await session.refresh(request)  # updated_at is set by the database
    return request


# --- manager side --------------------------------------------------------------------


async def create_manual(
    session: AsyncSession, data: ManualRequestIn, manager: User
) -> AssessmentRequest:
    if data.service_slug and await _service_slug(session, data.service_slug) is None:
        raise not_found("service")
    request = AssessmentRequest(
        reference=await next_reference(session, "REQ"),
        source=data.source,
        locale=data.locale,
        submitted_name=data.name.strip(),
        submitted_company=_blank(data.company),
        submitted_phone=_blank(data.phone),
        submitted_email=_blank(data.email),
        service_slug=data.service_slug,
        project_type=_blank(data.project_type),
        message=data.message.strip(),
        site_address=_blank(data.site_address),
    )
    session.add(request)
    await session.flush()
    audit.record(
        session,
        "request.created",
        user_id=manager.id,
        entity_type="assessment_request",
        entity_id=request.id,
        metadata={"reference": request.reference, "source": data.source.value},
    )
    await session.commit()
    await session.refresh(request)  # updated_at is set by the database
    return request


async def list_requests(
    session: AsyncSession,
    *,
    statuses: list[RequestStatus] | None,
    q: str | None,
    limit: int,
    offset: int,
) -> list[AssessmentRequest]:
    stmt = (
        select(AssessmentRequest).order_by(AssessmentRequest.id.desc()).limit(limit).offset(offset)
    )
    if statuses:
        stmt = stmt.where(AssessmentRequest.status.in_(statuses))
    if q:
        like = f"%{q.strip()}%"
        stmt = stmt.where(
            or_(
                AssessmentRequest.reference.ilike(like),
                AssessmentRequest.submitted_name.ilike(like),
                AssessmentRequest.submitted_company.ilike(like),
                AssessmentRequest.submitted_phone.ilike(like),
                AssessmentRequest.submitted_email.ilike(like),
            )
        )
    return list(await session.scalars(stmt))


async def counts(session: AsyncSession) -> RequestCountsOut:
    rows = dict(
        (s, n)
        for s, n in await session.execute(
            select(AssessmentRequest.status, func.count())
            .where(AssessmentRequest.status.in_([RequestStatus.NEW, RequestStatus.IN_REVIEW]))
            .group_by(AssessmentRequest.status)
        )
    )
    return RequestCountsOut(
        new=rows.get(RequestStatus.NEW, 0), in_review=rows.get(RequestStatus.IN_REVIEW, 0)
    )


async def get_request(session: AsyncSession, request_id: int) -> AssessmentRequest:
    return await get_or_404(session, AssessmentRequest, request_id, "assessment request")


def _move(
    session: AsyncSession, request: AssessmentRequest, target: RequestStatus, manager: User
) -> None:
    if request.status == target:
        return
    REQUEST_TRANSITIONS.check(request.status, target, manager.role)
    audit.record(
        session,
        "request.status_changed",
        user_id=manager.id,
        entity_type="assessment_request",
        entity_id=request.id,
        metadata={"from": request.status.value, "to": target.value},
    )
    request.status = target
    request.reviewed_by = manager.id


async def update_request(
    session: AsyncSession, request_id: int, patch: RequestPatch, manager: User
) -> AssessmentRequest:
    request = await get_request(session, request_id)
    if request.status is RequestStatus.CONVERTED:
        raise AppError(
            "REQUEST_CONVERTED",
            "This request is already a project.",
            status_code=HTTPStatus.CONFLICT,
        )
    changes = patch.model_dump(exclude_unset=True)
    if (
        changes.get("service_slug")
        and await _service_slug(session, changes["service_slug"]) is None
    ):
        raise not_found("service")
    if (target := changes.pop("status", None)) is not None:
        _move(session, request, target, manager)
    for field, value in changes.items():
        setattr(request, field, value)
    await session.commit()
    await session.refresh(request)  # updated_at is set by the database
    return request


async def reject(
    session: AsyncSession, request_id: int, data: RejectIn, manager: User
) -> AssessmentRequest:
    request = await get_request(session, request_id)
    _move(session, request, RequestStatus.SPAM if data.spam else RequestStatus.REJECTED, manager)
    request.review_note = data.reason
    await session.commit()
    await session.refresh(request)  # updated_at is set by the database
    return request


async def convert(
    session: AsyncSession, request_id: int, data: ConvertIn, manager: User
) -> AssessmentRequest:
    request = await get_request(session, request_id)
    REQUEST_TRANSITIONS.check(request.status, RequestStatus.CONVERTED, manager.role)

    company_id = data.company_id
    if company_id is not None:
        await get_or_404(session, Company, company_id, "company")
    elif data.new_company is not None:
        company_id = (await companies.create_company(session, data.new_company, commit=False)).id

    contact_id = data.contact_id
    if contact_id is not None:
        await get_or_404(session, Contact, contact_id, "contact")
    elif data.new_contact is not None:
        contact = await companies.create_contact(
            session,
            ContactIn(
                company_id=company_id,
                **data.new_contact.model_dump(),
                preferred_locale=UserLocale(request.locale) if request.locale else None,
            ),
            commit=False,
        )
        contact_id = contact.id

    site_id = data.site_id
    if site_id is not None:
        await get_or_404(session, Site, site_id, "site")
    else:
        assert data.new_site is not None  # noqa: S101 — checked by ConvertIn
        site = await sites.create_site(
            session,
            SiteIn(company_id=company_id, **data.new_site.model_dump()),
            manager.id,
            commit=False,
        )
        site_id = site.id

    project = await projects.create_project(
        session,
        ProjectIn(
            name=data.project.name,
            site_id=site_id,
            company_id=company_id,
            primary_contact_id=contact_id,
            service_slug=data.project.service_slug,
            expected_install_date=data.project.expected_install_date,
            manager_id=manager.id,
            notes=data.project.notes,
        ),
        manager.id,
        commit=False,
    )
    if data.project.status is ProjectStatus.SURVEY:
        projects.change_status(session, project, ProjectStatus.SURVEY, manager.role, manager.id)

    _move(session, request, RequestStatus.CONVERTED, manager)
    request.contact_id = contact_id
    request.project_id = project.id
    audit.record(
        session,
        "request.converted",
        user_id=manager.id,
        entity_type="assessment_request",
        entity_id=request.id,
        metadata={
            "project_id": project.id,
            "project_reference": project.reference,
            "company_id": company_id,
            "contact_id": contact_id,
            "site_id": site_id,
        },
    )
    await session.commit()
    await session.refresh(request)  # updated_at is set by the database
    return request
