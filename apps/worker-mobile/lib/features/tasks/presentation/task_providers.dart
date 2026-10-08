import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/mappers.dart';
import '../../completion/domain/completion_models.dart';
import '../../work/domain/duration_calculator.dart';
import '../../work/domain/location_check.dart';
import '../../work/domain/time_entry.dart';
import '../domain/task.dart';
import '../domain/task_config.dart';
import '../domain/task_status.dart';

/// A task plus everything the UI derives for it.
class TaskView {
  const TaskView({
    required this.task,
    required this.status,
    required this.entries,
    this.completion,
  });

  final Task task;
  final TaskDisplayStatus status;

  /// Only loaded for active/finished tasks (cheap otherwise).
  final List<TimeEntry> entries;
  final CompletionRow? completion;

  String get id => task.id;
}

/// Ticks every second — drives the big timers. Values come from the Clock,
/// so the display is always `now - startedAt` (never a counter).
final tickerProvider = StreamProvider<DateTime>((ref) async* {
  final clock = ref.watch(clockProvider);
  yield clock.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => clock.now());
});

/// Ticks every minute — enough for task lists (today/upcoming boundaries).
final minuteTickerProvider = StreamProvider<DateTime>((ref) async* {
  final clock = ref.watch(clockProvider);
  yield clock.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => clock.now());
});

final taskConfigProvider = Provider<TaskConfig>((ref) {
  ref.watch(cachedTasksProvider); // re-read after each refresh
  return ref.watch(taskRepositoryProvider).config;
});

final cachedTasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(taskRepositoryProvider).watchTasks(),
);

final allEntriesProvider = StreamProvider<List<TimeEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .select(db.timeEntries)
      .watch()
      .map((rows) => rows.map((r) => r.toDomain()).toList());
});

final allCompletionsProvider = StreamProvider<List<CompletionRow>>(
  (ref) => ref.watch(completionRepositoryProvider).watchAllCompletions(),
);

final failedTaskIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(outboxProvider).watchFailedTaskIds(),
);

/// All tasks with derived status. Loading until the local streams are ready.
final taskViewsProvider = Provider<AsyncValue<List<TaskView>>>((ref) {
  final tasks = ref.watch(cachedTasksProvider);
  final entries = ref.watch(allEntriesProvider);
  final completions = ref.watch(allCompletionsProvider);
  final failed = ref.watch(failedTaskIdsProvider);
  final now =
      ref.watch(minuteTickerProvider).value ?? ref.watch(clockProvider).now();

  for (final a in [tasks, entries, completions, failed]) {
    if (a.hasError) return AsyncError(a.error!, a.stackTrace!);
  }
  if (!tasks.hasValue ||
      !entries.hasValue ||
      !completions.hasValue ||
      !failed.hasValue) {
    return const AsyncLoading();
  }

  final byTask = <String, List<TimeEntry>>{};
  for (final e in entries.requireValue) {
    byTask.putIfAbsent(e.taskId, () => []).add(e);
  }
  final completionByTask = {
    for (final c in completions.requireValue) c.taskId: c,
  };

  return AsyncData([
    for (final t in tasks.requireValue)
      () {
        final taskEntries = (byTask[t.id] ?? [])
          ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
        final completion = completionByTask[t.id];
        final local = TaskLocalState(
          openEntry: DurationCalculator.openEntry(taskEntries),
          hasLocalCompletion: completion != null,
          completionConfirmed: completion?.confirmed ?? false,
          hasFailedSync: failed.requireValue.contains(t.id),
        );
        return TaskView(
          task: t,
          status: deriveStatus(t, local, now),
          entries: taskEntries,
          completion: completion,
        );
      }(),
  ]);
});

final taskViewProvider = Provider.family<AsyncValue<TaskView?>, String>((
  ref,
  id,
) {
  return ref.watch(taskViewsProvider).whenData((views) {
    for (final v in views) {
      if (v.id == id) return v;
    }
    return null;
  });
});

/// The task currently being worked on (working or on break), if any.
final activeTaskProvider = Provider<TaskView?>((ref) {
  final views = ref.watch(taskViewsProvider).value ?? const [];
  for (final v in views) {
    if (v.status.isActive) return v;
  }
  return null;
});

final locationChecksProvider =
    StreamProvider.family<List<LocationCheck>, String>(
      (ref, taskId) =>
          ref.watch(workSessionRepositoryProvider).watchChecks(taskId),
    );

final photosProvider = StreamProvider.family<List<TaskPhoto>, String>(
  (ref, taskId) => ref.watch(completionRepositoryProvider).watchPhotos(taskId),
);

final materialsProvider = StreamProvider.family<List<MaterialEntry>, String>(
  (ref, taskId) =>
      ref.watch(completionRepositoryProvider).watchMaterials(taskId),
);

/// Server reason for a task's failed sync items, if any.
final syncFailureMessageProvider = StreamProvider.family<String?, String>(
  (ref, taskId) => ref
      .watch(outboxProvider)
      .watchFailedForTask(taskId)
      .map((rows) => rows.isEmpty ? null : rows.first.lastErrorMessage),
);
