import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/api/dto/api_dtos.dart';

/// Contract test (ARCHITECTURE §40): every DTO has exactly the fields of its
/// schema in the committed apps/api/openapi.json. When the API changes, the
/// backend regenerates that file (`python -m app.cli export-openapi`) and this
/// test points at the DTOs that need updating.
void main() {
  final schemas =
      (jsonDecode(File('../api/openapi.json').readAsStringSync())
              as Map<String, dynamic>)['components']['schemas']
          as Map<String, dynamic>;

  Set<String> fieldsOf(String schema) {
    final s = schemas[schema] as Map<String, dynamic>?;
    expect(s, isNotNull, reason: 'schema $schema missing from openapi.json');
    return (s!['properties'] as Map<String, dynamic>).keys.toSet();
  }

  final now = DateTime.utc(2026, 10, 14, 9);
  const worker = WorkerInfoDto(id: 1, employeeCode: 'NEST-007');
  final me = MeDto(
    id: 1,
    phone: '+37491000007',
    email: null,
    firstName: 'A',
    lastName: 'B',
    fullName: 'A B',
    role: 'WORKER',
    locale: 'hy',
    mustChangePassword: false,
    worker: worker,
  );
  const item = CatalogItemDto(id: 1, name: 'Net', unit: 'm2');
  final notification = NotificationDto(
    id: 1,
    type: 'TASK_ASSIGNED',
    title: 't',
    body: 'b',
    taskId: 1,
    createdAt: now,
    readAt: null,
  );

  // DTO sample → OpenAPI schema name
  final samples = <String, Map<String, dynamic>>{
    'LoginRequest': const LoginRequestDto(phone: 'p', password: 'x').toJson(),
    'WorkerInfo': worker.toJson(),
    'MeResponse': me.toJson(),
    'LoginResponse': LoginResponseDto(
      accessToken: 'a',
      refreshToken: 'r',
      tokenType: 'bearer',
      expiresIn: 900,
      user: me,
    ).toJson(),
    'TokenResponse': const TokenResponseDto(
      accessToken: 'a',
      refreshToken: 'r',
      tokenType: 'bearer',
      expiresIn: 900,
    ).toJson(),
    'WorkerConfigOut': const WorkerConfigDto(
      defaultGeofenceRadiusM: 150,
      maxLocationAccuracyM: 100,
      minCompletionPhotos: 1,
      startWindowMinutesBefore: 120,
      minSupportedAppVersion: '1.0.0',
      telegramBotUsername: null,
    ).toJson(),
    'CrewMateOut': const CrewMateDto(
      workerId: 1,
      fullName: 'A',
      role: 'LEAD',
      phone: 'p',
    ).toJson(),
    'TaskOut': TaskDto(
      id: 1,
      jobId: 1,
      visitId: 1,
      jobType: 'INSTALLATION',
      title: 't',
      projectName: 'p',
      customerName: 'c',
      instructions: '',
      siteName: 's',
      address: 'a',
      latitude: 40,
      longitude: 44,
      geofenceRadiusM: null,
      accessNotes: '',
      siteContactName: null,
      siteContactPhone: null,
      scheduledStart: now,
      scheduledEnd: now,
      role: 'LEAD',
      status: 'ASSIGNED',
      crew: const [],
    ).toJson(),
    'CatalogItemOut': item.toJson(),
    'ExpectedMaterialOut': const ExpectedMaterialDto(
      item: item,
      quantity: '1',
    ).toJson(),
    'EarningsOut': const EarningsDto(
      month: '2026-10',
      approvedTasks: 0,
      approvedAmount: '0.00',
      currency: 'AMD',
    ).toJson(),
    'NotificationOut': notification.toJson(),
    'NotificationPageOut': NotificationPageDto(
      items: [notification],
      nextCursor: null,
    ).toJson(),
    'LocationCheckIn': LocationCheckBody(
      taskId: 1,
      purpose: 'START',
      latitude: 40,
      longitude: 44,
      accuracyM: 5,
      isMocked: false,
      capturedAt: now,
      distanceM: 1,
      radiusM: 150,
      verified: true,
    ).toJson(),
    'TimeEntryIn': TimeEntryBody(
      taskId: 1,
      kind: 'WORK',
      startedAt: now,
      endedAt: null,
      startLocationCheckId: null,
    ).toJson(),
    'MaterialMovementIn': const MaterialMovementBody(
      taskId: 1,
      catalogItemId: 1,
      quantity: '1',
      movement: 'INSTALLED',
      note: null,
      recordedAt: null,
    ).toJson(),
    'PresignIn': PresignBody(
      taskId: 1,
      kind: 'PHOTO',
      mimeType: 'image/jpeg',
      sizeBytes: 1,
      takenAt: now,
      latitude: null,
      longitude: null,
    ).toJson(),
    'PresignOut': PresignDto(
      uploadUrl: 'u',
      headers: const {},
      expiresAt: now,
      alreadyUploaded: false,
    ).toJson(),
    'CompletionIn': CompletionBody(
      completedAt: now,
      completionLocationCheckId: null,
      reportedWorkSeconds: 0,
      reportedBreakSeconds: 0,
      photoIds: const [],
      comment: null,
    ).toJson(),
  };

  for (final MapEntry(key: schema, value: json) in samples.entries) {
    test('$schema matches openapi.json', () {
      expect(json.keys.toSet(), fieldsOf(schema));
    });
  }
}
