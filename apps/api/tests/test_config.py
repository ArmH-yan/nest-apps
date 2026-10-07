import pytest

from app.core.config import Settings


def test_cors_origins_are_split(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("CORS_ORIGINS", "http://localhost:3001, https://manager.example.com")

    settings = Settings()

    assert settings.cors_origins == ["http://localhost:3001", "https://manager.example.com"]


def test_database_url_is_required(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("DATABASE_URL", raising=False)

    with pytest.raises(ValueError, match="database_url"):
        Settings(_env_file=None)
