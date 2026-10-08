import '../../../core/time/yerevan_time.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_config.dart';
import '../../tasks/domain/task_status.dart';

enum TaskAction { start, startBreak, resumeWork, finish, retrySync }

/// Why an action was refused. Each maps to a localized message in the UI.
enum TaskActionError {
  notScheduledToday,
  tooEarly,
  anotherTaskActive,
  alreadyCompleted,
  cancelled,
  locationNotVerified,
  invalidTransition,
}

class TaskActionException implements Exception {
  const TaskActionException(this.error);

  final TaskActionError error;

  @override
  String toString() => 'TaskActionException($error)';
}

/// The single place that decides whether an action is allowed
/// (WORKER_APP_SPEC "Allowed actions"). The server re-validates on sync.
abstract final class TaskStateMachine {
  /// Returns null when allowed, otherwise the reason it isn't.
  static TaskActionError? check({
    required TaskAction action,
    required Task task,
    required TaskDisplayStatus status,
    required TaskConfig config,
    required DateTime now,
    String? otherActiveTaskId,
    bool hasVerifiedStartCheck = false,
  }) {
    if (status == TaskDisplayStatus.cancelled) return TaskActionError.cancelled;
    if (status == TaskDisplayStatus.completed) {
      return TaskActionError.alreadyCompleted;
    }

    switch (action) {
      case TaskAction.start:
        if (status != TaskDisplayStatus.today &&
            status != TaskDisplayStatus.upcoming) {
          return TaskActionError.invalidTransition;
        }
        if (!YerevanTime.isSameDay(task.scheduledStart, now)) {
          return TaskActionError.notScheduledToday;
        }
        final earliest = task.scheduledStart.subtract(
          Duration(minutes: config.startWindowMinutesBefore),
        );
        if (now.isBefore(earliest)) return TaskActionError.tooEarly;
        if (otherActiveTaskId != null && otherActiveTaskId != task.id) {
          return TaskActionError.anotherTaskActive;
        }
        if (!hasVerifiedStartCheck) return TaskActionError.locationNotVerified;
        return null;
      case TaskAction.startBreak:
        return status == TaskDisplayStatus.inProgress
            ? null
            : TaskActionError.invalidTransition;
      case TaskAction.resumeWork:
        return status == TaskDisplayStatus.onBreak
            ? null
            : TaskActionError.invalidTransition;
      case TaskAction.finish:
        return status.isActive ? null : TaskActionError.invalidTransition;
      case TaskAction.retrySync:
        return status == TaskDisplayStatus.synchronizationFailed
            ? null
            : TaskActionError.invalidTransition;
    }
  }

  static void ensure({
    required TaskAction action,
    required Task task,
    required TaskDisplayStatus status,
    required TaskConfig config,
    required DateTime now,
    String? otherActiveTaskId,
    bool hasVerifiedStartCheck = false,
  }) {
    final error = check(
      action: action,
      task: task,
      status: status,
      config: config,
      now: now,
      otherActiveTaskId: otherActiveTaskId,
      hasVerifiedStartCheck: hasVerifiedStartCheck,
    );
    if (error != null) throw TaskActionException(error);
  }
}
