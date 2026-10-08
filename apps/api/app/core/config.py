"""Application settings, read from environment variables (and the repo-root `.env`)."""

from functools import lru_cache
from pathlib import Path
from typing import Annotated, Literal

from pydantic import Field, PostgresDsn, SecretStr, field_validator
from pydantic_settings import BaseSettings, NoDecode, SettingsConfigDict

# apps/api/app/core/config.py -> repo root is four levels up
REPO_ROOT = Path(__file__).resolve().parents[4]


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=(REPO_ROOT / ".env", ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_env: Literal["development", "test", "production"] = "development"
    # Required — no default, so a missing value fails fast instead of using a guessed secret.
    database_url: PostgresDsn
    # Separate database for the pytest suite; never the development/production one.
    test_database_url: PostgresDsn | None = None
    cors_origins: Annotated[list[str], NoDecode] = []
    log_level: str = "INFO"

    # Auth (ARCHITECTURE §7). Required: signs access tokens.
    jwt_secret: SecretStr = Field(min_length=32)
    access_token_ttl_minutes: int = 15
    # Sliding: every refresh issues a new token with a fresh lifetime.
    refresh_token_ttl_days: int = 60
    # Failed logins allowed per phone/email within the window before 429.
    login_max_failures: int = 5
    login_failure_window_minutes: int = 15

    @field_validator("cors_origins", mode="before")
    @classmethod
    def _split_origins(cls, value: object) -> object:
        if isinstance(value, str):
            return [origin.strip() for origin in value.split(",") if origin.strip()]
        return value

    @property
    def is_production(self) -> bool:
        return self.app_env == "production"


@lru_cache
def get_settings() -> Settings:
    return Settings()  # values come from the environment
