import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/time/clock.dart';
import 'package:nest_worker/core/time/yerevan_time.dart';
import 'package:nest_worker/features/work/domain/duration_calculator.dart';
import 'package:nest_worker/features/work/domain/time_entry.dart';

import '../../support/fixtures.dart';

void main() {
  final t0 = nineAmYerevan;
  DateTime at(int minutes) => t0.add(Duration(minutes: minutes));

  test('single open work entry: duration is now - startedAt', () {
    final entries = [entry(TimeEntryKind.work, t0)];

    final totals = DurationCalculator.totals(
      entries,
      t0.add(const Duration(hours: 2, minutes: 34, seconds: 18)),
    );

    expect(formatHms(totals.work), '02:34:18');
    expect(totals.breakTime, Duration.zero);
  });

  test('multiple work/break cycles (09:00–12:00, break, 12:30–17:00)', () {
    final entries = [
      entry(TimeEntryKind.work, at(0), at(180)),
      entry(TimeEntryKind.breakTime, at(180), at(210)),
      entry(TimeEntryKind.work, at(210), at(480)),
    ];

    final totals = DurationCalculator.totals(entries, at(600));

    expect(totals.work, const Duration(hours: 7, minutes: 30));
    expect(totals.breakTime, const Duration(minutes: 30));
    expect(totals.total, const Duration(hours: 8));
    expect(DurationCalculator.firstStart(entries), at(0));
  });

  test('open break entry counts towards break time', () {
    final entries = [
      entry(TimeEntryKind.work, at(0), at(60)),
      entry(TimeEntryKind.breakTime, at(60)),
    ];

    final totals = DurationCalculator.totals(entries, at(75));

    expect(totals.work, const Duration(hours: 1));
    expect(totals.breakTime, const Duration(minutes: 15));
    expect(
      DurationCalculator.openEntry(entries)?.kind,
      TimeEntryKind.breakTime,
    );
  });

  test('advancing the clock changes totals without any timer firing', () {
    final clock = FixedClock(t0);
    final entries = [entry(TimeEntryKind.work, clock.now())];

    expect(DurationCalculator.totals(entries, clock.now()).work, Duration.zero);
    clock.advance(const Duration(hours: 5));
    expect(
      DurationCalculator.totals(entries, clock.now()).work,
      const Duration(hours: 5),
    );
  });

  test(
    'restoring the same entries later gives the same totals (app restart)',
    () {
      // Simulates: entries persisted, app killed, entries reloaded 3h later.
      final persisted = [
        entry(TimeEntryKind.work, at(0), at(120)).toJson(),
        entry(TimeEntryKind.breakTime, at(120), at(135)).toJson(),
        entry(TimeEntryKind.work, at(135)).toJson(),
      ];
      final reloaded = persisted.map(TimeEntry.fromJson).toList();

      final totals = DurationCalculator.totals(reloaded, at(300));

      expect(totals.work, const Duration(minutes: 120 + 165));
      expect(totals.breakTime, const Duration(minutes: 15));
    },
  );

  test('device clock moved backwards never yields negative durations', () {
    final entries = [entry(TimeEntryKind.work, at(60))];

    expect(DurationCalculator.totals(entries, at(0)).work, Duration.zero);
  });
}
