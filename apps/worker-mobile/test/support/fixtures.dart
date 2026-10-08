import 'package:nest_worker/core/time/yerevan_time.dart';
import 'package:nest_worker/features/tasks/domain/task.dart';
import 'package:nest_worker/features/work/domain/time_entry.dart';

/// 2026-10-07 09:00 Yerevan.
final DateTime nineAmYerevan = YerevanTime.at(2026, 10, 7, 9);

Task buildTask({
  String id = 'task-1',
  JobType jobType = JobType.installation,
  TaskRole role = TaskRole.lead,
  DateTime? start,
  ServerTaskStatus serverStatus = ServerTaskStatus.assigned,
  double? radius,
}) {
  final s = start ?? nineAmYerevan;
  return Task(
    id: id,
    jobId: 'job-1',
    visitId: 'visit-1',
    jobType: jobType,
    title: 'Install Safety Net – Building A',
    projectName: 'Davtashen Residential',
    customerName: 'Arm Build LLC',
    siteName: 'Building A',
    address: 'Davtashen 3rd district, Yerevan',
    latitude: 40.2262,
    longitude: 44.4930,
    geofenceRadiusM: radius,
    scheduledStart: s,
    scheduledEnd: s.add(const Duration(hours: 8)),
    role: role,
    serverStatus: serverStatus,
  );
}

TimeEntry entry(
  TimeEntryKind kind,
  DateTime start, [
  DateTime? end,
  String taskId = 'task-1',
]) => TimeEntry(
  id: '${kind.name}-${start.toIso8601String()}',
  taskId: taskId,
  kind: kind,
  startedAt: start,
  endedAt: end,
);
