import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../core/media/photo_capture_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/time/clock.dart';
import '../../auth/domain/worker.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/task.dart';
import '../../work/data/work_session_repository.dart';
import '../../work/domain/duration_calculator.dart';
import '../../work/domain/location_check.dart';
import '../../work/domain/time_entry.dart';
import '../domain/completion_models.dart';
import '../domain/completion_validator.dart';
import 'completion_repository.dart';

class CompletionValidationException implements Exception {
  const CompletionValidationException(this.issues);

  final List<CompletionIssue> issues;
}

/// Photos and final submission of a task (PhotoUploadService +
/// TaskCompletionRepository wiring in the spec).
class CompletionService {
  CompletionService({
    required CompletionRepository completions,
    required WorkSessionRepository sessions,
    required TaskRepository tasks,
    required PhotoCaptureService capture,
    required SyncService sync,
    required Clock clock,
    Uuid uuid = const Uuid(),
  }) : _completions = completions,
       _sessions = sessions,
       _tasks = tasks,
       _capture = capture,
       _sync = sync,
       _clock = clock,
       _uuid = uuid;

  final CompletionRepository _completions;
  final WorkSessionRepository _sessions;
  final TaskRepository _tasks;
  final PhotoCaptureService _capture;
  final SyncService _sync;
  final Clock _clock;
  final Uuid _uuid;

  /// Takes/picks photos; each is stored and its upload queued immediately.
  Future<int> addPhotos(
    Task task,
    PhotoSource source, {
    LocationCheck? location,
  }) async {
    final stem = '${task.id}_${_clock.now().millisecondsSinceEpoch}';
    final paths = await _capture.pick(source, fileStem: stem);
    for (final path in paths) {
      await _completions.addPhoto(
        TaskPhoto(
          id: _uuid.v4(),
          taskId: task.id,
          localPath: path,
          kind: PhotoKind.after,
          takenAt: _clock.now(),
          latitude: location?.latitude,
          longitude: location?.longitude,
        ),
      );
    }
    if (paths.isNotEmpty) unawaited(_sync.syncNow());
    return paths.length;
  }

  Future<void> removePhoto(String photoId) => _completions.removePhoto(photoId);

  /// Retry a failed upload now.
  Future<void> retryUploads() => _sync.syncNow();

  /// Entries as they will be submitted (open entry closed at [finishAt]).
  Future<List<TimeEntry>> entriesAt(String taskId, DateTime finishAt) async {
    final entries = await _sessions.entries(taskId);
    return [
      for (final e in entries)
        e.isOpen
            ? e.copyWith(
                endedAt: finishAt.isBefore(e.startedAt)
                    ? e.startedAt
                    : finishAt,
              )
            : e,
    ];
  }

  /// Validates, builds and queues the completion. Throws
  /// [CompletionValidationException] when rules aren't met.
  Future<TaskCompletion> submit({
    required Task task,
    required Worker worker,
    required DateTime finishAt,
    LocationCheck? completionCheck,
    String? comment,
  }) async {
    final photos = await _completions.watchPhotos(task.id).first;
    final materials = (await _completions.watchMaterials(task.id).first)
        .where((m) => m.quantity > 0)
        .toList();
    final issues = CompletionValidator.validate(
      task: task,
      config: _tasks.config,
      photos: photos,
      materials: materials,
    );
    if (issues.isNotEmpty) throw CompletionValidationException(issues);

    final entries = await entriesAt(task.id, finishAt);
    final totals = DurationCalculator.totals(entries, finishAt);
    final trimmed = comment?.trim();
    final completion = TaskCompletion(
      id: _uuid.v4(),
      taskId: task.id,
      workerId: worker.id,
      completedAt: finishAt,
      completionLocationCheckId: completionCheck?.id,
      timeEntries: entries,
      totalWorkDuration: totals.work,
      totalBreakDuration: totals.breakTime,
      photoIds: [for (final p in photos) p.id],
      materials: materials,
      comment: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );
    await _completions.submit(completion);
    unawaited(_sync.syncNow());
    return completion;
  }
}
