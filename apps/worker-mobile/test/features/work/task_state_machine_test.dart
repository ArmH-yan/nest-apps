import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/features/tasks/domain/task.dart';
import 'package:nest_worker/features/tasks/domain/task_config.dart';
import 'package:nest_worker/features/tasks/domain/task_status.dart';
import 'package:nest_worker/features/work/domain/task_state_machine.dart';
import 'package:nest_worker/features/work/domain/time_entry.dart';

import '../../support/fixtures.dart';

void main() {
  const config = TaskConfig();
  final task = buildTask();
  final now = nineAmYerevan.add(const Duration(minutes: 5));

  TaskActionError? check(
    TaskAction action,
    TaskDisplayStatus status, {
    Task? t,
    DateTime? at,
    String? otherActive,
    bool verified = true,
  }) => TaskStateMachine.check(
    action: action,
    task: t ?? task,
    status: status,
    config: config,
    now: at ?? now,
    otherActiveTaskId: otherActive,
    hasVerifiedStartCheck: verified,
  );

  group('deriveStatus', () {
    test('upcoming → today follows the calendar day (Yerevan)', () {
      final tomorrow = buildTask(
        start: nineAmYerevan.add(const Duration(days: 1)),
      );

      expect(
        deriveStatus(tomorrow, TaskLocalState.empty, now),
        TaskDisplayStatus.upcoming,
      );
      expect(
        deriveStatus(
          tomorrow,
          TaskLocalState.empty,
          now.add(const Duration(days: 1)),
        ),
        TaskDisplayStatus.today,
      );
    });

    test('open work / break entries → inProgress / onBreak', () {
      expect(
        deriveStatus(
          task,
          TaskLocalState(openEntry: entry(TimeEntryKind.work, now)),
          now,
        ),
        TaskDisplayStatus.inProgress,
      );
      expect(
        deriveStatus(
          task,
          TaskLocalState(openEntry: entry(TimeEntryKind.breakTime, now)),
          now,
        ),
        TaskDisplayStatus.onBreak,
      );
    });

    test('local completion → waiting; failed sync → synchronizationFailed', () {
      expect(
        deriveStatus(task, const TaskLocalState(hasLocalCompletion: true), now),
        TaskDisplayStatus.waitingForSubmission,
      );
      expect(
        deriveStatus(
          task,
          const TaskLocalState(hasLocalCompletion: true, hasFailedSync: true),
          now,
        ),
        TaskDisplayStatus.synchronizationFailed,
      );
    });

    test('server submitted / confirmed → completed; cancelled → cancelled', () {
      expect(
        deriveStatus(
          buildTask(serverStatus: ServerTaskStatus.submitted),
          TaskLocalState.empty,
          now,
        ),
        TaskDisplayStatus.completed,
      );
      expect(
        deriveStatus(
          task,
          const TaskLocalState(completionConfirmed: true),
          now,
        ),
        TaskDisplayStatus.completed,
      );
      expect(
        deriveStatus(
          buildTask(serverStatus: ServerTaskStatus.cancelled),
          TaskLocalState.empty,
          now,
        ),
        TaskDisplayStatus.cancelled,
      );
    });
  });

  group('allowed transitions', () {
    test('today → inProgress with verified location', () {
      expect(check(TaskAction.start, TaskDisplayStatus.today), isNull);
    });
    test('inProgress → onBreak → inProgress', () {
      expect(
        check(TaskAction.startBreak, TaskDisplayStatus.inProgress),
        isNull,
      );
      expect(check(TaskAction.resumeWork, TaskDisplayStatus.onBreak), isNull);
    });
    test('inProgress or onBreak → waitingForSubmission (finish)', () {
      expect(check(TaskAction.finish, TaskDisplayStatus.inProgress), isNull);
      expect(check(TaskAction.finish, TaskDisplayStatus.onBreak), isNull);
    });
    test('synchronizationFailed → retry', () {
      expect(
        check(TaskAction.retrySync, TaskDisplayStatus.synchronizationFailed),
        isNull,
      );
    });
  });

  group('invalid transitions are rejected', () {
    test('upcoming task cannot be started (not scheduled today)', () {
      final tomorrow = buildTask(
        start: nineAmYerevan.add(const Duration(days: 1)),
      );
      expect(
        check(TaskAction.start, TaskDisplayStatus.upcoming, t: tomorrow),
        TaskActionError.notScheduledToday,
      );
    });
    test('start before the start window', () {
      expect(
        check(
          TaskAction.start,
          TaskDisplayStatus.today,
          at: nineAmYerevan.subtract(const Duration(hours: 3)),
        ),
        TaskActionError.tooEarly,
      );
    });
    test('start without verified location', () {
      expect(
        check(TaskAction.start, TaskDisplayStatus.today, verified: false),
        TaskActionError.locationNotVerified,
      );
    });
    test('second active task', () {
      expect(
        check(TaskAction.start, TaskDisplayStatus.today, otherActive: 'task-2'),
        TaskActionError.anotherTaskActive,
      );
    });
    test('completed → inProgress', () {
      expect(
        check(TaskAction.start, TaskDisplayStatus.completed),
        TaskActionError.alreadyCompleted,
      );
      expect(
        check(TaskAction.resumeWork, TaskDisplayStatus.completed),
        TaskActionError.alreadyCompleted,
      );
    });
    test('cancelled task cannot be started', () {
      expect(
        check(TaskAction.start, TaskDisplayStatus.cancelled),
        TaskActionError.cancelled,
      );
    });
    test('break/resume/finish from wrong states', () {
      expect(
        check(TaskAction.startBreak, TaskDisplayStatus.onBreak),
        TaskActionError.invalidTransition,
      );
      expect(
        check(TaskAction.resumeWork, TaskDisplayStatus.inProgress),
        TaskActionError.invalidTransition,
      );
      expect(
        check(TaskAction.finish, TaskDisplayStatus.today),
        TaskActionError.invalidTransition,
      );
      expect(
        check(TaskAction.start, TaskDisplayStatus.inProgress),
        TaskActionError.invalidTransition,
      );
      expect(
        check(TaskAction.start, TaskDisplayStatus.waitingForSubmission),
        TaskActionError.invalidTransition,
      );
    });
    test('ensure() throws a typed exception', () {
      expect(
        () => TaskStateMachine.ensure(
          action: TaskAction.startBreak,
          task: task,
          status: TaskDisplayStatus.today,
          config: config,
          now: now,
        ),
        throwsA(
          isA<TaskActionException>().having(
            (e) => e.error,
            'error',
            TaskActionError.invalidTransition,
          ),
        ),
      );
    });
  });
}
