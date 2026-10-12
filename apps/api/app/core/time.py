"""Time helpers. Everything is stored in UTC; Armenia is UTC+4 all year (no DST since
2012), so a fixed offset is exact and needs no timezone database at runtime."""

from datetime import UTC, datetime, timedelta, timezone

YEREVAN = timezone(timedelta(hours=4), "Asia/Yerevan")


def utcnow() -> datetime:
    return datetime.now(UTC)


def yerevan_month_bounds(year: int, month: int) -> tuple[datetime, datetime]:
    """[start, end) of a Yerevan calendar month, as UTC instants."""
    start = datetime(year, month, 1, tzinfo=YEREVAN)
    end = datetime(year + month // 12, month % 12 + 1, 1, tzinfo=YEREVAN)
    return start.astimezone(UTC), end.astimezone(UTC)


def yerevan_short(instant: datetime | None) -> str:
    """'13.10 09:00' in Yerevan time (notification texts)."""
    if instant is None:
        return ""
    return instant.astimezone(YEREVAN).strftime("%d.%m %H:%M")
