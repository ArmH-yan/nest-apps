/// Injectable source of "now".
///
/// Timers and durations are always computed from stored timestamps and
/// `clock.now()` — never from a counter (CLAUDE.md, WORKER_APP_SPEC "Work timer").
/// Tests use [FixedClock] to move time without waiting.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

class FixedClock implements Clock {
  FixedClock(DateTime start) : _now = start.toUtc();

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration by) => _now = _now.add(by);

  void set(DateTime value) => _now = value.toUtc();
}
