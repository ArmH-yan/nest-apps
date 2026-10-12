from decimal import Decimal
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field

Latitude = Annotated[Decimal, Field(ge=-90, le=90, max_digits=9, decimal_places=6)]
Longitude = Annotated[Decimal, Field(ge=-180, le=180, max_digits=9, decimal_places=6)]
Radius = Annotated[int, Field(ge=10, le=5000)]


class SiteIn(BaseModel):
    company_id: int | None = None
    name: str = Field(min_length=1, max_length=200)
    address: str = Field(min_length=1, max_length=300)
    latitude: Latitude
    longitude: Longitude
    location_confirmed: bool = False
    geofence_radius_m: Radius | None = None
    access_notes: str | None = None


class SitePatch(BaseModel):
    company_id: int | None = None
    name: str | None = Field(default=None, min_length=1, max_length=200)
    address: str | None = Field(default=None, min_length=1, max_length=300)
    latitude: Latitude | None = None
    longitude: Longitude | None = None
    location_confirmed: bool | None = None
    geofence_radius_m: Radius | None = None
    access_notes: str | None = None


class SiteOut(SiteIn):
    model_config = ConfigDict(from_attributes=True)
    id: int
