from pydantic import BaseModel, Field

from app.core.schemas import Email
from app.modules.users.models import UserLocale


class WorkerOut(BaseModel):
    id: int
    user_id: int
    employee_code: str
    first_name: str
    last_name: str
    full_name: str
    phone: str
    email: str | None
    locale: UserLocale
    skills: list[str]
    is_active: bool
    must_change_password: bool


class WorkerIn(BaseModel):
    """A new worker account. The manager sets the first password (§7); the worker
    must change it at first login."""

    phone: str = Field(max_length=32)
    first_name: str = Field(min_length=1, max_length=100)
    last_name: str = Field(min_length=1, max_length=100)
    employee_code: str = Field(min_length=1, max_length=32)
    initial_password: str = Field(min_length=8, max_length=128)
    email: Email | None = None
    locale: UserLocale = UserLocale.HY
    skills: list[str] = Field(default_factory=list, max_length=20)


class WorkerPatch(BaseModel):
    phone: str | None = Field(default=None, max_length=32)
    first_name: str | None = Field(default=None, min_length=1, max_length=100)
    last_name: str | None = Field(default=None, min_length=1, max_length=100)
    employee_code: str | None = Field(default=None, min_length=1, max_length=32)
    email: Email | None = None
    locale: UserLocale | None = None
    skills: list[str] | None = Field(default=None, max_length=20)
    # false = deactivate: signs the worker out everywhere (§7)
    is_active: bool | None = None


class ResetPasswordIn(BaseModel):
    new_password: str = Field(min_length=8, max_length=128)
