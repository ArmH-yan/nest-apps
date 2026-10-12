"""Typed access to the `settings` table. Missing keys fall back to DEFAULTS, so a
fresh database works without seeding."""

from dataclasses import dataclass

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.settings.models import Setting

DEFAULTS: dict[str, int] = {
    "default_geofence_radius_m": 150,
    "max_location_accuracy_m": 100,
    "min_completion_photos": 1,
    "start_window_minutes_before": 120,
    "clock_skew_flag_seconds": 300,
}


@dataclass(frozen=True)
class OperationalSettings:
    default_geofence_radius_m: int
    max_location_accuracy_m: int
    min_completion_photos: int
    start_window_minutes_before: int
    clock_skew_flag_seconds: int


async def get_operational(session: AsyncSession) -> OperationalSettings:
    rows = await session.execute(
        select(Setting.key, Setting.value).where(Setting.key.in_(DEFAULTS))
    )
    values = DEFAULTS | {key: int(value) for key, value in rows}
    return OperationalSettings(**values)
