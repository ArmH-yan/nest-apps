from pydantic import BaseModel

from app.modules.users.models import User, UserLocale, UserRole, Worker


class WorkerInfo(BaseModel):
    id: int
    employee_code: str


class MeResponse(BaseModel):
    id: int
    phone: str
    email: str | None
    first_name: str
    last_name: str
    full_name: str
    role: UserRole
    locale: UserLocale
    must_change_password: bool
    # present only for role WORKER
    worker: WorkerInfo | None

    @classmethod
    def build(cls, user: User, worker: Worker | None) -> "MeResponse":
        return cls(
            id=user.id,
            phone=user.phone,
            email=user.email,
            first_name=user.first_name,
            last_name=user.last_name,
            full_name=user.full_name,
            role=user.role,
            locale=user.locale,
            must_change_password=user.must_change_password,
            worker=(
                WorkerInfo(id=worker.id, employee_code=worker.employee_code) if worker else None
            ),
        )
