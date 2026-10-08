import 'package:geolocator/geolocator.dart';

import '../../features/profile/data/settings_repository.dart';
import '../../features/tasks/domain/task.dart';
import '../../features/work/domain/location_verification.dart';
import '../time/clock.dart';

enum LocationFailure {
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}

class LocationException implements Exception {
  const LocationException(this.failure);

  final LocationFailure failure;

  @override
  String toString() => 'LocationException($failure)';
}

/// Device GPS behind an interface; widgets never call geolocator directly.
abstract interface class LocationService {
  /// Requests permission if needed and returns one high-accuracy fix.
  /// [near] is used only by the mock to place the fix relative to a site.
  Future<GeoFix> currentFix({Task? near});

  Future<bool> openAppSettings();

  Future<bool> openLocationSettings();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<GeoFix> currentFix({Task? near}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationFailure.servicesDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationFailure.permissionDeniedForever);
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw const LocationException(LocationFailure.permissionDenied);
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return GeoFix(
        latitude: p.latitude,
        longitude: p.longitude,
        accuracyM: p.accuracy,
        isMocked: p.isMocked,
        timestamp: p.timestamp.toUtc(),
      );
    } on LocationServiceDisabledException {
      throw const LocationException(LocationFailure.servicesDisabled);
    } on PermissionDeniedException {
      throw const LocationException(LocationFailure.permissionDenied);
    } on Exception catch (e) {
      throw LocationException(
        e.runtimeType.toString().contains('Timeout')
            ? LocationFailure.timeout
            : LocationFailure.unknown,
      );
    }
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}

/// Deterministic fixes for development and tests (WORKER_APP_SPEC "Mock data").
class MockLocationService implements LocationService {
  MockLocationService({required this.source, required Clock clock})
    : _clock = clock;

  final GpsSource source;
  final Clock _clock;

  @override
  Future<GeoFix> currentFix({Task? near}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final lat = near?.latitude ?? 40.1812;
    final lon = near?.longitude ?? 44.5146;
    GeoFix fix(double dLat, double accuracy) => GeoFix(
      latitude: lat + dLat,
      longitude: lon,
      accuracyM: accuracy,
      isMocked: false,
      timestamp: _clock.now(),
    );
    switch (source) {
      case GpsSource.device:
      case GpsSource.mockAtSite:
        return fix(0.000288, 8); // ≈ 32 m
      case GpsSource.mockOutside:
        return fix(0.0078, 12); // ≈ 870 m
      case GpsSource.mockLowAccuracy:
        return fix(0.0001, 250);
      case GpsSource.mockPermissionDenied:
        throw const LocationException(LocationFailure.permissionDenied);
      case GpsSource.mockServicesDisabled:
        throw const LocationException(LocationFailure.servicesDisabled);
    }
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}
