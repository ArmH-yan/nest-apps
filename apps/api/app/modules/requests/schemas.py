from datetime import date, datetime
from decimal import Decimal
from typing import Literal, Self

from pydantic import BaseModel, ConfigDict, Field, model_validator

from app.core.schemas import Email
from app.modules.companies.schemas import CompanyIn
from app.modules.projects.models import ProjectStatus
from app.modules.requests.models import RequestSource, RequestStatus
from app.modules.sites.schemas import Latitude, Longitude, Radius


class PublicRequestIn(BaseModel):
    """`POST /public/assessment-requests` from nest_web (§12). The field names are
    the website's own and must stay as they are. Unknown fields are ignored."""

    model_config = ConfigDict(extra="ignore", populate_by_name=True)

    name: str = Field(min_length=1, max_length=200)
    company: str = Field(default="", max_length=200)
    phone: str = Field(default="", max_length=40)
    email: str = Field(default="", max_length=200)  # kept as typed, not validated
    service: str = Field(default="", max_length=200)
    project_type: str = Field(default="", max_length=200, alias="projectType")
    message: str = Field(min_length=1, max_length=5000)
    locale: Literal["hy", "ru", "en"] | None = None

    @model_validator(mode="after")
    def _reachable(self) -> Self:
        if not self.phone.strip() and not self.email.strip():
            raise ValueError("Give a phone number or an email address.")
        return self


class PublicRequestOut(BaseModel):
    reference: str


class ManualRequestIn(BaseModel):
    """A lead taken by phone or in person, entered by a manager."""

    source: Literal[RequestSource.PHONE, RequestSource.MANUAL] = RequestSource.PHONE
    name: str = Field(min_length=1, max_length=200)
    company: str | None = Field(default=None, max_length=200)
    phone: str | None = Field(default=None, max_length=40)
    email: str | None = Field(default=None, max_length=200)
    service_slug: str | None = Field(default=None, max_length=64)
    project_type: str | None = Field(default=None, max_length=200)
    message: str = Field(min_length=1, max_length=5000)
    site_address: str | None = Field(default=None, max_length=300)
    locale: Literal["hy", "ru", "en"] | None = None


class RequestPatch(BaseModel):
    """Start a review, or add what the call with the customer revealed."""

    status: Literal[RequestStatus.IN_REVIEW] | None = None
    service_slug: str | None = Field(default=None, max_length=64)
    site_address: str | None = Field(default=None, max_length=300)
    latitude: Latitude | None = None
    longitude: Longitude | None = None
    preferred_date: date | None = None
    review_note: str | None = Field(default=None, max_length=2000)


class RejectIn(BaseModel):
    reason: str = Field(min_length=1, max_length=2000)
    spam: bool = False


class NewContactIn(BaseModel):
    full_name: str = Field(min_length=1, max_length=200)
    position: str | None = Field(default=None, max_length=100)
    phone: str | None = Field(default=None, max_length=32)
    email: Email | None = None


class NewSiteIn(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    address: str = Field(min_length=1, max_length=300)
    latitude: Latitude
    longitude: Longitude
    geofence_radius_m: Radius | None = None
    access_notes: str | None = None


class NewProjectIn(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    service_slug: str = Field(max_length=64)
    status: Literal[ProjectStatus.LEAD, ProjectStatus.SURVEY] = ProjectStatus.LEAD
    expected_install_date: date | None = None
    notes: str | None = None


class ConvertIn(BaseModel):
    """One step from a lead to a project (§9). Each part is either an existing
    record (`*_id`) or a new one; a private customer has no company."""

    company_id: int | None = None
    new_company: CompanyIn | None = None
    contact_id: int | None = None
    new_contact: NewContactIn | None = None
    site_id: int | None = None
    new_site: NewSiteIn | None = None
    project: NewProjectIn

    @model_validator(mode="after")
    def _one_of_each(self) -> Self:
        if self.company_id is not None and self.new_company is not None:
            raise ValueError("Choose an existing company or a new one, not both.")
        if self.contact_id is not None and self.new_contact is not None:
            raise ValueError("Choose an existing contact or a new one, not both.")
        if (self.site_id is None) == (self.new_site is None):
            raise ValueError("Choose an existing site or describe a new one.")
        return self


class RequestOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    reference: str
    status: RequestStatus
    source: RequestSource
    locale: str | None
    submitted_name: str
    submitted_company: str | None
    submitted_phone: str | None
    submitted_email: str | None
    submitted_service: str | None
    service_slug: str | None
    project_type: str | None
    message: str
    site_address: str | None
    latitude: Decimal | None
    longitude: Decimal | None
    preferred_date: date | None
    review_note: str | None
    contact_id: int | None
    project_id: int | None
    reviewed_by: int | None
    created_at: datetime
    updated_at: datetime


class RequestCountsOut(BaseModel):
    """For the dashboard card and the sidebar badge (manager alerts, §41 Phase 4)."""

    new: int
    in_review: int
