import 'package:freezed_annotation/freezed_annotation.dart';

import '../../work/domain/time_entry.dart';

part 'completion_models.freezed.dart';
part 'completion_models.g.dart';

enum PhotoKind { before, after, photo }

enum PhotoUploadState { pending, uploading, uploaded, failed }

@freezed
abstract class TaskPhoto with _$TaskPhoto {
  const factory TaskPhoto({
    required String id,
    required String taskId,

    /// Local file; null for photos that only exist on the server (history).
    String? localPath,
    @Default(PhotoKind.photo) PhotoKind kind,
    required DateTime takenAt,
    double? latitude,
    double? longitude,
    @Default(PhotoUploadState.pending) PhotoUploadState uploadState,

    /// 0.0 – 1.0 while uploading.
    @Default(0) double progress,
    String? lastError,
  }) = _TaskPhoto;

  factory TaskPhoto.fromJson(Map<String, dynamic> json) =>
      _$TaskPhotoFromJson(json);
}

enum MaterialMovement { installed, retrieved, damaged, lost, adjustment }

@freezed
abstract class CatalogItem with _$CatalogItem {
  const factory CatalogItem({
    required String id,
    required String name,
    required String unit,
  }) = _CatalogItem;

  factory CatalogItem.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemFromJson(json);
}

/// What the ledger says is on site (dismantling list).
@freezed
abstract class ExpectedMaterial with _$ExpectedMaterial {
  const factory ExpectedMaterial({
    required CatalogItem item,
    required double quantity,
  }) = _ExpectedMaterial;

  factory ExpectedMaterial.fromJson(Map<String, dynamic> json) =>
      _$ExpectedMaterialFromJson(json);
}

@freezed
abstract class MaterialEntry with _$MaterialEntry {
  const factory MaterialEntry({
    required String id,
    required String taskId,
    required String catalogItemId,
    required String itemName,
    required String unit,
    required double quantity,
    required MaterialMovement movement,
    String? note,
  }) = _MaterialEntry;

  factory MaterialEntry.fromJson(Map<String, dynamic> json) =>
      _$MaterialEntryFromJson(json);
}

/// Everything sent with `PUT /worker/tasks/{id}/completion/{uuid}`.
@freezed
abstract class TaskCompletion with _$TaskCompletion {
  const factory TaskCompletion({
    required String id,
    required String taskId,
    required String workerId,
    required DateTime completedAt,
    String? completionLocationCheckId,
    required List<TimeEntry> timeEntries,
    required Duration totalWorkDuration,
    required Duration totalBreakDuration,
    required List<String> photoIds,
    required List<MaterialEntry> materials,
    String? comment,
  }) = _TaskCompletion;

  factory TaskCompletion.fromJson(Map<String, dynamic> json) =>
      _$TaskCompletionFromJson(json);
}
