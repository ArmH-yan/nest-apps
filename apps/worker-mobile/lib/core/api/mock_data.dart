import '../../features/auth/domain/worker.dart';
import '../../features/completion/domain/completion_models.dart';
import '../../features/notifications/domain/app_notification.dart';
import '../../features/tasks/domain/task.dart';
import '../../features/tasks/domain/task_config.dart';
import '../time/yerevan_time.dart';

/// Deterministic mock data (WORKER_APP_SPEC "Mock data"). Dates are relative
/// to "today" in Yerevan, so the same inputs always produce the same output.
abstract final class MockData {
  static const password = 'nest1234';

  static const worker = Worker(
    id: 'w-007',
    fullName: 'Arman Harutyunyan',
    employeeCode: 'NEST-007',
    phone: '+37491000007',
  );

  static const config = TaskConfig(
    defaultGeofenceRadiusM: 150,
    maxLocationAccuracyM: 100,
    minCompletionPhotos: 1,
    startWindowMinutesBefore: 120,
  );

  static const _david = CrewMember(
    workerId: 'w-011',
    fullName: 'David Sargsyan',
    role: TaskRole.member,
    phone: '+37491000011',
  );
  static const _karen = CrewMember(
    workerId: 'w-014',
    fullName: 'Karen Petrosyan',
    role: TaskRole.member,
    phone: '+37491000014',
  );
  static const _armanLead = CrewMember(
    workerId: 'w-007',
    fullName: 'Arman Harutyunyan',
    role: TaskRole.lead,
    phone: '+37491000007',
  );
  static const _armanMember = CrewMember(
    workerId: 'w-007',
    fullName: 'Arman Harutyunyan',
    role: TaskRole.member,
    phone: '+37491000007',
  );
  static const _vardanLead = CrewMember(
    workerId: 'w-003',
    fullName: 'Vardan Grigoryan',
    role: TaskRole.lead,
    phone: '+37491000003',
  );

  static const catalog = [
    CatalogItem(id: 'net-10x5', name: 'Safety net 10×5 m', unit: 'pcs'),
    CatalogItem(id: 'net-m2', name: 'Safety net', unit: 'm2'),
    CatalogItem(id: 'dust-m2', name: 'Dust net', unit: 'm2'),
    CatalogItem(id: 'anchor-m12', name: 'Anchor M12', unit: 'pcs'),
    CatalogItem(id: 'cable-8', name: 'Steel cable 8 mm', unit: 'm'),
  ];

  static const _yesterdayTaskId = 'asg-103';

  static final Map<String, List<ExpectedMaterial>> expectedMaterials = {
    'asg-105': [
      ExpectedMaterial(item: catalog[1], quantity: 300),
      ExpectedMaterial(item: catalog[3], quantity: 40),
    ],
  };

  /// Yerevan wall clock on [now]'s day plus [days], at [hour]:[minute].
  static DateTime _at(DateTime now, int days, int hour, [int minute = 0]) {
    final day = YerevanTime.day(now).add(Duration(days: days));
    return YerevanTime.at(day.year, day.month, day.day, hour, minute);
  }

