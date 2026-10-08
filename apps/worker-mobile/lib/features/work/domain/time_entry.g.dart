// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimeEntry _$TimeEntryFromJson(Map<String, dynamic> json) => _TimeEntry(
  id: json['id'] as String,
  taskId: json['taskId'] as String,
  kind: $enumDecode(_$TimeEntryKindEnumMap, json['kind']),
  startedAt: DateTime.parse(json['startedAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  startLocationCheckId: json['startLocationCheckId'] as String?,
);

Map<String, dynamic> _$TimeEntryToJson(_TimeEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'kind': _$TimeEntryKindEnumMap[instance.kind]!,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'startLocationCheckId': instance.startLocationCheckId,
    };

const _$TimeEntryKindEnumMap = {
  TimeEntryKind.work: 'work',
  TimeEntryKind.breakTime: 'breakTime',
};
