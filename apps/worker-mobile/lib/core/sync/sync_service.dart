import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../features/completion/data/completion_repository.dart';
import '../../features/completion/domain/completion_models.dart';
import '../../features/tasks/data/task_repository.dart';
import '../../features/work/domain/location_check.dart';
import '../../features/work/domain/time_entry.dart';
import '../api/nest_api.dart';
import '../network/api_exception.dart';
import '../storage/app_database.dart';
import '../time/clock.dart';
import 'sync_models.dart';

/// Sends the outbox to the API (WORKER_APP_SPEC "Offline support and sync").
///
/// - FIFO per task; a task whose item is waiting for a retry or has failed
///   blocks its later items (so a completion never overtakes its photos).
/// - Network error → stop the run, stay offline, keep items pending.
/// - 5xx / 429 → exponential backoff (max 10 min).
/// - Other 4xx (409, 422, …) → item `failed`, task shows
///   `synchronizationFailed` with the server's message and a Retry button.
/// - Every write is an idempotent PUT keyed by a client UUID, so replays are safe.
class SyncService {
  SyncService({
    required AppDatabase db,
    required NestApi api,
    required Clock clock,
    required CompletionRepository completions,
    required TaskRepository tasks,
  }) : _db = db,
       _api = api,
       _clock = clock,
       _completions = completions,
       _tasks = tasks;

  final AppDatabase _db;
  final NestApi _api;
  final Clock _clock;
  final CompletionRepository _completions;
  final TaskRepository _tasks;

  static const maxBackoff = Duration(minutes: 10);

  final _status = StreamController<SyncStatus>.broadcast();
  SyncStatus _current = SyncStatus.initial;
  Future<void>? _inFlight;
  bool _runAgain = false;
  Timer? _periodic;

  SyncStatus get status => _current;
  Stream<SyncStatus> get statusStream => _status.stream;

  void _emit(SyncStatus s) {
    _current = s;
    if (!_status.isClosed) _status.add(s);
  }

  /// Starts a periodic sync (30 s) while the app is in the foreground and
  /// recovers items left `inFlight` by a crash.
  Future<void> start() async {
    await (_db.update(_db.syncItems)
          ..where((s) => s.state.equals(SyncItemState.inFlight.name)))
        .write(SyncItemsCompanion(state: Value(SyncItemState.pending.name)));
    _periodic ??= Timer.periodic(const Duration(seconds: 30), (_) => syncNow());
    unawaited(syncNow());
  }

  void pause() {
    _periodic?.cancel();
    _periodic = null;
  }

  void setOnline(bool online) {
    final wasOffline = !_current.isOnline;
    _emit(_current.copyWith(isOnline: online));
    if (online && wasOffline) unawaited(syncNow());
  }

  Future<void> dispose() async {
    pause();
    await _status.close();
  }

  /// Runs passes over the outbox until nothing new was requested.
  /// Concurrent calls join the running pass (plus one extra pass) and their
  /// returned future completes only when that work is done.
  Future<void> syncNow() {
    final running = _inFlight;
    if (running != null) {
      _runAgain = true;
      return running;
    }
    return _inFlight = _loop().whenComplete(() => _inFlight = null);
  }

  Future<void> _loop() async {
    _emit(_current.copyWith(isSyncing: true));
    try {
      do {
        _runAgain = false;
        await _runOnce();
      } while (_runAgain);
    } finally {
      _emit(_current.copyWith(isSyncing: false));
    }
  }

