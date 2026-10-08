import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/features/tasks/domain/task_config.dart';
import 'package:nest_worker/features/work/domain/location_verification.dart';

import '../../support/fixtures.dart';

GeoFix fix(
  double lat,
  double lon, {
  double accuracy = 10,
  bool mocked = false,
}) => GeoFix(
  latitude: lat,
  longitude: lon,
  accuracyM: accuracy,
  isMocked: mocked,
  timestamp: nineAmYerevan,
);

void main() {
  const config = TaskConfig(); // default radius 150 m, accuracy limit 100 m

  test(
    'haversine distance matches known value (Yerevan, ~1.11 km per 0.01° lat)',
    () {
      final d = LocationVerificationService.haversineMeters(
        40.1812,
        44.5146,
        40.1912,
        44.5146,
      );

      expect(d, closeTo(1111.95, 1));
    },
  );

  test('inside the radius is verified', () {
    final task = buildTask();
    // ~32 m north of the site
    final result = LocationVerificationService.verify(
      fix: fix(task.latitude + 0.000288, task.longitude),
      task: task,
      config: config,
    );

    expect(result.outcome, VerificationOutcome.verified);
    expect(result.distanceMeters, closeTo(32, 1));
    expect(result.radiusMeters, 150);
  });

  test('outside the radius is not verified', () {
    final task = buildTask();
    final result = LocationVerificationService.verify(
      fix: fix(task.latitude + 0.0078, task.longitude), // ~870 m
      task: task,
      config: config,
    );

    expect(result.outcome, VerificationOutcome.outside);
    expect(result.verified, isFalse);
  });

  test('boundary: exactly on the radius counts as inside', () {
    final task = buildTask(radius: 200);
    final onEdge = LocationVerificationService.haversineMeters(
      task.latitude,
      task.longitude,
      task.latitude + 0.0017987,
      task.longitude,
    );
    final result = LocationVerificationService.verify(
      fix: fix(task.latitude + 0.0017987, task.longitude),
      task: task.copyWith(geofenceRadiusM: onEdge),
      config: config,
    );

    expect(result.verified, isTrue);
  });

  test('task radius overrides the config default', () {
    final task = buildTask(radius: 50);
    final result = LocationVerificationService.verify(
      fix: fix(task.latitude + 0.0009, task.longitude), // ~100 m
      task: task,
      config: config,
    );

    expect(result.radiusMeters, 50);
    expect(result.outcome, VerificationOutcome.outside);
  });

  test('config default radius is used when the task has none', () {
    final task = buildTask();
    final result = LocationVerificationService.verify(
      fix: fix(task.latitude + 0.0009, task.longitude), // ~100 m
      task: task,
      config: const TaskConfig(defaultGeofenceRadiusM: 120),
    );

    expect(result.radiusMeters, 120);
    expect(result.verified, isTrue);
  });

  test('low accuracy fix is rejected even when inside', () {
    final task = buildTask();
    final result = LocationVerificationService.verify(
      fix: fix(task.latitude, task.longitude, accuracy: 250),
      task: task,
      config: config,
    );

    expect(result.outcome, VerificationOutcome.lowAccuracy);
  });

  test('mocked location is recorded, not rejected', () {
    final task = buildTask();
    final result = LocationVerificationService.verify(
      fix: fix(task.latitude, task.longitude, mocked: true),
      task: task,
      config: config,
    );

    expect(result.verified, isTrue);
    expect(result.isMocked, isTrue);
  });
}
