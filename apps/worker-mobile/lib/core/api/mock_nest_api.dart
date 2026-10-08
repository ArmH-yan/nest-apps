import 'dart:async';

import '../../features/auth/domain/worker.dart';
import '../../features/completion/domain/completion_models.dart';
import '../../features/earnings/domain/earnings_summary.dart';
import '../../features/notifications/domain/app_notification.dart';
import '../../features/tasks/domain/task.dart';
import '../../features/tasks/domain/task_config.dart';
import '../../features/work/domain/location_check.dart';
import '../../features/work/domain/time_entry.dart';
import '../network/api_exception.dart';
import '../time/clock.dart';
import '../time/yerevan_time.dart';
import 'mock_data.dart';
import 'nest_api.dart';

/// Switches for exercising error paths from the dev menu and tests.
class MockApiScenario {
  /// Every call fails with NETWORK_ERROR (simulates no signal).
  bool offline = false;

  /// The next photo upload fails once (retryable).
  bool failNextUpload = false;

  /// The next completion is rejected with 409 (non-retryable).
  bool rejectNextCompletion = false;

  Duration latency = const Duration(milliseconds: 350);
}

/// In-memory stand-in for the NEST backend with deterministic data
/// (WORKER_APP_SPEC "Mock data"). Behaves like the real API: idempotent PUTs,
/// server-side status changes, typed errors.
class MockNestApi implements NestApi {
  MockNestApi({required Clock clock, MockApiScenario? scenario})
    : _clock = clock,
      scenario = scenario ?? MockApiScenario() {
    _tasks = {for (final t in MockData.tasks(clock.now())) t.id: t};
    _notifications = MockData.notifications(clock.now());
  }

  final Clock _clock;
  final MockApiScenario scenario;

  late final Map<String, Task> _tasks;
  late final List<AppNotification> _notifications;
  String _password = MockData.password;

  /// What the "server" has received, for tests and debugging.
  final Map<String, LocationCheck> receivedChecks = {};
  final Map<String, TimeEntry> receivedTimeEntries = {};
  final Map<String, MaterialEntry> receivedMaterials = {};
  final Set<String> confirmedPhotos = {};
  final Map<String, TaskCompletion> receivedCompletions = {};

  Future<void> _call() async {
    if (scenario.latency > Duration.zero) {
      await Future<void>.delayed(scenario.latency);
    }
    if (scenario.offline) {
      throw const ApiException(
        code: ApiException.networkError,
        message: 'No connection to the server.',
      );
    }
  }

  Task _task(String id) {
    final task = _tasks[id];
    if (task == null) {
      throw const ApiException(
        code: 'NOT_FOUND',
        message: 'Task not found.',
        statusCode: 404,
      );
    }
    return task;
  }

  void _ensureWritable(String taskId) {
    if (_task(taskId).serverStatus == ServerTaskStatus.cancelled) {
      throw const ApiException(
        code: 'TASK_CANCELLED',
        message: 'This task was cancelled by your manager.',
        statusCode: 409,
      );
    }
  }

