import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/media/photo_capture_service.dart';
import 'package:nest_worker/core/sync/sync_models.dart';
import 'package:nest_worker/core/sync/sync_service.dart';
import 'package:nest_worker/features/completion/data/completion_service.dart';
import 'package:nest_worker/features/completion/domain/completion_models.dart';
import 'package:nest_worker/features/completion/domain/completion_validator.dart';
import 'package:nest_worker/features/profile/data/settings_repository.dart';
import 'package:nest_worker/features/tasks/domain/task.dart';
import 'package:nest_worker/features/tasks/domain/task_status.dart';
import 'package:nest_worker/features/work/domain/location_verification.dart';
import 'package:nest_worker/features/work/domain/task_state_machine.dart';
import 'package:nest_worker/features/work/domain/time_entry.dart';

import '../../support/harness.dart';

void main() {
  late Harness h;
  late Task task;

  setUp(() async {
    h = await Harness.create();
    task = (await h.tasks.getTask(Harness.buildingA))!;
  });
  tearDown(() => h.dispose());

  Future<void> startWorking() async {
    final (result, check) = await h.work.verifyLocation(task);
    expect(result.outcome, VerificationOutcome.verified);
    await h.work.startWork(task, check);
  }

  Future<void> addMaterial(double qty) => h.completions.saveMaterial(
    MaterialEntry(
      id: 'mat-1',
      taskId: task.id,
      catalogItemId: 'net-m2',
      itemName: 'Safety net',
      unit: 'm2',
      quantity: qty,
      movement: MaterialMovement.installed,
    ),
  );

  test('full offline workflow, then sync delivers everything once', () async {
    h.api.scenario.offline = true;

    await startWorking();
    expect(await h.work.statusOf(task), TaskDisplayStatus.inProgress);

    h.clock.advance(const Duration(hours: 3));
    await h.work.startBreak(task);
    expect(await h.work.statusOf(task), TaskDisplayStatus.onBreak);

    h.clock.advance(const Duration(minutes: 30));
    await h.work.resumeWork(task);
    h.clock.advance(const Duration(hours: 4));

    await h.completionService.addPhotos(task, PhotoSource.camera);
    await addMaterial(420);
    final completion = await h.completionService.submit(
      task: task,
      worker: h.worker,
      finishAt: h.clock.now(),
      comment: '  Done  ',
    );

    expect(completion.totalWorkDuration, const Duration(hours: 7));
    expect(completion.totalBreakDuration, const Duration(minutes: 30));
    expect(completion.comment, 'Done');
    expect(completion.timeEntries.every((e) => !e.isOpen), isTrue);
    expect(await h.work.statusOf(task), TaskDisplayStatus.waitingForSubmission);
    expect(h.api.receivedCompletions, isEmpty, reason: 'still offline');
    expect(h.sync.status.isOnline, isFalse);
    expect(await h.outboxCount(), greaterThan(0));

    // Signal returns.
    h.api.scenario.offline = false;
    await h.sync.syncNow();

    expect(await h.outboxCount(), 0);
    expect(h.api.receivedCompletions[task.id]?.id, completion.id);
    expect(h.api.receivedTimeEntries, hasLength(3));
    expect(
      h.api.receivedTimeEntries.values.every((e) => e.endedAt != null),
      isTrue,
      reason: 'open+close coalesced into one PUT with the final body',
    );
    expect(h.api.confirmedPhotos, hasLength(1));
    expect(h.api.receivedMaterials, hasLength(1));
    expect(await h.work.statusOf(task), TaskDisplayStatus.completed);
    expect(
      (await h.tasks.getTask(task.id))!.serverStatus,
      ServerTaskStatus.submitted,
    );
    expect(h.sync.status.isOnline, isTrue);
  });

  test(
    'timer state survives a restart: entries are read back from the DB',
    () async {
      await startWorking();
      h.clock.advance(const Duration(hours: 2, minutes: 34, seconds: 18));

      // A "restarted app" only has the database: re-read the entries.
      final entries = await h.sessions.entries(task.id);
      expect(entries.single.isOpen, isTrue);
      expect(
        entries.single.durationAt(h.clock.now()),
        const Duration(hours: 2, minutes: 34, seconds: 18),
      );
    },
  );

  test('start requires a verified location check', () async {
    final outside = await Harness.create(gps: GpsSource.mockOutside);
    addTearDown(outside.dispose);
    final t = (await outside.tasks.getTask(Harness.buildingA))!;

    final (result, check) = await outside.work.verifyLocation(t);

    expect(result.outcome, VerificationOutcome.outside);
    expect(check.verified, isFalse);
    await expectLater(
      outside.work.startWork(t, check),
      throwsA(
        isA<TaskActionException>().having(
          (e) => e.error,
          'error',
          TaskActionError.locationNotVerified,
        ),
      ),
    );
    // the failed check is still recorded as evidence
    expect(await outside.sessions.watchChecks(t.id).first, hasLength(1));
  });

  test('only one active task at a time', () async {
    await startWorking();
    final other = (await h.tasks.getTask('asg-105'))!; // today 14:00
    h.clock.advance(const Duration(hours: 4));
    final (_, check) = await h.work.verifyLocation(other);

    await expectLater(
      h.work.startWork(other, check),
      throwsA(
        isA<TaskActionException>().having(
          (e) => e.error,
          'error',
          TaskActionError.anotherTaskActive,
        ),
      ),
    );
  });

  test('submit is refused without photos / lead materials', () async {
    await startWorking();

    await expectLater(
      h.completionService.submit(
        task: task,
        worker: h.worker,
        finishAt: h.clock.now(),
      ),
      throwsA(
        isA<CompletionValidationException>().having((e) => e.issues, 'issues', [
          CompletionIssue.notEnoughPhotos,
          CompletionIssue.materialsRequired,
        ]),
      ),
    );
  });

  test('409 from the server → synchronizationFailed; Retry resends', () async {
    await startWorking();
    await h.completionService.addPhotos(task, PhotoSource.gallery);
    await addMaterial(10);
    h.api.scenario.rejectNextCompletion = true;
    await h.completionService.submit(
      task: task,
      worker: h.worker,
      finishAt: h.clock.now(),
    );
    await h.sync.syncNow();

    expect(
      await h.work.statusOf(task),
      TaskDisplayStatus.synchronizationFailed,
    );
    final failed = await h.outbox.watchFailedForTask(task.id).first;
    expect(failed.single.lastErrorCode, 'COMPLETION_REJECTED');

    await h.outbox.retryTask(task.id);
    await h.sync.syncNow();

    expect(await h.work.statusOf(task), TaskDisplayStatus.completed);
    expect(await h.outboxCount(), 0);
  });

  test(
    'retryable upload failure backs off and blocks the completion',
    () async {
      await startWorking();
      h.api.scenario.failNextUpload = true;
      await h.completionService.addPhotos(task, PhotoSource.camera);
      await addMaterial(10);
      await h.completionService.submit(
        task: task,
        worker: h.worker,
        finishAt: h.clock.now(),
      );
      await h.sync.syncNow();

      final photo = (await h.completions.watchPhotos(task.id).first).single;
      expect(photo.uploadState, PhotoUploadState.failed);
      expect(
        h.api.receivedCompletions,
        isEmpty,
        reason: 'completion must not overtake its photo',
      );
      expect(
        await h.work.statusOf(task),
        TaskDisplayStatus.waitingForSubmission,
      );

      // Before the backoff expires nothing is retried …
      await h.sync.syncNow();
      expect(h.api.confirmedPhotos, isEmpty);

      // … after it, the photo and then the completion go through.
      h.clock.advance(SyncService.backoff(1));
      await h.sync.syncNow();
      expect(h.api.confirmedPhotos, hasLength(1));
      expect(await h.work.statusOf(task), TaskDisplayStatus.completed);
    },
  );

  test('a photo removed before upload is never sent', () async {
    h.api.scenario.offline = true;
    await startWorking();
    await h.completionService.addPhotos(task, PhotoSource.camera);
    final photo = (await h.completions.watchPhotos(task.id).first).single;

    await h.completionService.removePhoto(photo.id);
    h.api.scenario.offline = false;
    await h.sync.syncNow();

    expect(h.api.confirmedPhotos, isEmpty);
    expect(await h.completions.watchPhotos(task.id).first, isEmpty);
  });

  test(
    'cancelled by manager while working → time entry rejected (409)',
    () async {
      h.api.scenario.offline = true;
      await startWorking();
      h.api.cancelTask(task.id);
      h.api.scenario.offline = false;

      await h.sync.syncNow();
      await h.tasks.refresh();
      final refreshed = (await h.tasks.getTask(task.id))!;

      expect(refreshed.serverStatus, ServerTaskStatus.cancelled);
      final failed = await h.outbox.watchFailedForTask(task.id).first;
      expect(failed.map((f) => f.lastErrorCode), contains('TASK_CANCELLED'));
      // local data is kept for the manager
      expect(await h.sessions.entries(task.id), hasLength(1));
    },
  );

  test('backoff doubles and is capped at 10 minutes', () {
    expect(SyncService.backoff(1), const Duration(seconds: 10));
    expect(SyncService.backoff(2), const Duration(seconds: 20));
    expect(SyncService.backoff(4), const Duration(seconds: 80));
    expect(SyncService.backoff(20), SyncService.maxBackoff);
  });

  test('outbox coalesces repeated writes to the same pending entity', () async {
    h.api.scenario.offline = true;
    await startWorking();
    await h.work.startBreak(task);

    final items = await h.db.select(h.db.syncItems).get();
    final timeEntryItems = items.where(
      (i) => i.entityType == SyncEntityType.timeEntry.name,
    );
    // work entry (opened then closed → 1 item) + break entry
    expect(timeEntryItems, hasLength(2));
    final entries = await h.sessions.entries(task.id);
    expect(entries.map((e) => e.kind), [
      TimeEntryKind.work,
      TimeEntryKind.breakTime,
    ]);
  });
}
