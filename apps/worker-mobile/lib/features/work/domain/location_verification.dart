import 'dart:math' as math;

import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_config.dart';

/// A position as reported by the device (see LocationService).
class GeoFix {
  const GeoFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
    required this.isMocked,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double accuracyM;
  final bool isMocked;
  final DateTime timestamp;
}

enum VerificationOutcome { verified, outside, lowAccuracy }

class LocationVerificationResult {
  const LocationVerificationResult({
    required this.outcome,
    required this.distanceMeters,
    required this.accuracyMeters,
    required this.radiusMeters,
    required this.isMocked,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.workLatitude,
    required this.workLongitude,
    required this.timestamp,
  });

  final VerificationOutcome outcome;
  final double distanceMeters;
  final double accuracyMeters;
  final double radiusMeters;
  final bool isMocked;
  final double currentLatitude;
  final double currentLongitude;
  final double workLatitude;
  final double workLongitude;
  final DateTime timestamp;

  bool get verified => outcome == VerificationOutcome.verified;
}

/// Pure geofence logic (no GPS access here — see LocationService).
abstract final class LocationVerificationService {
  static const double _earthRadiusM = 6371000;

  /// Great-circle distance in meters.
  static double haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    double rad(double deg) => deg * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLon = rad(lon2 - lon1);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * _earthRadiusM * math.asin(math.min(1, math.sqrt(a)));
  }

  static LocationVerificationResult verify({
    required GeoFix fix,
    required Task task,
    required TaskConfig config,
  }) {
    final radius = task.radiusM(config);
    final distance = haversineMeters(
      fix.latitude,
      fix.longitude,
      task.latitude,
      task.longitude,
    );
    final VerificationOutcome outcome;
    if (fix.accuracyM > config.maxLocationAccuracyM) {
      outcome = VerificationOutcome.lowAccuracy;
    } else if (distance <= radius) {
      outcome = VerificationOutcome.verified;
    } else {
      outcome = VerificationOutcome.outside;
    }
    return LocationVerificationResult(
      outcome: outcome,
      distanceMeters: distance,
      accuracyMeters: fix.accuracyM,
      radiusMeters: radius,
      isMocked: fix.isMocked,
      currentLatitude: fix.latitude,
      currentLongitude: fix.longitude,
      workLatitude: task.latitude,
      workLongitude: task.longitude,
      timestamp: fix.timestamp,
    );
  }
}
