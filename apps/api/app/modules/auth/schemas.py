from typing import Literal, Self

from pydantic import BaseModel, Field, model_validator

from app.modules.users.schemas import MeResponse


class LoginRequest(BaseModel):
    """Phone is the normal identifier and email is optional (ARCHITECTURE §7).
    Send exactly one of them."""

    phone: str | None = Field(default=None, max_length=32)
    email: str | None = Field(default=None, max_length=254)
    password: str = Field(min_length=1, max_length=128)
    # stable per-install id from the worker app; helps managers see sessions
    device_id: str | None = Field(default=None, max_length=128)

    @model_validator(mode="after")
    def _one_identifier(self) -> Self:
        if (self.phone is None) == (self.email is None):
            raise ValueError("Send exactly one of phone or email.")
        return self


class RefreshRequest(BaseModel):
    refresh_token: str = Field(min_length=1, max_length=256)


class ChangePasswordRequest(BaseModel):
    current_password: str = Field(min_length=1, max_length=128)
    new_password: str = Field(min_length=8, max_length=128)


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: Literal["bearer"] = "bearer"  # noqa: S105 — OAuth token type, not a secret
    # access token lifetime in seconds
    expires_in: int


class LoginResponse(TokenResponse):
    user: MeResponse
