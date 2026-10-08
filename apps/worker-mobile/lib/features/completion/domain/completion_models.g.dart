// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskPhoto _$TaskPhotoFromJson(Map<String, dynamic> json) => _TaskPhoto(
  id: json['id'] as String,
  taskId: json['taskId'] as String,
  localPath: json['localPath'] as String?,
  kind:
      $enumDecodeNullable(_$PhotoKindEnumMap, json['kind']) ?? PhotoKind.photo,
  takenAt: DateTime.parse(json['takenAt'] as String),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  uploadState:
      $enumDecodeNullable(_$PhotoUploadStateEnumMap, json['uploadState']) ??
      PhotoUploadState.pending,
  progress: (json['progress'] as num?)?.toDouble() ?? 0,
  lastError: json['lastError'] as String?,
);

Map<String, dynamic> _$TaskPhotoToJson(_TaskPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'localPath': instance.localPath,
      'kind': _$PhotoKindEnumMap[instance.kind]!,
      'takenAt': instance.takenAt.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'uploadState': _$PhotoUploadStateEnumMap[instance.uploadState]!,
      'progress': instance.progress,
      'lastError': instance.lastError,
    };

const _$PhotoKindEnumMap = {
  PhotoKind.before: 'before',
  PhotoKind.after: 'after',
  PhotoKind.photo: 'photo',
};

const _$PhotoUploadStateEnumMap = {
  PhotoUploadState.pending: 'pending',
  PhotoUploadState.uploading: 'uploading',
  PhotoUploadState.uploaded: 'uploaded',
  PhotoUploadState.failed: 'failed',
};

_CatalogItem _$CatalogItemFromJson(Map<String, dynamic> json) => _CatalogItem(
  id: json['id'] as String,
  name: json['name'] as String,
  unit: json['unit'] as String,
);

Map<String, dynamic> _$CatalogItemToJson(_CatalogItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
    };

_ExpectedMaterial _$ExpectedMaterialFromJson(Map<String, dynamic> json) =>
    _ExpectedMaterial(
      item: CatalogItem.fromJson(json['item'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
    );

Map<String, dynamic> _$ExpectedMaterialToJson(_ExpectedMaterial instance) =>
    <String, dynamic>{
      'item': instance.item.toJson(),
      'quantity': instance.quantity,
    };

_MaterialEntry _$MaterialEntryFromJson(Map<String, dynamic> json) =>
    _MaterialEntry(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      catalogItemId: json['catalogItemId'] as String,
      itemName: json['itemName'] as String,
      unit: json['unit'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      movement: $enumDecode(_$MaterialMovementEnumMap, json['movement']),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$MaterialEntryToJson(_MaterialEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'catalogItemId': instance.catalogItemId,
      'itemName': instance.itemName,
      'unit': instance.unit,
      'quantity': instance.quantity,
      'movement': _$MaterialMovementEnumMap[instance.movement]!,
      'note': instance.note,
    };

const _$MaterialMovementEnumMap = {
  MaterialMovement.installed: 'installed',
  MaterialMovement.retrieved: 'retrieved',
  MaterialMovement.damaged: 'damaged',
  MaterialMovement.lost: 'lost',
  MaterialMovement.adjustment: 'adjustment',
};

_TaskCompletion _$TaskCompletionFromJson(Map<String, dynamic> json) =>
    _TaskCompletion(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      workerId: json['workerId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      completionLocationCheckId: json['completionLocationCheckId'] as String?,
      timeEntries: (json['timeEntries'] as List<dynamic>)
          .map((e) => TimeEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalWorkDuration: Duration(
        microseconds: (json['totalWorkDuration'] as num).toInt(),
      ),
      totalBreakDuration: Duration(
        microseconds: (json['totalBreakDuration'] as num).toInt(),
      ),
      photoIds: (json['photoIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      materials: (json['materials'] as List<dynamic>)
          .map((e) => MaterialEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$TaskCompletionToJson(_TaskCompletion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'workerId': instance.workerId,
      'completedAt': instance.completedAt.toIso8601String(),
      'completionLocationCheckId': instance.completionLocationCheckId,
      'timeEntries': instance.timeEntries.map((e) => e.toJson()).toList(),
      'totalWorkDuration': instance.totalWorkDuration.inMicroseconds,
      'totalBreakDuration': instance.totalBreakDuration.inMicroseconds,
      'photoIds': instance.photoIds,
      'materials': instance.materials.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
    };
