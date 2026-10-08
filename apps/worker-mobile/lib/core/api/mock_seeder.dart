import 'package:drift/drift.dart';

import '../../features/completion/domain/completion_models.dart';
import '../../features/work/domain/time_entry.dart';
import '../storage/app_database.dart';
import 'mock_data.dart';

/// Mock mode only: puts yesterday's completed task (with sessions and photos)
/// into the local DB once, so History has a full example (WORKER_APP_SPEC
/// "Mock data", task 3).
abstract final class MockSeeder {
  static Future<void> seedIfEmpty(AppDatabase db, DateTime now) async {
    final taskId = MockData.yesterdayTaskId;
    final existing = await (db.select(
      db.completions,
    )..where((c) => c.taskId.equals(taskId))).getSingleOrNull();
    if (existing != null) return;

    final timeline = MockData.yesterdayTimeline(now);
    var workMs = 0;
    var breakMs = 0;
    DateTime end = timeline.start;
    await db.transaction(() async {
      for (final (i, (isWork, fromMin, toMin)) in timeline.cycles.indexed) {
        final start = timeline.start.add(Duration(minutes: fromMin));
        end = timeline.start.add(Duration(minutes: toMin));
        final ms = end.difference(start).inMilliseconds;
        isWork ? workMs += ms : breakMs += ms;
        await db
            .into(db.timeEntries)
            .insert(
              TimeEntriesCompanion.insert(
                id: 'seed-te-$i',
                taskId: taskId,
                kind: (isWork ? TimeEntryKind.work : TimeEntryKind.breakTime)
                    .name,
                startedAt: start,
                endedAt: Value(end),
              ),
            );
      }
      for (var i = 0; i < 3; i++) {
        await db
            .into(db.photos)
            .insert(
              PhotosCompanion.insert(
                id: 'seed-photo-$i',
                taskId: taskId,
                kind: PhotoKind.after.name,
                takenAt: end.subtract(Duration(minutes: 10 - i)),
                uploadState: PhotoUploadState.uploaded.name,
                progress: const Value(1),
              ),
            );
      }
      await db
          .into(db.completions)
          .insert(
            CompletionsCompanion.insert(
              id: 'seed-completion',
              taskId: taskId,
              workerId: MockData.worker.id,
              completedAt: end,
              comment: const Value(
                'Net installed on floors 3–6. Two anchors replaced.',
              ),
              totalWorkMs: workMs,
              totalBreakMs: breakMs,
              confirmed: const Value(true),
            ),
          );
    });
  }
}
