"""`catalog_items` and `site_material_movements` (ARCHITECTURE §8, §16).

The catalog is shared with quotes (Phase 5); only the fields the worker app needs
are used now. The movement ledger is append-only: what is on a site is the sum.
"""

import uuid
from datetime import datetime
from decimal import Decimal
from enum import StrEnum

from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Identity,
    Numeric,
    String,
    Text,
    func,
    text,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, text_enum


class CatalogKind(StrEnum):
    MATERIAL = "MATERIAL"
    LABOR = "LABOR"
    SERVICE = "SERVICE"
    RENTAL = "RENTAL"


class Unit(StrEnum):
    M2 = "m2"
    M = "m"
    PCS = "pcs"
    DAY = "day"
    LUMP = "lump"


class Movement(StrEnum):
    INSTALLED = "INSTALLED"
    RETRIEVED = "RETRIEVED"
    DAMAGED = "DAMAGED"
    LOST = "LOST"
    ADJUSTMENT = "ADJUSTMENT"


class CatalogItem(TimestampMixin, Base):
    __tablename__ = "catalog_items"

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    sku: Mapped[str] = mapped_column(String(64), unique=True)
    name_hy: Mapped[str] = mapped_column(String(200))
    name_ru: Mapped[str] = mapped_column(String(200))
    name_en: Mapped[str] = mapped_column(String(200))
    kind: Mapped[CatalogKind] = mapped_column(text_enum(CatalogKind, "catalog_kind"))
    unit: Mapped[Unit] = mapped_column(text_enum(Unit, "catalog_unit"))
    # Phase 5 (quotes)
    default_price: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    # physical item tracked on site → offered in the worker app
    is_trackable: Mapped[bool] = mapped_column(Boolean, server_default=text("false"))
    is_active: Mapped[bool] = mapped_column(Boolean, server_default=text("true"))

    def name(self, locale: str) -> str:
        # hi/id crews read the English name
        return {"hy": self.name_hy, "ru": self.name_ru}.get(locale, self.name_en)


class SiteMaterialMovement(Base):
    __tablename__ = "site_material_movements"
    __table_args__ = (CheckConstraint("quantity > 0", name="quantity_positive"),)

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    site_id: Mapped[int] = mapped_column(ForeignKey("sites.id"), index=True)
    project_id: Mapped[int] = mapped_column(ForeignKey("projects.id"), index=True)
    job_id: Mapped[int | None] = mapped_column(ForeignKey("jobs.id"))
    assignment_id: Mapped[int | None] = mapped_column(ForeignKey("visit_assignments.id"))
    catalog_item_id: Mapped[int] = mapped_column(ForeignKey("catalog_items.id"))
    quantity: Mapped[Decimal] = mapped_column(Numeric(12, 3))
    movement: Mapped[Movement] = mapped_column(text_enum(Movement, "movement"))
    recorded_by: Mapped[int] = mapped_column(ForeignKey("users.id"))
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    note: Mapped[str | None] = mapped_column(Text)
    received_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
