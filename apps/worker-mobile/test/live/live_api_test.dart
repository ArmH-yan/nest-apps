@Tags(['live'])
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/api/http_nest_api.dart';
import 'package:nest_worker/core/network/api_client.dart';
import 'package:nest_worker/core/network/api_exception.dart';
import 'package:nest_worker/core/storage/token_storage.dart';
import 'package:nest_worker/core/time/clock.dart';
import 'package:nest_worker/features/completion/domain/completion_models.dart';
import 'package:nest_worker/features/notifications/domain/app_notification.dart';
import 'package:nest_worker/features/tasks/domain/task.dart';
import 'package:nest_worker/features/work/domain/location_check.dart';
import 'package:nest_worker/features/work/domain/time_entry.dart';
import 'package:uuid/uuid.dart';

/// The worker workflow through the real HttpNestApi against a running API with
/// the demo seed (Phase 2d). Skipped unless LIVE_API_URL is set:
///
///   python -m app.cli seed-demo --reset
///   S3_PUBLIC_ENDPOINT_URL=http://127.0.0.1:9000 uvicorn app.main:app --port 8000
///   LIVE_API_URL=http://127.0.0.1:8000 flutter test test/live
class _MemoryTokens implements TokenStorage {
  StoredTokens? tokens;
  @override
  Future<void> clear() async => tokens = null;
  @override
  Future<StoredTokens?> read() async => tokens;
  @override
  Future<void> write(StoredTokens t) async => tokens = t;
}

void main() {
  final baseUrl = Platform.environment['LIVE_API_URL'];
  const uuid = Uuid();

  test(
    'Arman: login → tasks → GPS → work/break → materials → photo → submit',
    () async {
      final tokens = _MemoryTokens();
      final api = HttpNestApi(
        ApiClient(
          baseUrl: baseUrl!,
          clock: const SystemClock(),
          tokens: tokens,
        ),
        uploadDio: Dio(),
      );

      // login (AuthRepository stores the tokens; here we do it by hand)
      final login = await api.login(
        phone: '+37491000007',
        password: 'nest1234',
      );
      await tokens.write(
        StoredTokens(
          accessToken: login.accessToken,
          refreshToken: login.refreshToken,
        ),
      );
      expect(login.worker.fullName, 'Arman Harutyunyan');
      expect((await api.me()).employeeCode, 'NEST-007');
      final config = await api.config();
      expect(config.defaultGeofenceRadiusM, 150);

      final now = DateTime.now().toUtc();
      final tasks = await api.tasks(
        from: now.subtract(const Duration(days: 2)),
        to: now.add(const Duration(days: 5)),
      );
      final task = tasks.firstWhere((t) => t.title.contains('Building A'));
      expect(task.role, TaskRole.lead);
      expect(task.crew, hasLength(3));
      expect(task.customerName, 'Arm Build LLC');
      final catalog = await api.catalog();
      final net = catalog.firstWhere((c) => c.unit == 'm2');

      // GPS at the site pin, then work 3h, break 30m, work again
      final start = task.scheduledStart;
      final check = LocationCheck(
        id: uuid.v4(),
        taskId: task.id,
        purpose: LocationCheckPurpose.start,
        latitude: task.latitude + 0.0002,
        longitude: task.longitude,
        accuracyM: 6,
        isMocked: false,
        capturedAt: start,
        distanceM: 22,
        radiusM: 150,
        verified: true,
      );
      await api.putLocationCheck(check);
      await api.putLocationCheck(check); // outbox replay → still fine
      final work1 = TimeEntry(
        id: uuid.v4(),
        taskId: task.id,
        kind: TimeEntryKind.work,
        startedAt: start,
        startLocationCheckId: check.id,
      );
      await api.putTimeEntry(work1);
      await api.putTimeEntry(
        work1.copyWith(endedAt: start.add(const Duration(hours: 3))),
      );
      await api.putTimeEntry(
        TimeEntry(
          id: uuid.v4(),
          taskId: task.id,
          kind: TimeEntryKind.breakTime,
          startedAt: start.add(const Duration(hours: 3)),
          endedAt: start.add(const Duration(hours: 3, minutes: 30)),
        ),
      );
      final work2 = TimeEntry(
        id: uuid.v4(),
        taskId: task.id,
        kind: TimeEntryKind.work,
        startedAt: start.add(const Duration(hours: 3, minutes: 30)),
        endedAt: start.add(const Duration(hours: 4, minutes: 30)),
      );
      await api.putTimeEntry(work2);

      // a conflicting change to a closed entry is refused with a stable code
      await expectLater(
        api.putTimeEntry(
          work2.copyWith(endedAt: start.add(const Duration(hours: 5))),
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'TIME_ENTRY_FINALIZED',
          ),
        ),
      );

      await api.putMaterial(
        MaterialEntry(
          id: uuid.v4(),
          taskId: task.id,
          catalogItemId: net.id,
          itemName: net.name,
          unit: net.unit,
          quantity: 420,
          movement: MaterialMovement.installed,
        ),
      );

      // photo: presign → PUT to real storage → confirm
      final dir = await Directory.systemTemp.createTemp('nest_live');
      final file = File('${dir.path}/after.jpg')
        ..writeAsBytesSync([0xFF, 0xD8, ...List.filled(4000, 1), 0xFF, 0xD9]);
      final photo = TaskPhoto(
        id: uuid.v4(),
        taskId: task.id,
        localPath: file.path,
        takenAt: start.add(const Duration(hours: 4)),
      );
      final target = await api.presignPhoto(photo);
      final progress = <double>[];
      await api.uploadPhoto(target, file.path, onProgress: progress.add);
      await api.confirmPhoto(photo.id);
      expect((await api.presignPhoto(photo)).alreadyUploaded, isTrue);
      expect(progress.last, 1.0);

      final completion = TaskCompletion(
        id: uuid.v4(),
        taskId: task.id,
        workerId: login.worker.id,
        completedAt: start.add(const Duration(hours: 4, minutes: 30)),
        timeEntries: const [],
        totalWorkDuration: const Duration(hours: 4),
        totalBreakDuration: const Duration(minutes: 30),
        photoIds: [photo.id],
        materials: const [],
        comment: 'Live test',
      );
      await api.putCompletion(completion);
      await api.putCompletion(completion); // replay

      final after = await api.tasks(
        from: now.subtract(const Duration(days: 2)),
        to: now.add(const Duration(days: 5)),
      );
      expect(
        after.firstWhere((t) => t.id == task.id).serverStatus,
        ServerTaskStatus.submitted,
      );
      final notifications = await api.notifications();
      expect(notifications.first.type, NotificationType.submissionAccepted);
      final earnings = await api.earnings(year: now.year, month: now.month);
      expect(earnings.currency, 'AMD');

      await api.logout();
      await expectLater(api.me(), throwsA(isA<ApiException>()));
      await dir.delete(recursive: true);
    },
    skip: baseUrl == null
        ? 'set LIVE_API_URL to run against a real API'
        : false,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