  @override
  Future<LoginResult> login({
    required String phone,
    required String password,
  }) async {
    await _call();
    final normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (normalized != MockData.worker.phone.replaceAll(' ', '') ||
        password != _password) {
      throw const ApiException(
        code: 'INVALID_CREDENTIALS',
        message: 'Wrong phone number or password.',
        statusCode: 401,
      );
    }
    return const LoginResult(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      worker: MockData.worker,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _call();
    if (currentPassword != _password) {
      throw const ApiException(
        code: 'INVALID_CREDENTIALS',
        message: 'Current password is wrong.',
        // 400 like the real API: the session is fine, only the typed password isn't.
        statusCode: 400,
      );
    }
    _password = newPassword;
  }

  @override
  Future<Worker> me() async {
    await _call();
    return MockData.worker;
  }

  @override
  Future<TaskConfig> config() async {
    await _call();
    return MockData.config;
  }

  @override
  Future<List<Task>> tasks({
    required DateTime from,
    required DateTime to,
  }) async {
    await _call();
    return _tasks.values
        .where(
          (t) =>
              !t.scheduledStart.isBefore(from) && !t.scheduledStart.isAfter(to),
        )
        .toList()
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
  }

  @override
  Future<List<ExpectedMaterial>> expectedMaterials(String taskId) async {
    await _call();
    _task(taskId);
    return MockData.expectedMaterials[taskId] ?? const [];
  }

  @override
  Future<List<CatalogItem>> catalog() async {
    await _call();
    return MockData.catalog;
  }

  @override
  Future<void> putLocationCheck(LocationCheck check) async {
    await _call();
    _task(check.taskId);
    receivedChecks[check.id] = check;
  }

  @override
  Future<void> putTimeEntry(TimeEntry entry) async {
    await _call();
    _ensureWritable(entry.taskId);
    final previous = receivedTimeEntries[entry.id];
    if (previous != null && previous.endedAt != null && previous != entry) {
      throw const ApiException(
        code: 'TIME_ENTRY_FINALIZED',
        message: 'This time entry was already closed.',
        statusCode: 409,
      );
    }
    receivedTimeEntries[entry.id] = entry;
    final task = _task(entry.taskId);
    if (task.serverStatus == ServerTaskStatus.assigned) {
      _tasks[task.id] = task.copyWith(
        serverStatus: ServerTaskStatus.inProgress,
      );
    }
  }

  @override
  Future<void> putMaterial(MaterialEntry material) async {
    await _call();
    _ensureWritable(material.taskId);
    receivedMaterials[material.id] = material;
  }

  @override
  Future<Uri> presignPhoto(TaskPhoto photo) async {
    await _call();
    _task(photo.taskId);
    return Uri.parse('https://storage.mock/upload/${photo.id}');
  }

  @override
  Future<void> uploadPhoto(
    Uri uploadUrl,
    String localPath, {
    void Function(double progress)? onProgress,
  }) async {
    for (var i = 1; i <= 5; i++) {
      await Future<void>.delayed(scenario.latency ~/ 2);
      if (scenario.offline) {
        throw const ApiException(
          code: ApiException.networkError,
          message: 'Upload interrupted.',
        );
      }
      if (scenario.failNextUpload && i == 3) {
        scenario.failNextUpload = false;
        throw const ApiException(
          code: 'UPLOAD_FAILED',
          message: 'Upload failed. It will be retried.',
          statusCode: 503,
        );
      }
      onProgress?.call(i / 5);
    }
  }

  @override
  Future<void> confirmPhoto(String photoId) async {
    await _call();
    confirmedPhotos.add(photoId);
  }

  @override
  Future<void> putCompletion(TaskCompletion completion) async {
    await _call();
    _ensureWritable(completion.taskId);
    final existing = receivedCompletions[completion.taskId];
    if (existing != null) {
      if (existing.id == completion.id) return; // idempotent replay
      throw const ApiException(
        code: 'TASK_ALREADY_SUBMITTED',
        message: 'This task was already submitted.',
        statusCode: 409,
      );
    }
    if (scenario.rejectNextCompletion) {
      scenario.rejectNextCompletion = false;
      throw const ApiException(
        code: 'COMPLETION_REJECTED',
        message: 'The server rejected this submission (simulated).',
        statusCode: 409,
      );
    }
    final missing = completion.photoIds.where(
      (id) => !confirmedPhotos.contains(id),
    );
    if (missing.isNotEmpty) {
      throw ApiException(
        code: 'PHOTOS_NOT_UPLOADED',
        message: 'Some photos have not been uploaded yet.',
        statusCode: 409,
        details: {'photo_ids': missing.toList()},
      );
    }
    receivedCompletions[completion.taskId] = completion;
    _tasks[completion.taskId] = _task(completion.taskId)
        .copyWith(serverStatus: ServerTaskStatus.submitted);
    _notifications.insert(
      0,
      AppNotification(
        id: 'n-${completion.id}',
        type: NotificationType.submissionAccepted,
        title: 'Task submitted successfully',
        body: _task(completion.taskId).title,
        taskId: completion.taskId,
        createdAt: _clock.now(),
      ),
    );
  }

  @override
  Future<EarningsSummary> earnings({
    required int year,
    required int month,
  }) async {
    await _call();
    final approved = MockData.approvedPay(_clock.now()).where((p) {
      final day = YerevanTime.day(p.scheduledStart);
      return day.year == year && day.month == month;
    }).toList();
    final total = approved.fold<int>(0, (sum, p) => sum + p.payAmd);
    return EarningsSummary(
      year: year,
      month: month,
      approvedTasks: approved.length,
      approvedAmount: '$total.00',
    );
  }

  @override
  Future<List<AppNotification>> notifications() async {
    await _call();
    return List.unmodifiable(_notifications);
  }

  @override
  Future<void> markNotificationRead(String id) async {
    await _call();
    final i = _notifications.indexWhere((n) => n.id == id);
    if (i >= 0 && _notifications[i].readAt == null) {
      _notifications[i] = _notifications[i].copyWith(readAt: _clock.now());
    }
  }

  /// Dev/test helper: the manager cancels a task.
  void cancelTask(String taskId) {
    _tasks[taskId] = _task(taskId)
        .copyWith(serverStatus: ServerTaskStatus.cancelled);
  }
}
