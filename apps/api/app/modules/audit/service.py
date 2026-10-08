"""Audit logging (ARCHITECTURE §31).

`record()` only adds the row to the session. The calling service commits it
together with the business change, so the log and the change succeed or fail
together.
"""

import ipaddress
from typing import Any

from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.audit.models import AuditLog


def record(
    session: AsyncSession,
    action: str,
    *,
    user_id: int | None,
    entity_type: str | None = None,
    entity_id: int | str | None = None,
    metadata: dict[str, Any] | None = None,
    ip: str | None = None,
) -> AuditLog:
    entry = AuditLog(
        user_id=user_id,
        action=action,
        entity_type=entity_type,
        entity_id=None if entity_id is None else str(entity_id),
        meta=metadata or {},
        ip=_valid_ip(ip),
    )
    session.add(entry)
    return entry


def _valid_ip(ip: str | None) -> str | None:
    """The column is INET. Anything that isn't an address is dropped."""
    if ip is None:
        return None
    try:
        return str(ipaddress.ip_address(ip))
    except ValueError:
        return None