  Future<void> _runOnce() async {
    final now = _clock.now();
    final items =
        await (_db.select(_db.syncItems)
              ..where((s) => s.state.isNotIn([SyncItemState.done.name]))
              ..orderBy([(s) => OrderingTerm.asc(s.id)]))
            .get();

    final blocked = <String>{};
    var sentAny = false;
    for (final item in items) {
      if (blocked.contains(item.taskId)) continue;
      final waiting =
          item.nextAttemptAt != null && item.nextAttemptAt!.isAfter(now);
      if (item.state == SyncItemState.failed.name || waiting) {
        blocked.add(item.taskId);
        continue;
      }

      await _setState(item.id, SyncItemState.inFlight);
      try {
        await _send(item);
        await (_db.delete(
          _db.syncItems,
        )..where((s) => s.id.equals(item.id))).go();
        sentAny = true;
        if (!_current.isOnline) _emit(_current.copyWith(isOnline: true));
      } on ApiException catch (e) {
        if (e.statusCode == null) {
          // No connection: put it back and stop this pass.
          await _setState(item.id, SyncItemState.pending);
          _emit(_current.copyWith(isOnline: false));
          return;
        }
        blocked.add(item.taskId);
        if (e.isRetryable) {
          final attempts = item.attempts + 1;
          await (_db.update(
            _db.syncItems,
          )..where((s) => s.id.equals(item.id))).write(
            SyncItemsCompanion(
              state: Value(SyncItemState.pending.name),
              attempts: Value(attempts),
              lastErrorCode: Value(e.code),
              lastErrorMessage: Value(e.message),
              nextAttemptAt: Value(now.add(backoff(attempts))),
            ),
          );
        } else {
          await (_db.update(
            _db.syncItems,
          )..where((s) => s.id.equals(item.id))).write(
            SyncItemsCompanion(
              state: Value(SyncItemState.failed.name),
              attempts: Value(item.attempts + 1),
              lastErrorCode: Value(e.code),
              lastErrorMessage: Value(e.message),
            ),
          );
        }
      }
    }
    if (sentAny) _emit(_current.copyWith(lastSyncedAt: _clock.now()));
  }

  /// 10 s, 20 s, 40 s … capped at [maxBackoff].
  static Duration backoff(int attempts) {
    final seconds = 10 * math.pow(2, math.max(0, attempts - 1)).toInt();
    final d = Duration(seconds: seconds);
    return d > maxBackoff ? maxBackoff : d;
  }

  Future<void> _setState(int id, SyncItemState state) =>
      (_db.update(_db.syncItems)..where((s) => s.id.equals(id))).write(
        SyncItemsCompanion(state: Value(state.name)),
      );

  Future<void> _send(SyncItemRow item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    switch (SyncEntityType.values.byName(item.entityType)) {
      case SyncEntityType.locationCheck:
        await _api.putLocationCheck(LocationCheck.fromJson(payload));
      case SyncEntityType.timeEntry:
        await _api.putTimeEntry(TimeEntry.fromJson(payload));
      case SyncEntityType.material:
        await _api.putMaterial(MaterialEntry.fromJson(payload));
      case SyncEntityType.photo:
        await _sendPhoto(item.entityId);
      case SyncEntityType.completion:
        final completion = TaskCompletion.fromJson(payload);
        await _api.putCompletion(completion);
        await _completions.markConfirmed(completion.taskId);
        await _tasks.markSubmitted(completion.taskId);
    }
  }

  Future<void> _sendPhoto(String photoId) async {
    final photo = await _completions.photo(photoId);
    if (photo == null || photo.uploadState == PhotoUploadState.uploaded) return;
    final path = photo.localPath;
    if (path == null) return;
    try {
      await _completions.updatePhotoUpload(
        photoId,
        state: PhotoUploadState.uploading,
        progress: 0,
      );
      final url = await _api.presignPhoto(photo);
      var lastWritten = 0.0;
      await _api.uploadPhoto(
        url,
        path,
        onProgress: (p) {
          // throttle DB writes to ~10 updates per upload
          if (p - lastWritten >= 0.1 || p >= 1) {
            lastWritten = p;
            unawaited(
              _completions.updatePhotoUpload(
                photoId,
                state: PhotoUploadState.uploading,
                progress: p,
              ),
            );
          }
        },
      );
      await _api.confirmPhoto(photoId);
      await _completions.updatePhotoUpload(
        photoId,
        state: PhotoUploadState.uploaded,
        progress: 1,
      );
    } on ApiException catch (e) {
      await _completions.updatePhotoUpload(
        photoId,
        state: PhotoUploadState.failed,
        progress: 0,
        error: e.code,
      );
      rethrow;
    }
  }
}
