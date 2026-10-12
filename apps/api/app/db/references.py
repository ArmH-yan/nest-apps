"""Human-facing references such as `P-2026-0007` (ARCHITECTURE §8).

One row per (prefix, year). `next_reference` increments it with a single
UPDATE … RETURNING inside the caller's transaction, so concurrent creates never
get the same number.
"""

from datetime import UTC, datetime, timedelta

from sqlalchemy import Integer, String
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base

_YEREVAN_OFFSET_HOURS = 4  # Armenia: UTC+4, no DST


class ReferenceCounter(Base):
    __tablename__ = "reference_counters"

    prefix: Mapped[str] = mapped_column(String(8), primary_key=True)
    year: Mapped[int] = mapped_column(Integer, primary_key=True)
    last_value: Mapped[int] = mapped_column(Integer)


async def next_reference(session: AsyncSession, prefix: str) -> str:
    year = (datetime.now(UTC) + timedelta(hours=_YEREVAN_OFFSET_HOURS)).year
    stmt = (
        insert(ReferenceCounter)
        .values(prefix=prefix, year=year, last_value=1)
        .on_conflict_do_update(
            index_elements=[ReferenceCounter.prefix, ReferenceCounter.year],
            set_={"last_value": ReferenceCounter.last_value + 1},
        )
        .returning(ReferenceCounter.last_value)
    )
    value = (await session.execute(stmt)).scalar_one()
    return f"{prefix}-{year}-{value:04d}"
