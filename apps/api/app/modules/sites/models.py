"""`sites` (ARCHITECTURE §8, §25). The map pin is the authoritative location: GPS
checks are measured against it."""

from decimal import Decimal

from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    ForeignKey,
    Identity,
    Integer,
    Numeric,
    String,
    Text,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin


class Site(TimestampMixin, Base):
    __tablename__ = "sites"
    __table_args__ = (
        CheckConstraint("latitude BETWEEN -90 AND 90", name="latitude_range"),
        CheckConstraint("longitude BETWEEN -180 AND 180", name="longitude_range"),
        CheckConstraint("geofence_radius_m BETWEEN 10 AND 5000", name="radius_range"),
    )

    id: Mapped[int] = mapped_column(BigInteger, Identity(), primary_key=True)
    company_id: Mapped[int | None] = mapped_column(ForeignKey("companies.id"), index=True)
    name: Mapped[str] = mapped_column(String(200))  # "Davtashen residential block 3"
    address: Mapped[str] = mapped_column(String(300))
    # numeric(9,6) ≈ 0.1 m precision; never float for stored coordinates
    latitude: Mapped[Decimal] = mapped_column(Numeric(9, 6))
    longitude: Mapped[Decimal] = mapped_column(Numeric(9, 6))
    # true once a person has placed or checked the pin on a map
    location_confirmed: Mapped[bool] = mapped_column(Boolean, server_default=text("false"))
    # null → settings.default_geofence_radius_m
    geofence_radius_m: Mapped[int | None] = mapped_column(Integer)
    # gate code, foreman, parking, height notes
    access_notes: Mapped[str | None] = mapped_column(Text)
