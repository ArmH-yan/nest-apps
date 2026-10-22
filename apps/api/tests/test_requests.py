"""Intake (ARCHITECTURE §9, §12): the website's payload unchanged, the service key,
duplicates and rate limit, review / reject / spam, and one-transaction conversion."""

from collections.abc import Iterator
from typing import Any

import pytest
from httpx import AsyncClient
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.modules.audit.models import AuditLog
from app.modules.companies.models import Company
from app.modules.requests import service as intake
from app.modules.users.models import UserRole
from tests.factories import make_user, make_worker, token

KEY = "test-intake-key-0123456789"
URL = "/api/v1/public/assessment-requests"

# exactly what nest_web's contact form sends (field names and the Armenian service name)
WEBSITE_LEAD = {
    "name": "Hayk Avetisyan",
    "company": "Arm Build LLC",
    "phone": "+37493000101",
    "email": "hayk@armbuild.am",
    "service": "Որսացող Պաշտպանական Ցանցային համակարգի տեղադրում",
    "projectType": "Բարձրահարկ շինարարություն",
    "message": "We need a safety net on a 16-storey building in Davtashen.",
}


@pytest.fixture(autouse=True)
def intake_key(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    monkeypatch.setenv("INTAKE_SERVICE_KEY", KEY)
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


async def manager(client: AsyncClient, session: AsyncSession) -> dict[str, str]:
    await make_user(session, "+37491000001", UserRole.MANAGER, first="Mane")
    return await token(client, "+37491000001")


async def submit(client: AsyncClient, body: dict[str, Any], key: str | None = KEY) -> Any:
    headers = {"X-Service-Key": key} if key else {}
    return await client.post(URL, json=body, headers=headers)


async def test_website_lead_is_kept_as_received_and_matched_to_a_service(
    client: AsyncClient, session: AsyncSession
) -> None:
    m = await manager(client, session)

    r = await submit(client, WEBSITE_LEAD | {"locale": "hy", "turnstileToken": "x"})
    [row] = (await client.get("/api/v1/assessment-requests", headers=m)).json()
    counts = (await client.get("/api/v1/assessment-requests/counts", headers=m)).json()

    assert r.status_code == 201
    assert r.json()["reference"].startswith("REQ-") and r.json()["reference"] == row["reference"]
    assert row["status"] == "NEW" and row["source"] == "website" and row["locale"] == "hy"
    assert row["submitted_name"] == "Hayk Avetisyan"
    assert row["submitted_service"] == WEBSITE_LEAD["service"]
    assert row["service_slug"] == "safety-system"
    assert row["project_type"] == WEBSITE_LEAD["projectType"]
    assert counts == {"new": 1, "in_review": 0}
    assert await session.scalar(select(AuditLog.id).where(AuditLog.action == "request.received"))


@pytest.mark.parametrize(
    ("service", "slug"),
    [
        ("Suite Dust-Protection System Installation", "dust-protection"),
        ("Монтаж системы улавливания безопасности", "safety-system"),
        ("dust-protection", "dust-protection"),
        ("Something else", None),
    ],
)
async def test_service_names_in_every_language_map_to_slugs(
    session: AsyncSession, service: str, slug: str | None
) -> None:
    assert await intake._service_slug(session, service) == slug


async def test_the_service_key_is_required(
    client: AsyncClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    missing = await submit(client, WEBSITE_LEAD, key=None)
    wrong = await submit(client, WEBSITE_LEAD, key="nope")
    monkeypatch.delenv("INTAKE_SERVICE_KEY")
    get_settings.cache_clear()
    unconfigured = await submit(client, WEBSITE_LEAD)

    for r in (missing, wrong, unconfigured):
        assert r.status_code == 401 and r.json()["error"]["code"] == "INVALID_SERVICE_KEY"


async def test_a_lead_needs_a_name_a_message_and_a_way_to_reach_them(client: AsyncClient) -> None:
    no_contact = await submit(client, WEBSITE_LEAD | {"phone": "", "email": "  "})
    no_message = await submit(client, WEBSITE_LEAD | {"message": ""})

    assert no_contact.status_code == 422 and no_message.status_code == 422


async def test_a_resent_lead_is_not_duplicated_and_floods_are_refused(
    client: AsyncClient, session: AsyncSession
) -> None:
    first = await submit(client, WEBSITE_LEAD)
    again = await submit(client, WEBSITE_LEAD)
    assert again.status_code == 201 and again.json() == first.json()

    for i in range(intake.INTAKE_PER_HOUR - 1):
        await submit(client, WEBSITE_LEAD | {"message": f"lead {i}"})
    flood = await submit(client, WEBSITE_LEAD | {"message": "one too many"})

    assert flood.status_code == 429 and flood.json()["error"]["code"] == "RATE_LIMITED"


async def test_review_reject_spam_and_reopen(client: AsyncClient, session: AsyncSession) -> None:
    m = await manager(client, session)
    await submit(client, WEBSITE_LEAD)
    [row] = (await client.get("/api/v1/assessment-requests", headers=m)).json()
    url = f"/api/v1/assessment-requests/{row['id']}"

    review = await client.patch(
        url, headers=m, json={"status": "IN_REVIEW", "site_address": "Davtashen 3"}
    )
    spam = await client.post(f"{url}/reject", headers=m, json={"reason": "bot", "spam": True})
    reopened = await client.patch(url, headers=m, json={"status": "IN_REVIEW"})
    rejected = await client.post(f"{url}/reject", headers=m, json={"reason": "Too far away"})
    filtered = (
        await client.get(
            "/api/v1/assessment-requests", headers=m, params={"status": ["REJECTED", "SPAM"]}
        )
    ).json()

    assert review.status_code == 200, review.text
    assert review.json()["status"] == "IN_REVIEW" and review.json()["site_address"] == "Davtashen 3"
    assert spam.json()["status"] == "SPAM"
    assert reopened.json()["status"] == "IN_REVIEW"
    assert (
        rejected.json()["status"] == "REJECTED" and rejected.json()["review_note"] == "Too far away"
    )
    assert [r["id"] for r in filtered] == [row["id"]]


def convert_body(**overrides: Any) -> dict[str, Any]:
    return {
        "new_company": {"name": "Arm Build LLC", "phone": "+37410500100"},
        "new_contact": {"full_name": "Hayk Avetisyan", "phone": "+37493000101"},
        "new_site": {
            "name": "Building A",
            "address": "Davtashen 3rd district, Yerevan",
            "latitude": "40.226200",
            "longitude": "44.493000",
        },
        "project": {
            "name": "Davtashen Residential",
            "service_slug": "safety-system",
            "status": "SURVEY",
        },
    } | overrides


async def test_conversion_creates_company_contact_site_and_project_together(
    client: AsyncClient, session: AsyncSession
) -> None:
    m = await manager(client, session)
    await submit(client, WEBSITE_LEAD | {"locale": "ru"})
    [row] = (await client.get("/api/v1/assessment-requests", headers=m)).json()
    url = f"/api/v1/assessment-requests/{row['id']}"

    converted = await client.post(f"{url}/convert", headers=m, json=convert_body())
    assert converted.status_code == 200, converted.text
    project = (
        await client.get(f"/api/v1/projects/{converted.json()['project_id']}", headers=m)
    ).json()
    contacts = (await client.get("/api/v1/contacts", headers=m)).json()
    twice = await client.post(f"{url}/convert", headers=m, json=convert_body())
    edit = await client.patch(url, headers=m, json={"review_note": "late"})

    assert converted.status_code == 200, converted.text
    assert converted.json()["status"] == "CONVERTED"
    assert project["status"] == "SURVEY" and project["name"] == "Davtashen Residential"
    assert project["primary_contact_id"] == converted.json()["contact_id"]
    [contact] = contacts
    assert contact["company_id"] == project["company_id"]
    assert contact["preferred_locale"] == "ru"
    assert twice.json()["error"]["code"] == "INVALID_TRANSITION"
    assert edit.json()["error"]["code"] == "REQUEST_CONVERTED"


async def test_a_failed_conversion_leaves_nothing_behind(
    client: AsyncClient, session: AsyncSession
) -> None:
    m = await manager(client, session)
    await submit(client, WEBSITE_LEAD)
    [row] = (await client.get("/api/v1/assessment-requests", headers=m)).json()
    bad = convert_body(project={"name": "X", "service_slug": "no-such-service"})

    r = await client.post(f"/api/v1/assessment-requests/{row['id']}/convert", headers=m, json=bad)
    after = (await client.get(f"/api/v1/assessment-requests/{row['id']}", headers=m)).json()

    assert r.status_code == 404
    assert await session.scalar(select(func.count()).select_from(Company)) == 0
    assert after["status"] == "NEW" and after["project_id"] is None


async def test_phone_leads_by_managers_and_workers_are_kept_out(
    client: AsyncClient, session: AsyncSession
) -> None:
    m = await manager(client, session)
    await make_worker(session, "+37491000007")
    w = await token(client, "+37491000007")

    phone = await client.post(
        "/api/v1/assessment-requests",
        headers=m,
        json={
            "name": "Karen",
            "phone": "+37455000000",
            "message": "Called about dust nets",
            "service_slug": "dust-protection",
        },
    )
    worker = await client.get("/api/v1/assessment-requests", headers=w)

    assert phone.status_code == 201 and phone.json()["source"] == "phone"
    assert worker.status_code == 403
