// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskConfig _$TaskConfigFromJson(Map<String, dynamic> json) => _TaskConfig(
  defaultGeofenceRadiusM:
      (json['defaultGeofenceRadiusM'] as num?)?.toDouble() ?? 150,
  maxLocationAccuracyM:
      (json['maxLocationAccuracyM'] as num?)?.toDouble() ?? 100,
  minCompletionPhotos: (json['minCompletionPhotos'] as num?)?.toInt() ?? 1,
  startWindowMinutesBefore:
      (json['startWindowMinutesBefore'] as num?)?.toInt() ?? 120,
  minSupportedAppVersion: json['minSupportedAppVersion'] as String? ?? '1.0.0',
);

Map<String, dynamic> _$TaskConfigToJson(_TaskConfig instance) =>
    <String, dynamic>{
      'defaultGeofenceRadiusM': instance.defaultGeofenceRadiusM,
      'maxLocationAccuracyM': instance.maxLocationAccuracyM,
      'minCompletionPhotos': instance.minCompletionPhotos,
      'startWindowMinutesBefore': instance.startWindowMinutesBefore,
      'minSupportedAppVersion': instance.minSupportedAppVersion,
    };