  static List<Task> tasks(DateTime now) => [
    Task(
      id: 'asg-101',
      jobId: 'job-12',
      visitId: 'visit-210',
      jobType: JobType.installation,
      title: 'Install Safety Net – Building A',
      projectName: 'Davtashen Residential',
      customerName: 'Arm Build LLC',
      instructions:
          'Install the catch-fan safety net on floors 6–9, east façade. '
          'Check anchors before mounting.',
      siteName: 'Building A',
      address: 'Davtashen 3rd district, Yerevan',
      latitude: 40.2262,
      longitude: 44.4930,
      geofenceRadiusM: 150,
      accessNotes: 'Gate 2 on the north side. Ask for foreman Hayk.',
      siteContactName: 'Hayk Avetisyan (foreman)',
      siteContactPhone: '+37493000101',
      scheduledStart: _at(now, 0, 9),
      scheduledEnd: _at(now, 0, 17),
      role: TaskRole.lead,
      crew: const [_armanLead, _david, _karen],
      serverStatus: ServerTaskStatus.assigned,
    ),
    Task(
      id: 'asg-105',
      jobId: 'job-9',
      visitId: 'visit-214',
      jobType: JobType.dismantling,
      title: 'Dismantle Safety Net – Building E',
      projectName: 'Nor Nork Tower',
      customerName: 'Renshin CJSC',
      instructions:
          'Remove the safety net from the west façade. Bring back all anchors.',
      siteName: 'Building E',
      address: 'Gai Ave 15, Nor Nork, Yerevan',
      latitude: 40.1990,
      longitude: 44.5630,
      accessNotes: 'Crane on site until 15:00 — wait for the signal.',
      scheduledStart: _at(now, 0, 14),
      scheduledEnd: _at(now, 0, 18),
      role: TaskRole.lead,
      crew: const [_armanLead, _karen],
      serverStatus: ServerTaskStatus.assigned,
    ),
    Task(
      id: 'asg-102',
      jobId: 'job-14',
      visitId: 'visit-220',
      jobType: JobType.installation,
      title: 'Dust Protection Installation – Building B',
      projectName: 'Komitas 22 Residence',
      customerName: 'Elite Group',
      instructions: 'Install dust net on scaffolding, south and east sides.',
      siteName: 'Building B',
      address: 'Komitas Ave 22, Yerevan',
      latitude: 40.2045,
      longitude: 44.5160,
      scheduledStart: _at(now, 1, 10),
      scheduledEnd: _at(now, 1, 16),
      role: TaskRole.member,
      crew: const [_vardanLead, _armanMember],
      serverStatus: ServerTaskStatus.assigned,
    ),
    Task(
      id: 'asg-104',
      jobId: 'job-15',
      visitId: 'visit-231',
      jobType: JobType.inspection,
      title: 'Safety Net Inspection – Building D',
      projectName: 'Ajapnyak Heights',
      customerName: 'Arm Build LLC',
      instructions: 'Monthly inspection of the safety net and anchors.',
      siteName: 'Building D',
      address: 'Margaryan St 25, Ajapnyak, Yerevan',
      latitude: 40.1960,
      longitude: 44.4580,
      scheduledStart: _at(now, 3, 10),
      scheduledEnd: _at(now, 3, 11),
      role: TaskRole.member,
      crew: const [_vardanLead, _armanMember],
      serverStatus: ServerTaskStatus.assigned,
    ),
    Task(
      id: _yesterdayTaskId,
      jobId: 'job-8',
      visitId: 'visit-198',
      jobType: JobType.installation,
      title: 'Install Protective Net – Building C',
      projectName: 'Arabkir Business Center',
      customerName: 'Arabkir Development',
      siteName: 'Building C',
      address: 'Komitas Ave 49, Arabkir, Yerevan',
      latitude: 40.2080,
      longitude: 44.5050,
      scheduledStart: _at(now, -1, 9),
      scheduledEnd: _at(now, -1, 17),
      role: TaskRole.member,
      crew: const [_vardanLead, _armanMember],
      serverStatus: ServerTaskStatus.submitted,
    ),
  ];

  /// Seed for yesterday's completed task so History has a full example.
  static String get yesterdayTaskId => _yesterdayTaskId;

  static ({DateTime start, List<(bool work, int fromMin, int toMin)> cycles})
  yesterdayTimeline(DateTime now) => (
    start: _at(now, -1, 9, 5),
    // work 09:05–12:30, break 12:30–13:00, work 13:00–16:47 → 7h12m work
    cycles: const [(true, 0, 205), (false, 205, 235), (true, 235, 462)],
  );

  /// Tasks the manager already approved, with the fixed pay (whole AMD) they
  /// entered. Yesterday's task is first. Some of these fall in the previous
  /// month, so the "this month" filter has something to filter out.
  static List<({DateTime scheduledStart, int payAmd})> approvedPay(
    DateTime now,
  ) => [
    (scheduledStart: _at(now, -1, 9), payAmd: 25000),
    (scheduledStart: _at(now, -3, 9), payAmd: 30000),
    (scheduledStart: _at(now, -6, 10), payAmd: 25000),
    (scheduledStart: _at(now, -10, 9), payAmd: 35000),
    (scheduledStart: _at(now, -20, 9), payAmd: 20000),
    (scheduledStart: _at(now, -40, 9), payAmd: 25000),
  ];

  static List<AppNotification> notifications(DateTime now) => [
    AppNotification(
      id: 'n-1',
      type: NotificationType.taskReminder,
      title: 'Your task starts today at 09:00',
      body: 'Install Safety Net – Building A',
      taskId: 'asg-101',
      createdAt: _at(now, 0, 7, 30),
    ),
    AppNotification(
      id: 'n-2',
      type: NotificationType.taskAssigned,
      title: 'New task assigned',
      body: 'Dismantle Safety Net – Building E',
      taskId: 'asg-105',
      createdAt: _at(now, -1, 18, 10),
    ),
    AppNotification(
      id: 'n-3',
      type: NotificationType.taskChanged,
      title: 'Task schedule changed',
      body: 'Dust Protection Installation – Building B moved to tomorrow 10:00',
      taskId: 'asg-102',
      createdAt: _at(now, -1, 16, 45),
      readAt: _at(now, -1, 17),
    ),
  ];
}
