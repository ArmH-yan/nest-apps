// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationCheck _$LocationCheckFromJson(Map<String, dynamic> json) =>
    _LocationCheck(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      purpose: $enumDecode(_$LocationCheckPurposeEnumMap, json['purpose']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyM: (json['accuracyM'] as num).toDouble(),
      isMocked: json['isMocked'] as bool,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      distanceM: (json['distanceM'] as num).toDouble(),
      radiusM: (json['radiusM'] as num).toDouble(),
      verified: json['verified'] as bool,
    );

Map<String, dynamic> _$LocationCheckToJson(_LocationCheck instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'purpose': _$LocationCheckPurposeEnumMap[instance.purpose]!,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracyM': instance.accuracyM,
      'isMocked': instance.isMocked,
      'capturedAt': instance.capturedAt.toIso8601String(),
      'distanceM': instance.distanceM,
      'radiusM': instance.radiusM,
      'verified': instance.verified,
    };

const _$LocationCheckPurposeEnumMap = {
  LocationCheckPurpose.start: 'start',
  LocationCheckPurpose.resume: 'resume',
  LocationCheckPurpose.completion: 'completion',
  LocationCheckPurpose.manual: 'manual',
};
