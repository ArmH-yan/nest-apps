import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_check.freezed.dart';
part 'location_check.g.dart';

enum LocationCheckPurpose { start, resume, completion, manual }

/// A recorded GPS fix and its client-side verdict. The server recomputes the
/// distance independently; this is evidence, not proof (ARCHITECTURE §19).
@freezed
abstract class LocationCheck with _$LocationCheck {
  const factory LocationCheck({
    required String id,
    required String taskId,
    required LocationCheckPurpose purpose,
    required double latitude,
    required double longitude,
    required double accuracyM,
    required bool isMocked,
    required DateTime capturedAt,
    required double distanceM,
    required double radiusM,
    required bool verified,
  }) = _LocationCheck;

  factory LocationCheck.fromJson(Map<String, dynamic> json) =>
      _$LocationCheckFromJson(json);
}
