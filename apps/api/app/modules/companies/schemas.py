from pydantic import BaseModel, ConfigDict, Field

from app.core.schemas import Email
from app.modules.users.models import UserLocale


class CompanyIn(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    tax_id: str | None = Field(default=None, max_length=20)
    phone: str | None = Field(default=None, max_length=32)
    email: Email | None = None
    address: str | None = Field(default=None, max_length=300)
    notes: str | None = None


class CompanyPatch(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=200)
    tax_id: str | None = Field(default=None, max_length=20)
    phone: str | None = Field(default=None, max_length=32)
    email: Email | None = None
    address: str | None = Field(default=None, max_length=300)
    notes: str | None = None


class CompanyOut(CompanyIn):
    model_config = ConfigDict(from_attributes=True)
    id: int
    email: str | None = None  # stored data is not re-validated on the way out


class ContactIn(BaseModel):
    company_id: int | None = None
    full_name: str = Field(min_length=1, max_length=200)
    position: str | None = Field(default=None, max_length=100)
    phone: str | None = Field(default=None, max_length=32)
    email: Email | None = None
    preferred_locale: UserLocale | None = None


class ContactPatch(BaseModel):
    company_id: int | None = None
    full_name: str | None = Field(default=None, min_length=1, max_length=200)
    position: str | None = Field(default=None, max_length=100)
    phone: str | None = Field(default=None, max_length=32)
    email: Email | None = None
    preferred_locale: UserLocale | None = None


class ContactOut(ContactIn):
    model_config = ConfigDict(from_attributes=True)
    id: int
    email: str | None = None
