import '../../../core/time/yerevan_time.dart';
import '../../work/domain/time_entry.dart';
import 'task.dart';

/// What the app shows for a task (WORKER_APP_SPEC "Task display status").
/// Derived on the device; only `assigned/inProgress/submitted/cancelled`
/// exist on the server.
enum TaskDisplayStatus {
  upcoming,
  today,
  inProgress,
  onBreak,
  waitingForSubmission,
  synchronizationFailed,
  completed,
  cancelled,
}

/// Local facts about a task that the server doesn't know yet.
class TaskLocalState {
  const TaskLocalState({
    this.openEntry,
    this.hasLocalCompletion = false,
    this.completionConfirmed = false,
    this.hasFailedSync = false,
  });

  static const empty = TaskLocalState();

  final TimeEntry? openEntry;
  final bool hasLocalCompletion;
  final bool completionConfirmed;
  final bool hasFailedSync;
}

TaskDisplayStatus deriveStatus(Task task, TaskLocalState local, DateTime now) {
  if (task.serverStatus == ServerTaskStatus.submitted ||
      local.completionConfirmed) {
    return TaskDisplayStatus.completed;
  }
  if (task.serverStatus == ServerTaskStatus.cancelled) {
    return TaskDisplayStatus.cancelled;
  }
  if (local.hasFailedSync) return TaskDisplayStatus.synchronizationFailed;
  if (local.hasLocalCompletion) return TaskDisplayStatus.waitingForSubmission;

  final open = local.openEntry;
  if (open != null) {
    return open.kind == TimeEntryKind.work
        ? TaskDisplayStatus.inProgress
        : TaskDisplayStatus.onBreak;
  }

  final taskDay = YerevanTime.day(task.scheduledStart);
  final today = YerevanTime.day(now);
  // Past days that were never started are shown with today's tasks; the
  // start guard still refuses them ("not scheduled for today").
  return taskDay.isAfter(today)
      ? TaskDisplayStatus.upcoming
      : TaskDisplayStatus.today;
}

extension TaskDisplayStatusX on TaskDisplayStatus {
  /// Working or on break — the task owns the Work tab.
  bool get isActive =>
      this == TaskDisplayStatus.inProgress || this == TaskDisplayStatus.onBreak;

  bool get isFinished =>
      this == TaskDisplayStatus.completed ||
      this == TaskDisplayStatus.waitingForSubmission ||
      this == TaskDisplayStatus.synchronizationFailed;
}
