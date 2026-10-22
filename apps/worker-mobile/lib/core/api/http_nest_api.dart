import 'dart:io';

import 'package:dio/dio.dart';

import '../../features/auth/domain/worker.dart';
import '../../features/completion/domain/completion_models.dart';
import '../../features/earnings/domain/earnings_summary.dart';
import '../../features/notifications/domain/app_notification.dart';
import '../../features/tasks/domain/task.dart';
import '../../features/tasks/domain/task_config.dart';
import '../../features/work/domain/location_check.dart';
import '../../features/work/domain/time_entry.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import 'dto/api_dtos.dart';
import 'nest_api.dart';

/// [NestApi] over HTTP (ARCHITECTURE §18). DTOs ↔ domain mapping lives here and
/// nowhere else. Server ids are integers; the app keeps them as strings.
/// Every timestamp is sent in UTC (the API rejects times without a timezone).
class HttpNestApi implements NestApi {
  HttpNestApi(this._client, {Dio? uploadDio}) : _uploadDio = uploadDio ?? Dio();

  final ApiClient _client;

  /// Plain Dio for presigned storage URLs: no base URL and no Authorization
  /// header (storage rejects a second auth mechanism).
  final Dio _uploadDio;

  static const _v1 = '/api/v1';
  static const _worker = '$_v1/worker';

  // --- auth -------------------------------------------------------------------

  @override
  Future<LoginResult> login({
    required String phone,
    required String password,
  }) async {
    final json = await _client.postJson(
      '$_v1/auth/login',
      LoginRequestDto(phone: phone, password: password).toJson(),
    );
    final dto = LoginResponseDto.fromJson(json);
    return LoginResult(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      worker: _toWorker(dto.user),
    );
  }

  @override
  Future<void> logout() => _client.postJson('$_v1/auth/logout', null);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _client.postJson('$_v1/auth/change-password', {
    'current_password': currentPassword,
    'new_password': newPassword,
  });

  @override
  Future<Worker> me() async =>
      _toWorker(MeDto.fromJson(await _client.getJson('$_v1/me')));

  static Worker _toWorker(MeDto me) {
    final info = me.worker;
    if (info == null) {
      // A manager/admin account: the worker app is for crews only.
      throw const ApiException(
        code: 'NOT_A_WORKER',
        message: 'This account is not a worker account.',
        statusCode: 403,
      );
    }
    return Worker(
      id: '${info.id}',
      fullName: me.fullName,
      employeeCode: info.employeeCode,
      phone: me.phone,
      locale: me.locale,
      mustChangePassword: me.mustChangePassword,
    );
  }

  // --- reads ------------------------------------------------------------------

  @override
  Future<TaskConfig> config() async {
    final dto = WorkerConfigDto.fromJson(
      await _client.getJson('$_worker/config'),
    );
    return TaskConfig(
      defaultGeofenceRadiusM: dto.defaultGeofenceRadiusM.toDouble(),
      maxLocationAccuracyM: dto.maxLocationAccuracyM.toDouble(),
      minCompletionPhotos: dto.minCompletionPhotos,
      startWindowMinutesBefore: dto.startWindowMinutesBefore,
      minSupportedAppVersion: dto.minSupportedAppVersion,
    );
  }

  @override
  Future<List<Task>> tasks({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _client.getList(
      '$_worker/tasks',
      query: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      },
    );
    return [
      for (final row in rows)
        _task(TaskDto.fromJson(row! as Map<String, dynamic>)),
    ];
  }

