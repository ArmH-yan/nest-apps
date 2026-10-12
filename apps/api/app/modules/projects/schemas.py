from datetime import date

from pydantic import BaseModel, ConfigDict, Field

from app.modules.projects.models import ProjectStatus


class ProjectIn(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    site_id: int
    company_id: int | None = None
    primary_contact_id: int | None = None
    service_slug: str = Field(max_length=64)
    expected_install_date: date | None = None
    expected_dismantle_date: date | None = None
    manager_id: int | None = None
    notes: str | None = None


class ProjectPatch(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=200)
    primary_contact_id: int | None = None
    # changed through the project transition table (§10)
    status: ProjectStatus | None = None
    expected_install_date: date | None = None
    expected_dismantle_date: date | None = None
    manager_id: int | None = None
    notes: str | None = None


class ProjectOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    reference: str
    name: str
    site_id: int
    company_id: int | None
    primary_contact_id: int | None
    service_slug: str
    status: ProjectStatus
    expected_install_date: date | None
    expected_dismantle_date: date | None
    manager_id: int | None
    notes: str | None
