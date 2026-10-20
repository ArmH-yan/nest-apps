from datetime import date
from typing import Self

from pydantic import BaseModel, Field, model_validator

from app.core.schemas import Email
from app.modules.users.models import UserLocale
from app.modules.workers.models import TimeOffReason


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


class TimeOffIn(BaseModel):
    """Whole Yerevan days, both inclusive."""

    first_day: date
    last_day: date
    reason: TimeOffReason
    note: str | None = Field(default=None, max_length=500)

    @model_validator(mode="after")
    def _ordered(self) -> Self:
        if self.last_day < self.first_day:
            raise ValueError("last_day must not be before first_day.")
        if (self.last_day - self.first_day).days > 366:
            raise ValueError("Time off can't be longer than a year.")
        return self


class TimeOffOut(BaseModel):
    id: int
    worker_id: int
    worker_name: str
    first_day: date
    last_day: date
    reason: TimeOffReason
    note: str | None
    # non-cancelled tasks of this worker inside the absence: a warning for the
    # manager (time off doesn't block scheduling, §14)
    booked_tasks: int
