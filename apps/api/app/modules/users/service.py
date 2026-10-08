"""User accounts. There is no self-registration (ARCHITECTURE §7). Accounts are created
by an admin: for now with the `app.cli create-user` command, and from Phase 3 in the
manager app."""

import re
from http import HTTPStatus

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.core.security import hash_password
from app.modules.audit import service as audit
from app.modules.users.models import User, UserLocale, UserRole, Worker

_PHONE_RE = re.compile(r"^\+?[0-9]{8,15}$")


def normalize_phone(raw: str) -> str:
    """'+374 91 00-00-07' → '+37491000007'. Raises INVALID_PHONE if it isn't a number."""
    phone = re.sub(r"[\s\-().]", "", raw)
    if not _PHONE_RE.fullmatch(phone):
        raise AppError("INVALID_PHONE", "The phone number is not valid.")
    return phone


def normalize_email(raw: str) -> str:
    return raw.strip().lower()


async def create_user(
    session: AsyncSession,
    *,
    phone: str,
    password: str,
    first_name: str,
    last_name: str,
    role: UserRole,
    email: str | None = None,
    locale: UserLocale = UserLocale.HY,
    must_change_password: bool = True,
    employee_code: str | None = None,
    created_by: int | None = None,
) -> User:
    """Creates the user (and the `workers` row for WORKER) and commits."""
    if (role is UserRole.WORKER) != (employee_code is not None):
        raise AppError(
            "EMPLOYEE_CODE_REQUIRED",
            "Workers need an employee code; other roles must not have one.",
        )
    user = User(
        phone=normalize_phone(phone),
        email=normalize_email(email) if email else None,
        password_hash=hash_password(password),
        first_name=first_name.strip(),
        last_name=last_name.strip(),
        role=role,
        locale=locale,
        must_change_password=must_change_password,
    )
    session.add(user)
    try:
        await session.flush()
        if employee_code is not None:
            session.add(Worker(user_id=user.id, employee_code=employee_code.strip()))
        audit.record(
            session,
            "user.created",
            user_id=created_by,
            entity_type="user",
            entity_id=user.id,
            metadata={"role": role.value},
        )
        await session.commit()
    except IntegrityError as exc:
        await session.rollback()
        raise AppError(
            "USER_ALREADY_EXISTS",
            "A user with this phone, email or employee code already exists.",
            status_code=HTTPStatus.CONFLICT,
        ) from exc
    return user


async def get_worker_for_user(session: AsyncSession, user_id: int) -> Worker | None:
    return await session.scalar(select(Worker).where(Worker.user_id == user_id))
