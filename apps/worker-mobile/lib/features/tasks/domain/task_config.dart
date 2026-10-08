import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_config.freezed.dart';
part 'task_config.g.dart';

/// Server-provided rules (`GET /worker/config`, ARCHITECTURE §8 settings).
/// Never hard-code these values elsewhere.
@freezed
abstract class TaskConfig with _$TaskConfig {
  const factory TaskConfig({
    @Default(150) double defaultGeofenceRadiusM,
    @Default(100) double maxLocationAccuracyM,
    @Default(1) int minCompletionPhotos,
    @Default(120) int startWindowMinutesBefore,
    @Default('1.0.0') String minSupportedAppVersion,
  }) = _TaskConfig;

  factory TaskConfig.fromJson(Map<String, dynamic> json) =>
      _$TaskConfigFromJson(json);
}