  static Task _task(TaskDto t) => Task(
    id: '${t.id}',
    jobId: '${t.jobId}',
    visitId: '${t.visitId}',
    jobType: JobType.values.byName(t.jobType.toLowerCase()),
    title: t.title,
    projectName: t.projectName,
    customerName: t.customerName,
    instructions: t.instructions,
    siteName: t.siteName,
    address: t.address,
    latitude: t.latitude,
    longitude: t.longitude,
    geofenceRadiusM: t.geofenceRadiusM?.toDouble(),
    accessNotes: t.accessNotes,
    siteContactName: t.siteContactName,
    siteContactPhone: t.siteContactPhone,
    scheduledStart: t.scheduledStart.toUtc(),
    scheduledEnd: t.scheduledEnd.toUtc(),
    role: _role(t.role),
    crew: [
      for (final c in t.crew)
        CrewMember(
          workerId: '${c.workerId}',
          fullName: c.fullName,
          role: _role(c.role),
          phone: c.phone,
        ),
    ],
    serverStatus: switch (t.status) {
      'ASSIGNED' => ServerTaskStatus.assigned,
      'IN_PROGRESS' => ServerTaskStatus.inProgress,
      'SUBMITTED' => ServerTaskStatus.submitted,
      _ => ServerTaskStatus.cancelled,
    },
  );

  static TaskRole _role(String role) =>
      role == 'LEAD' ? TaskRole.lead : TaskRole.member;

  @override
  Future<List<ExpectedMaterial>> expectedMaterials(String taskId) async {
    final rows = await _client.getList(
      '$_worker/tasks/$taskId/expected-materials',
    );
    return [
      for (final row in rows)
        () {
          final dto = ExpectedMaterialDto.fromJson(
            row! as Map<String, dynamic>,
          );
          return ExpectedMaterial(
            item: _catalogItem(dto.item),
            quantity: double.parse(dto.quantity),
          );
        }(),
    ];
  }

  @override
  Future<List<CatalogItem>> catalog() async => [
    for (final row in await _client.getList('$_worker/catalog'))
      _catalogItem(CatalogItemDto.fromJson(row! as Map<String, dynamic>)),
  ];

  static CatalogItem _catalogItem(CatalogItemDto dto) =>
      CatalogItem(id: '${dto.id}', name: dto.name, unit: dto.unit);

  @override
  Future<EarningsSummary> earnings({
    required int year,
    required int month,
  }) async {
    final monthParam = '$year-${month.toString().padLeft(2, '0')}';
    final dto = EarningsDto.fromJson(
      await _client.getJson('$_worker/earnings', query: {'month': monthParam}),
    );
    return EarningsSummary(
      year: year,
      month: month,
      approvedTasks: dto.approvedTasks,
      approvedAmount: dto.approvedAmount,
      currency: dto.currency,
    );
  }

  @override
  Future<List<AppNotification>> notifications() async {
    final page = NotificationPageDto.fromJson(
      await _client.getJson('$_worker/notifications'),
    );
    return [
      for (final n in page.items)
        if (_notificationType(n.type) case final type?)
          AppNotification(
            id: '${n.id}',
            type: type,
            title: n.title,
            body: n.body,
            taskId: n.taskId == null ? null : '${n.taskId}',
            createdAt: n.createdAt.toUtc(),
            readAt: n.readAt?.toUtc(),
          ),
    ];
  }

