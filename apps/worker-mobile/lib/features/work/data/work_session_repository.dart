import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/storage/mappers.dart';
import '../../../core/sync/outbox.dart';
import '../../../core/sync/sync_models.dart';
import '../../../core/time/clock.dart';
import '../domain/location_check.dart';
import '../domain/time_entry.dart';

/// Work/break sessions and GPS checks. Each write stores the local change and
/// its outbox item in one transaction, *before* the UI updates.
class WorkSessionRepository {
  WorkSessionRepository({
    required AppDatabase db,
    required Outbox outbox,
    required Clock clock,
    Uuid uuid = const Uuid(),
  }) : _db = db,
       _outbox = outbox,
       _clock = clock,
       _uuid = uuid;

  final AppDatabase _db;
  final Outbox _outbox;
  final Clock _clock;
  final Uuid _uuid;

  Stream<List<TimeEntry>> watchEntries(String taskId) =>
      (_db.select(_db.timeEntries)
            ..where((e) => e.taskId.equals(taskId))
            ..orderBy([(e) => OrderingTerm.asc(e.startedAt)]))
          .watch()
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  Future<List<TimeEntry>> entries(String taskId) => watchEntries(taskId).first;

  /// Open entries across all tasks (at most one in practice).
  Stream<List<TimeEntry>> watchOpenEntries() =>
      (_db.select(_db.timeEntries)..where((e) => e.endedAt.isNull()))
          .watch()
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  Stream<List<LocationCheck>> watchChecks(String taskId) =>
      (_db.select(_db.locationChecks)
            ..where((c) => c.taskId.equals(taskId))
            ..orderBy([(c) => OrderingTerm.asc(c.capturedAt)]))
          .watch()
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  Future<LocationCheck?> check(String id) async => (await (_db.select(
    _db.locationChecks,
  )..where((c) => c.id.equals(id))).getSingleOrNull())?.toDomain();

  /// Saves a GPS check (verified or not — failed checks are evidence too).
  Future<void> saveLocationCheck(LocationCheck check) =>
      _db.transaction(() async {
        await _db
            .into(_db.locationChecks)
            .insert(
              LocationChecksCompanion.insert(
                id: check.id,
                taskId: check.taskId,
                purpose: check.purpose.name,
                latitude: check.latitude,
                longitude: check.longitude,
                accuracyM: check.accuracyM,
                isMocked: check.isMocked,
                capturedAt: check.capturedAt,
                distanceM: check.distanceM,
                radiusM: check.radiusM,
                verified: check.verified,
              ),
            );
        await _outbox.enqueue(
          taskId: check.taskId,
          type: SyncEntityType.locationCheck,
          entityId: check.id,
          payload: check.toJson(),
        );
      });

  /// Opens a WORK entry (Start Working Timer). Fails if one is already open.
  Future<TimeEntry> startWork(String taskId, {String? startLocationCheckId}) =>
      _db.transaction(() async {
        await _ensureNoOpenEntry();
        return _open(taskId, TimeEntryKind.work, startLocationCheckId);
      });

  /// Closes WORK, opens BREAK (Stop & Start Break).
  Future<TimeEntry> startBreak(String taskId) => _db.transaction(() async {
    final now = _clock.now();
    await _closeOpen(taskId, now, expect: TimeEntryKind.work);
    return _open(taskId, TimeEntryKind.breakTime, null, at: now);
  });

  /// Closes BREAK, opens WORK (Resume Working).
  Future<TimeEntry> resumeWork(String taskId) => _db.transaction(() async {
    final now = _clock.now();
    await _closeOpen(taskId, now, expect: TimeEntryKind.breakTime);
    return _open(taskId, TimeEntryKind.work, null, at: now);
  });

  /// Closes whatever is open on [taskId] at [at]. Safe to call inside an
  /// outer transaction (completion submit).
  Future<void> closeOpenEntry(String taskId, DateTime at) =>
      _db.transaction(() => _closeOpen(taskId, at));

  Future<void> _ensureNoOpenEntry() async {
    final open = await (_db.select(
      _db.timeEntries,
    )..where((e) => e.endedAt.isNull())).get();
    if (open.isNotEmpty) {
      throw StateError(
        'A time entry is already open (task ${open.first.taskId}).',
      );
    }
  }

  Future<TimeEntry> _open(
    String taskId,
    TimeEntryKind kind,
    String? checkId, {
    DateTime? at,
  }) async {
    final entry = TimeEntry(
      id: _uuid.v4(),
      taskId: taskId,
      kind: kind,
      startedAt: at ?? _clock.now(),
      startLocationCheckId: checkId,
    );
    await _db
        .into(_db.timeEntries)
        .insert(
          TimeEntriesCompanion.insert(
            id: entry.id,
            taskId: taskId,
            kind: kind.name,
            startedAt: entry.startedAt,
            startLocationCheckId: Value(checkId),
          ),
        );
    await _outbox.enqueue(
      taskId: taskId,
      type: SyncEntityType.timeEntry,
      entityId: entry.id,
      payload: entry.toJson(),
    );
    return entry;
  }

  Future<void> _closeOpen(
    String taskId,
    DateTime at, {
    TimeEntryKind? expect,
  }) async {
    final row =
        await (_db.select(_db.timeEntries)
              ..where((e) => e.taskId.equals(taskId) & e.endedAt.isNull()))
            .getSingleOrNull();
    if (row == null) {
      if (expect != null) throw StateError('No open ${expect.name} entry.');
      return;
    }
    final entry = row.toDomain();
    if (expect != null && entry.kind != expect) {
      throw StateError(
        'Open entry is ${entry.kind.name}, expected ${expect.name}.',
      );
    }
    // never end before it started (device clock moved back)
    final end = at.isBefore(entry.startedAt) ? entry.startedAt : at;
    final closed = entry.copyWith(endedAt: end);
    await (_db.update(_db.timeEntries)..where((e) => e.id.equals(entry.id)))
        .write(TimeEntriesCompanion(endedAt: Value(end)));
    await _outbox.enqueue(
      taskId: taskId,
      type: SyncEntityType.timeEntry,
      entityId: entry.id,
      payload: closed.toJson(),
    );
  }
}
