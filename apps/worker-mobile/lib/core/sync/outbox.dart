import 'dart:convert';

import 'package:drift/drift.dart';

import '../storage/app_database.dart';
import '../time/clock.dart';
import 'sync_models.dart';

/// Writes outbox items. Callers must invoke [enqueue] inside the same
/// `db.transaction` as the local change it describes.
class Outbox {
  Outbox(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Adds an item. If a still-pending item exists for the same entity, its
  /// payload is replaced instead (e.g. a time entry created, then closed) —
  /// the server receives one idempotent PUT with the latest body.
  Future<void> enqueue({
    required String taskId,
    required SyncEntityType type,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    final body = jsonEncode(payload);
    final existing =
        await (_db.select(_db.syncItems)..where(
              (s) =>
                  s.entityType.equals(type.name) &
                  s.entityId.equals(entityId) &
                  s.state.equals(SyncItemState.pending.name),
            ))
            .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.syncItems)..where((s) => s.id.equals(existing.id)))
          .write(SyncItemsCompanion(payload: Value(body)));
      return;
    }
    await _db
        .into(_db.syncItems)
        .insert(
          SyncItemsCompanion.insert(
            taskId: taskId,
            entityType: type.name,
            entityId: entityId,
            payload: body,
            state: SyncItemState.pending.name,
            createdAt: _clock.now(),
          ),
        );
  }

  /// Removes not-yet-sent items for an entity (e.g. a photo deleted before upload).
  Future<void> cancel(SyncEntityType type, String entityId) =>
      (_db.delete(_db.syncItems)..where(
            (s) =>
                s.entityType.equals(type.name) &
                s.entityId.equals(entityId) &
                s.state.isIn([
                  SyncItemState.pending.name,
                  SyncItemState.failed.name,
                ]),
          ))
          .go();

  /// Live count of unsynced items (pending + inFlight + failed).
  Stream<int> watchUnsyncedCount() {
    final count = _db.syncItems.id.count();
    final query = _db.selectOnly(_db.syncItems)
      ..addColumns([count])
      ..where(_db.syncItems.state.isNotIn([SyncItemState.done.name]));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  Future<int> unsyncedCount() => watchUnsyncedCount().first;

  /// Task IDs that have at least one failed item.
  Stream<Set<String>> watchFailedTaskIds() =>
      (_db.select(_db.syncItems)
            ..where((s) => s.state.equals(SyncItemState.failed.name)))
          .watch()
          .map((rows) => rows.map((r) => r.taskId).toSet());

  /// Failed items for one task (to show the server's reason).
  Stream<List<SyncItemRow>> watchFailedForTask(String taskId) =>
      (_db.select(_db.syncItems)..where(
            (s) =>
                s.taskId.equals(taskId) &
                s.state.equals(SyncItemState.failed.name),
          ))
          .watch();

  /// Moves a task's failed items back to pending (Retry button).
  Future<void> retryTask(String taskId) =>
      (_db.update(_db.syncItems)..where(
            (s) =>
                s.taskId.equals(taskId) &
                s.state.equals(SyncItemState.failed.name),
          ))
          .write(
            const SyncItemsCompanion(
              state: Value('pending'),
              nextAttemptAt: Value(null),
            ),
          );
}
