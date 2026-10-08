import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/mappers.dart';
import '../../../core/sync/outbox.dart';
import '../../../core/sync/sync_models.dart';
import '../../work/data/work_session_repository.dart';
import '../domain/completion_models.dart';

/// Photos, materials and the final completion of a task (PhotoRepository,
/// MaterialRepository and TaskCompletionRepository in the spec).
class CompletionRepository {
  CompletionRepository({
    required AppDatabase db,
    required Outbox outbox,
    required WorkSessionRepository workSessions,
  }) : _db = db,
       _outbox = outbox,
       _workSessions = workSessions;

  final AppDatabase _db;
  final Outbox _outbox;
  final WorkSessionRepository _workSessions;

  // ---- photos --------------------------------------------------------------

  Stream<List<TaskPhoto>> watchPhotos(String taskId) =>
      (_db.select(_db.photos)
            ..where((p) => p.taskId.equals(taskId))
            ..orderBy([(p) => OrderingTerm.asc(p.takenAt)]))
          .watch()
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  Future<TaskPhoto?> photo(String id) async => (await (_db.select(
    _db.photos,
  )..where((p) => p.id.equals(id))).getSingleOrNull())?.toDomain();

  /// Stores the photo and queues its upload right away (uploads start while
  /// the worker is still finishing).
  Future<void> addPhoto(TaskPhoto photo) => _db.transaction(() async {
    await _db
        .into(_db.photos)
        .insert(
          PhotosCompanion.insert(
            id: photo.id,
            taskId: photo.taskId,
            localPath: Value(photo.localPath),
            kind: photo.kind.name,
            takenAt: photo.takenAt,
            latitude: Value(photo.latitude),
            longitude: Value(photo.longitude),
            uploadState: PhotoUploadState.pending.name,
          ),
        );
    await _outbox.enqueue(
      taskId: photo.taskId,
      type: SyncEntityType.photo,
      entityId: photo.id,
      payload: photo.toJson(),
    );
  });

  /// Removes a photo before submission (local file, row and queued upload).
  Future<void> removePhoto(String id) async {
    final existing = await photo(id);
    await _db.transaction(() async {
      await _outbox.cancel(SyncEntityType.photo, id);
      await (_db.delete(_db.photos)..where((p) => p.id.equals(id))).go();
    });
    final path = existing?.localPath;
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    }
  }

  Future<void> updatePhotoUpload(
    String id, {
    required PhotoUploadState state,
    double? progress,
    String? error,
  }) => (_db.update(_db.photos)..where((p) => p.id.equals(id))).write(
    PhotosCompanion(
      uploadState: Value(state.name),
      progress: progress == null ? const Value.absent() : Value(progress),
      lastError: Value(error),
    ),
  );

  // ---- materials (local until submit) ------------------------------------------

  Stream<List<MaterialEntry>> watchMaterials(String taskId) =>
      (_db.select(_db.materials)..where((m) => m.taskId.equals(taskId)))
          .watch()
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  Future<void> saveMaterial(MaterialEntry m) => _db
      .into(_db.materials)
      .insertOnConflictUpdate(
        MaterialsCompanion.insert(
          id: m.id,
          taskId: m.taskId,
          catalogItemId: m.catalogItemId,
          itemName: m.itemName,
          unit: m.unit,
          quantity: m.quantity,
          movement: m.movement.name,
          note: Value(m.note),
        ),
      );

  Future<void> removeMaterial(String id) =>
      (_db.delete(_db.materials)..where((m) => m.id.equals(id))).go();

  // ---- completion ------------------------------------------------------------

  Stream<List<CompletionRow>> watchAllCompletions() =>
      _db.select(_db.completions).watch();

  Stream<CompletionRow?> watchCompletion(String taskId) => (_db.select(
    _db.completions,
  )..where((c) => c.taskId.equals(taskId))).watchSingleOrNull();

  /// Saves the completion and queues materials + completion, in one
  /// transaction. Closes the open time entry at [completion.completedAt].
  Future<void> submit(TaskCompletion completion) => _db.transaction(() async {
    await _workSessions.closeOpenEntry(
      completion.taskId,
      completion.completedAt,
    );
    await _db
        .into(_db.completions)
        .insert(
          CompletionsCompanion.insert(
            id: completion.id,
            taskId: completion.taskId,
            workerId: completion.workerId,
            completedAt: completion.completedAt,
            completionLocationCheckId: Value(
              completion.completionLocationCheckId,
            ),
            comment: Value(completion.comment),
            totalWorkMs: completion.totalWorkDuration.inMilliseconds,
            totalBreakMs: completion.totalBreakDuration.inMilliseconds,
          ),
        );
    for (final m in completion.materials) {
      await _outbox.enqueue(
        taskId: m.taskId,
        type: SyncEntityType.material,
        entityId: m.id,
        payload: m.toJson(),
      );
    }
    await _outbox.enqueue(
      taskId: completion.taskId,
      type: SyncEntityType.completion,
      entityId: completion.id,
      payload: completion.toJson(),
    );
  });

  Future<void> markConfirmed(String taskId) =>
      (_db.update(_db.completions)..where((c) => c.taskId.equals(taskId)))
          .write(const CompletionsCompanion(confirmed: Value(true)));
}
