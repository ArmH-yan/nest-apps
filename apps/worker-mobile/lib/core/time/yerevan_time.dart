/// Display time is always Asia/Yerevan (CLAUDE.md). Armenia has used UTC+4 with
/// no daylight saving since 2012, so a fixed offset is exact and needs no
/// timezone database. All stored timestamps stay UTC.
abstract final class YerevanTime {
  static const Duration offset = Duration(hours: 4);

  /// Wall-clock time in Yerevan, returned as a UTC-flagged DateTime whose
  /// fields read as Yerevan local time. Use only for display / day math.
  static DateTime wallClock(DateTime instant) => instant.toUtc().add(offset);

  /// Calendar day (Yerevan) of [instant], as a date-only value.
  static DateTime day(DateTime instant) {
    final w = wallClock(instant);
    return DateTime.utc(w.year, w.month, w.day);
  }

  static bool isSameDay(DateTime a, DateTime b) => day(a) == day(b);

  /// UTC instant for Yerevan wall-clock [year]-[month]-[day] [hour]:[minute].
  static DateTime at(
    int year,
    int month,
    int day, [
    int hour = 0,
    int minute = 0,
  ]) => DateTime.utc(year, month, day, hour, minute).subtract(offset);

  /// "09:05"
  static String hm(DateTime instant) {
    final w = wallClock(instant);
    return '${_two(w.hour)}:${_two(w.minute)}';
  }

  /// "07.10.2026"
  static String date(DateTime instant) {
    final w = wallClock(instant);
    return '${_two(w.day)}.${_two(w.month)}.${w.year}';
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}

/// "02:34:18" — used by the big timers. Negative values show as 00:00:00.
String formatHms(Duration d) {
  final total = d.isNegative ? 0 : d.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(h)}:${two(m)}:${two(s)}';
}
