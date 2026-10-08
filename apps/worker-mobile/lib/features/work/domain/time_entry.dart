import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_entry.freezed.dart';
part 'time_entry.g.dart';

enum TimeEntryKind { work, breakTime }

/// One work or break session. Durations are always `endedAt - startedAt`
/// (or `now - startedAt` while open) — never a counter.
@freezed
abstract class TimeEntry with _$TimeEntry {
  const TimeEntry._();

  const factory TimeEntry({
    required String id,
    required String taskId,
    required TimeEntryKind kind,
    required DateTime startedAt,
    DateTime? endedAt,
    String? startLocationCheckId,
  }) = _TimeEntry;

  factory TimeEntry.fromJson(Map<String, dynamic> json) =>
      _$TimeEntryFromJson(json);

  bool get isOpen => endedAt == null;

  /// Duration as of [now]; never negative (protects against device clock jumps).
  Duration durationAt(DateTime now) {
    final end = endedAt ?? now;
    final d = end.difference(startedAt);
    return d.isNegative ? Duration.zero : d;
  }
}
