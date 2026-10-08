import 'dart:convert';

import '../../features/completion/domain/completion_models.dart';
import '../../features/tasks/domain/task.dart';
import '../../features/work/domain/location_check.dart';
import '../../features/work/domain/time_entry.dart';
import 'app_database.dart';

/// Row ↔ domain conversions. Enums are stored by `name`.

T _enum<T extends Enum>(List<T> values, String name) =>
    values.firstWhere((v) => v.name == name);

extension CachedTaskRowX on CachedTaskRow {
  Task toDomain() => Task.fromJson(jsonDecode(payload) as Map<String, dynamic>);
}

extension TimeEntryRowX on TimeEntryRow {
  TimeEntry toDomain() => TimeEntry(
    id: id,
    taskId: taskId,
    kind: _enum(TimeEntryKind.values, kind),
    startedAt: startedAt.toUtc(),
    endedAt: endedAt?.toUtc(),
    startLocationCheckId: startLocationCheckId,
  );
}

extension LocationCheckRowX on LocationCheckRow {
  LocationCheck toDomain() => LocationCheck(
    id: id,
    taskId: taskId,
    purpose: _enum(LocationCheckPurpose.values, purpose),
    latitude: latitude,
    longitude: longitude,
    accuracyM: accuracyM,
    isMocked: isMocked,
    capturedAt: capturedAt.toUtc(),
    distanceM: distanceM,
    radiusM: radiusM,
    verified: verified,
  );
}

extension PhotoRowX on PhotoRow {
  TaskPhoto toDomain() => TaskPhoto(
    id: id,
    taskId: taskId,
    localPath: localPath,
    kind: _enum(PhotoKind.values, kind),
    takenAt: takenAt.toUtc(),
    latitude: latitude,
    longitude: longitude,
    uploadState: _enum(PhotoUploadState.values, uploadState),
    progress: progress,
    lastError: lastError,
  );
}

extension MaterialRowX on MaterialRow {
  MaterialEntry toDomain() => MaterialEntry(
    id: id,
    taskId: taskId,
    catalogItemId: catalogItemId,
    itemName: itemName,
    unit: unit,
    quantity: quantity,
    movement: _enum(MaterialMovement.values, movement),
    note: note,
  );
}