  /// Unknown types (a newer server) are skipped rather than crashing.
  static NotificationType? _notificationType(String type) => switch (type) {
    'TASK_ASSIGNED' => NotificationType.taskAssigned,
    'TASK_CHANGED' => NotificationType.taskChanged,
    'TASK_CANCELLED' => NotificationType.taskCancelled,
    'TASK_REMINDER' => NotificationType.taskReminder,
    'SUBMISSION_ACCEPTED' => NotificationType.submissionAccepted,
    _ => null,
  };

  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
    String? appVersion,
  }) => _client.putJson('$_worker/devices/${Uri.encodeComponent(token)}', {
    'platform': platform,
    'app_version': appVersion,
  });

  @override
  Future<void> markNotificationRead(String id) =>
      _client.postJson('$_worker/notifications/$id/read', null);

  // --- writes (idempotent, replayed by the outbox) ---------------------------

  static int _id(String id) => int.parse(id);

  @override
  Future<void> putLocationCheck(LocationCheck check) => _client.putJson(
    '$_worker/location-checks/${check.id}',
    LocationCheckBody(
      taskId: _id(check.taskId),
      purpose: check.purpose.name.toUpperCase(),
      latitude: check.latitude,
      longitude: check.longitude,
      accuracyM: check.accuracyM,
      isMocked: check.isMocked,
      capturedAt: check.capturedAt.toUtc(),
      distanceM: check.distanceM,
      radiusM: check.radiusM,
      verified: check.verified,
    ).toJson(),
  );

  @override
  Future<void> putTimeEntry(TimeEntry entry) => _client.putJson(
    '$_worker/time-entries/${entry.id}',
    TimeEntryBody(
      taskId: _id(entry.taskId),
      kind: entry.kind == TimeEntryKind.work ? 'WORK' : 'BREAK',
      startedAt: entry.startedAt.toUtc(),
      endedAt: entry.endedAt?.toUtc(),
      startLocationCheckId: entry.startLocationCheckId,
    ).toJson(),
  );

  @override
  Future<void> putMaterial(MaterialEntry material) => _client.putJson(
    '$_worker/material-movements/${material.id}',
    MaterialMovementBody(
      taskId: _id(material.taskId),
      catalogItemId: _id(material.catalogItemId),
      quantity: _decimal(material.quantity),
      movement: material.movement.name.toUpperCase(),
      note: material.note,
      recordedAt: null,
    ).toJson(),
  );

  /// 420.0 → "420", 12.5 → "12.5" (the server stores numeric(12,3)).
  static String _decimal(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');

  @override
  Future<PhotoUploadTarget> presignPhoto(TaskPhoto photo) async {
    final path = photo.localPath;
    final size = path == null ? 0 : await File(path).length();
    final dto = PresignDto.fromJson(
      await _client.postJson(
        '$_worker/files/${photo.id}/presign',
        PresignBody(
          taskId: _id(photo.taskId),
          kind: switch (photo.kind) {
            PhotoKind.before => 'PHOTO_BEFORE',
            PhotoKind.after => 'PHOTO_AFTER',
            PhotoKind.photo => 'PHOTO',
          },
          mimeType: 'image/jpeg', // PhotoCaptureService always writes JPEG
          sizeBytes: size,
          takenAt: photo.takenAt.toUtc(),
          latitude: photo.latitude,
          longitude: photo.longitude,
        ).toJson(),
      ),
    );
    return PhotoUploadTarget(
      url: Uri.parse(dto.uploadUrl),
      headers: dto.headers,
      alreadyUploaded: dto.alreadyUploaded,
    );
  }

  @override
  Future<void> uploadPhoto(
    PhotoUploadTarget target,
    String localPath, {
    void Function(double progress)? onProgress,
  }) async {
    final file = File(localPath);
    final length = await file.length();
    try {
      await _uploadDio.putUri<void>(
        target.url,
        data: file.openRead(),
        options: Options(
          headers: {...target.headers, Headers.contentLengthHeader: length},
          sendTimeout: const Duration(minutes: 2),
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) onProgress(sent / total);
        },
      );
    } on DioException catch (e) {
      final mapped = ApiClient.toApiException(e);
      // Storage answers in XML, not our envelope. Any failure (including an
      // expired URL, 403) is retryable: the retry presigns a fresh URL.
      throw mapped.code == ApiException.unknownError
          ? const ApiException(
              code: 'UPLOAD_FAILED',
              message: 'Photo upload failed. It will be retried.',
              statusCode: 503,
            )
          : mapped;
    }
  }

  @override
  Future<void> confirmPhoto(String photoId) =>
      _client.postJson('$_worker/files/$photoId/confirm', null);

  @override
  Future<void> putCompletion(TaskCompletion completion) => _client.putJson(
    '$_worker/tasks/${completion.taskId}/completion/${completion.id}',
    CompletionBody(
      completedAt: completion.completedAt.toUtc(),
      completionLocationCheckId: completion.completionLocationCheckId,
      reportedWorkSeconds: completion.totalWorkDuration.inSeconds,
      reportedBreakSeconds: completion.totalBreakDuration.inSeconds,
      photoIds: completion.photoIds,
      comment: completion.comment,
    ).toJson(),
  );
}
