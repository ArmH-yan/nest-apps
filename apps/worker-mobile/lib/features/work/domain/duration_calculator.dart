import 'time_entry.dart';

class WorkTotals {
  const WorkTotals({required this.work, required this.breakTime});

  static const zero = WorkTotals(work: Duration.zero, breakTime: Duration.zero);

  final Duration work;
  final Duration breakTime;

  Duration get total => work + breakTime;
}

/// Pure totals over any number of work/break cycles (WORKER_APP_SPEC "Break timer").
abstract final class DurationCalculator {
  static WorkTotals totals(Iterable<TimeEntry> entries, DateTime now) {
    var work = Duration.zero;
    var breakTime = Duration.zero;
    for (final e in entries) {
      final d = e.durationAt(now);
      if (e.kind == TimeEntryKind.work) {
        work += d;
      } else {
        breakTime += d;
      }
    }
    return WorkTotals(work: work, breakTime: breakTime);
  }

  /// The open entry, if any (at most one per task by construction).
  static TimeEntry? openEntry(Iterable<TimeEntry> entries) {
    for (final e in entries) {
      if (e.isOpen) return e;
    }
    return null;
  }

  /// Start of the first work session.
  static DateTime? firstStart(Iterable<TimeEntry> entries) {
    DateTime? first;
    for (final e in entries) {
      if (e.kind == TimeEntryKind.work &&
          (first == null || e.startedAt.isBefore(first))) {
        first = e.startedAt;
      }
    }
    return first;
  }
}
