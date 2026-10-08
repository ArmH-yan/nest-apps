import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../core/location/location_service.dart';
import '../../../core/sync/outbox.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/time/clock.dart';
import '../../completion/data/completion_repository.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_status.dart';
import '../domain/duration_calculator.dart';
import '../domain/location_check.dart';
import '../domain/location_verification.dart';
import '../domain/task_state_machine.dart';
import 'work_session_repository.dart';

/// GPS verification and work/break actions (WorkTimerService +
/// LocationVerificationService wiring in the spec). Every action is checked
/// by [TaskStateMachine], persisted locally first, then synced.
class WorkActions {
  WorkActions({
    required TaskRepository tasks,
    required WorkSessionRepository sessions,
    required CompletionRepository completions,
    required Outbox outbox,
    required LocationService location,
    required SyncService sync,
    required Clock clock,
    Uuid uuid = const Uuid(),
  }) : _tasks = tasks,
       _sessions = sessions,
       _completions = completions,
       _outbox = outbox,
       _location = location,
       _sync = sync,
       _clock = clock,
       _uuid = uuid;

  final TaskRepository _tasks;
  final WorkSessionRepository _sessions;
  final CompletionRepository _completions;
  final Outbox _outbox;
  final LocationService _location;
  final SyncService _sync;
  final Clock _clock;
  final Uuid _uuid;

  /// Local facts used by [deriveStatus].
  Future<TaskLocalState> localState(String taskId) async {
    final open = await _sessions.watchOpenEntries().first;
    final completion = await _completions.watchCompletion(taskId).first;
    final failed = await _outbox.watchFailedTaskIds().first;
    return TaskLocalState(
      openEntry: DurationCalculator.openEntry(
        open.where((e) => e.taskId == taskId),
      ),
      hasLocalCompletion: completion != null,
      completionConfirmed: completion?.confirmed ?? false,
      hasFailedSync: failed.contains(taskId),
    );
  }

  Future<TaskDisplayStatus> statusOf(Task task) async =>
      deriveStatus(task, await localState(task.id), _clock.now());

  Future<String?> _otherActiveTaskId(String taskId) async {
    final open = await _sessions.watchOpenEntries().first;
    for (final e in open) {
      if (e.taskId != taskId) return e.taskId;
    }
    return null;
  }

  /// Takes a GPS fix, checks it against the site geofence and records the
  /// check (also when it fails). Throws [LocationException] for permission /
  /// service problems.
  Future<(LocationVerificationResult, LocationCheck)> verifyLocation(
    Task task,
  ) async {
    final fix = await _location.currentFix(near: task);
    final result = LocationVerificationService.verify(
      fix: fix,
      task: task,
      config: _tasks.config,
    );
    final check = _toCheck(task, LocationCheckPurpose.start, result);
    await _sessions.saveLocationCheck(check);
    unawaited(_sync.syncNow());
    return (result, check);
  }

  /// Start Working Timer. Requires a verified START check from [verifiedCheck].
  Future<void> startWork(Task task, LocationCheck verifiedCheck) async {
    TaskStateMachine.ensure(
      action: TaskAction.start,
      task: task,
      status: await statusOf(task),
      config: _tasks.config,
      now: _clock.now(),
      otherActiveTaskId: await _otherActiveTaskId(task.id),
      hasVerifiedStartCheck:
          verifiedCheck.verified &&
          verifiedCheck.taskId == task.id &&
          verifiedCheck.purpose == LocationCheckPurpose.start,
    );
    await _sessions.startWork(task.id, startLocationCheckId: verifiedCheck.id);
    unawaited(_sync.syncNow());
  }

  Future<void> startBreak(Task task) async {
    _ensure(TaskAction.startBreak, task, await statusOf(task));
    await _sessions.startBreak(task.id);
    unawaited(_sync.syncNow());
  }

  /// Resume Working. A location fix is recorded in the background but never
  /// blocks the worker.
  Future<void> resumeWork(Task task) async {
    _ensure(TaskAction.resumeWork, task, await statusOf(task));
    await _sessions.resumeWork(task.id);
    unawaited(captureInBackground(task, LocationCheckPurpose.resume));
    unawaited(_sync.syncNow());
  }

  /// Best-effort fix (resume / completion). Returns null on any problem.
  Future<LocationCheck?> captureInBackground(
    Task task,
    LocationCheckPurpose purpose,
  ) async {
    try {
      final fix = await _location
          .currentFix(near: task)
          .timeout(const Duration(seconds: 25));
      final result = LocationVerificationService.verify(
        fix: fix,
        task: task,
        config: _tasks.config,
      );
      final check = _toCheck(task, purpose, result);
      await _sessions.saveLocationCheck(check);
      return check;
    } on Object {
      return null;
    }
  }

  void _ensure(TaskAction action, Task task, TaskDisplayStatus status) =>
      TaskStateMachine.ensure(
        action: action,
        task: task,
        status: status,
        config: _tasks.config,
        now: _clock.now(),
      );

  LocationCheck _toCheck(
    Task task,
    LocationCheckPurpose purpose,
    LocationVerificationResult r,
  ) => LocationCheck(
    id: _uuid.v4(),
    taskId: task.id,
    purpose: purpose,
    latitude: r.currentLatitude,
    longitude: r.currentLongitude,
    accuracyM: r.accuracyMeters,
    isMocked: r.isMocked,
    capturedAt: r.timestamp,
    distanceM: r.distanceMeters,
    radiusM: r.radiusMeters,
    verified: r.verified,
  );
}
