import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/api/http_nest_api.dart';
import 'package:nest_worker/core/api/nest_api.dart';
import 'package:nest_worker/core/network/api_client.dart';
import 'package:nest_worker/core/network/api_exception.dart';
import 'package:nest_worker/core/storage/token_storage.dart';
import 'package:nest_worker/core/time/clock.dart';
import 'package:nest_worker/features/completion/domain/completion_models.dart';
import 'package:nest_worker/features/notifications/domain/app_notification.dart';
import 'package:nest_worker/features/tasks/domain/task.dart';
import 'package:nest_worker/features/work/domain/location_check.dart';
import 'package:nest_worker/features/work/domain/time_entry.dart';

class _Request {
  _Request(this.options, this.body);
  final RequestOptions options;
  final Object? body;
  String get key => '${options.method} ${options.uri.path}';
  String? get auth => options.headers['Authorization'] as String?;
}

typedef _Handler = (int, Object?) Function(_Request request);

/// Routes "METHOD /path" to canned responses and records every request.
class _Server implements HttpClientAdapter {
  final routes = <String, _Handler>{};
  final requests = <_Request>[];

  void on(String key, int status, [Object? body]) =>
      routes[key] = (_) => (status, body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Object? body;
    if (requestStream != null) {
      final bytes = await requestStream.fold<List<int>>(
        [],
        (a, b) => a..addAll(b),
      );
      final text = utf8.decode(bytes, allowMalformed: true);
      body = options.headers['content-type'] == 'image/jpeg'
          ? bytes.length
          : _tryJson(text);
    }
    final request = _Request(options, body);
    requests.add(request);
    final handler = routes[request.key];
    if (handler == null) {
      return ResponseBody.fromString('not routed: ${request.key}', 599);
    }
    final (status, response) = handler(request);
    return ResponseBody.fromString(
      response == null ? '' : jsonEncode(response),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  static Object? _tryJson(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return text;
    }
  }

  @override
  void close({bool force = false}) {}
}

class _MemoryTokens implements TokenStorage {
  _MemoryTokens([this.tokens]);
  StoredTokens? tokens;
  @override
  Future<void> clear() async => tokens = null;
  @override
  Future<StoredTokens?> read() async => tokens;
  @override
  Future<void> write(StoredTokens t) async => tokens = t;
}

Map<String, dynamic> _error(String code) => {
  'error': {'code': code, 'message': code, 'details': <String, dynamic>{}},
};

final _taskJson = {
  'id': 812,
  'job_id': 12,
  'visit_id': 210,
  'job_type': 'INSTALLATION',
  'title': 'Install Safety Net – Building A',
  'project_name': 'Davtashen Residential',
  'customer_name': 'Arm Build LLC',
  'instructions': '',
  'site_name': 'Building A',
  'address': 'Davtashen 3rd district, Yerevan',
  'latitude': 40.2262,
  'longitude': 44.493,
  'geofence_radius_m': null,
  'access_notes': 'Gate 2',
  'site_contact_name': null,
  'site_contact_phone': null,
  'scheduled_start': '2026-10-14T05:00:00Z',
  'scheduled_end': '2026-10-14T13:00:00Z',
  'role': 'LEAD',
  'status': 'IN_PROGRESS',
  'crew': [
    {'worker_id': 7, 'full_name': 'Arman H', 'role': 'LEAD', 'phone': '+374'},
    {
      'worker_id': 11,
      'full_name': 'David S',
      'role': 'MEMBER',
      'phone': '+374',
    },
  ],
};

void main() {
  late _Server server;
  late _MemoryTokens tokens;
  late ApiClient client;
  late HttpNestApi api;
  var expired = 0;

  setUp(() {
    server = _Server();
    tokens = _MemoryTokens(
      const StoredTokens(accessToken: 'old-access', refreshToken: 'refresh-1'),
    );
    expired = 0;
    client = ApiClient(
      baseUrl: 'http://api.test',
      clock: FixedClock(DateTime.utc(2026, 10, 14, 9)),
      dio: Dio()..httpClientAdapter = server,
      tokens: tokens,
      onSessionExpired: () => expired++,
    );
    api = HttpNestApi(client, uploadDio: Dio()..httpClientAdapter = server);
  });

  test('maps tasks to the domain model (ids as strings, enums, UTC)', () async {
    server.on('GET /api/v1/worker/tasks', 200, [_taskJson]);

    final [task] = await api.tasks(
      from: DateTime.utc(2026, 10, 7),
      to: DateTime.utc(2026, 10, 29),
    );

    final sent = server.requests.single.options;
    expect(sent.queryParameters['from'], '2026-10-07T00:00:00.000Z');
    expect(sent.headers['Authorization'], 'Bearer old-access');
    expect(task.id, '812');
    expect(task.jobType, JobType.installation);
    expect(task.role, TaskRole.lead);
    expect(task.serverStatus, ServerTaskStatus.inProgress);
    expect(task.geofenceRadiusM, isNull);
    expect(task.scheduledStart, DateTime.utc(2026, 10, 14, 5));
    expect(task.crew.map((c) => (c.workerId, c.role)), [
      ('7', TaskRole.lead),
      ('11', TaskRole.member),
    ]);
  });

  test('registers the push token with platform and app version', () async {
    // FCM tokens contain ':' — it must survive as one path segment
    server.on('PUT /api/v1/worker/devices/abc%3AAPA91b-token', 204);

    await api.registerDevice(
      token: 'abc:APA91b-token',
      platform: 'android',
      appVersion: '1.0.0',
    );

    final sent = server.requests.single;
    expect(sent.body, {'platform': 'android', 'app_version': '1.0.0'});
  });

  test('writes send ints, upper-case enums and UTC timestamps', () async {
    server.on('PUT /api/v1/worker/location-checks/c-1', 200, {});
    server.on('PUT /api/v1/worker/time-entries/t-1', 200, {});
    server.on('PUT /api/v1/worker/material-movements/m-1', 200, {});
    // A local (non-UTC) time must still reach the server with a zone.
    final local = DateTime(2026, 10, 14, 13, 5);

    await api.putLocationCheck(
      LocationCheck(
        id: 'c-1',
        taskId: '812',
        purpose: LocationCheckPurpose.start,
        latitude: 40.2265,
        longitude: 44.4932,
        accuracyM: 8,
        isMocked: false,
        capturedAt: local,
        distanceM: 38,
        radiusM: 150,
        verified: true,
      ),
    );
    await api.putTimeEntry(
      TimeEntry(
        id: 't-1',
        taskId: '812',
        kind: TimeEntryKind.breakTime,
        startedAt: local,
      ),
    );
    await api.putMaterial(
      const MaterialEntry(
        id: 'm-1',
        taskId: '812',
        catalogItemId: '2',
        itemName: 'Net',
        unit: 'm2',
        quantity: 420,
        movement: MaterialMovement.installed,
      ),
    );

    final [check, entry, material] = server.requests
        .map((r) => r.body! as Map)
        .toList();
    expect(check['task_id'], 812);
    expect(check['purpose'], 'START');
    expect(check['captured_at'], local.toUtc().toIso8601String());
    expect((check['captured_at'] as String).endsWith('Z'), isTrue);
    expect(entry['kind'], 'BREAK');
    expect(entry['ended_at'], isNull);
    expect(material['catalog_item_id'], 2);
    expect(material['quantity'], '420');
    expect(material['movement'], 'INSTALLED');
  });

  test(
    'an expired access token is refreshed once and the request retried',
    () async {
      var calls = 0;
      server.routes['GET /api/v1/worker/config'] = (r) {
        calls++;
        return r.auth == 'Bearer new-access'
            ? (
                200,
                {
                  'default_geofence_radius_m': 150,
                  'max_location_accuracy_m': 100,
                  'min_completion_photos': 2,
                  'start_window_minutes_before': 120,
                  'min_supported_app_version': '1.0.0',
                  'telegram_bot_username': null,
                },
              )
            : (401, _error('TOKEN_EXPIRED'));
      };
      server.routes['POST /api/v1/auth/refresh'] = (r) {
        expect((r.body! as Map)['refresh_token'], 'refresh-1');
        return (
          200,
          {
            'access_token': 'new-access',
            'refresh_token': 'refresh-2',
            'token_type': 'bearer',
            'expires_in': 900,
          },
        );
      };

      final config = await api.config();

      expect(config.minCompletionPhotos, 2);
      expect(calls, 2);
      expect(tokens.tokens!.refreshToken, 'refresh-2');
      expect(expired, 0);
    },
  );

  test('a rejected refresh ends the session; offline does not', () async {
    server.on('GET /api/v1/worker/config', 401, _error('TOKEN_EXPIRED'));
    server.on('POST /api/v1/auth/refresh', 401, _error('REFRESH_TOKEN_REUSED'));

    await expectLater(api.config(), throwsA(isA<ApiException>()));

    expect(expired, 1);
    expect(tokens.tokens, isNull);
  });

  test('login maps the user; a manager account is refused', () async {
    Map<String, dynamic> login(Map<String, dynamic>? worker) => {
      'access_token': 'a',
      'refresh_token': 'r',
      'token_type': 'bearer',
      'expires_in': 900,
      'user': {
        'id': 3,
        'phone': '+37491000007',
        'email': null,
        'first_name': 'Arman',
        'last_name': 'H',
        'full_name': 'Arman H',
        'role': worker == null ? 'MANAGER' : 'WORKER',
        'locale': 'hi',
        'must_change_password': true,
        'worker': worker,
      },
    };
    server.on(
      'POST /api/v1/auth/login',
      200,
      login({'id': 7, 'employee_code': 'NEST-007'}),
    );

    final result = await api.login(phone: '+37491000007', password: 'x');

    expect(server.requests.single.auth, isNull, reason: 'no token on login');
    expect(result.worker.id, '7');
    expect(result.worker.locale, 'hi');
    expect(result.worker.mustChangePassword, isTrue);

    server.on('POST /api/v1/auth/login', 200, login(null));
    await expectLater(
      api.login(phone: 'x', password: 'x'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'NOT_A_WORKER'),
      ),
    );
  });

  test('earnings keep the amount as a decimal string; unknown notifications are skipped', () async {
    server.on('GET /api/v1/worker/earnings', 200, {
      'month': '2026-10',
      'approved_tasks': 3,
      'approved_amount': '80000.00',
      'currency': 'AMD',
    });
    server.on('GET /api/v1/worker/notifications', 200, {
      'items': [
        {
          'id': 5,
          'type': 'TASK_ASSIGNED',
          'title': 't',
          'body': 'b',
          'task_id': 812,
          'created_at': '2026-10-14T05:00:00Z',
          'read_at': null,
        },
        {
          'id': 6,
          'type': 'SOMETHING_NEW',
          'title': 't',
          'body': 'b',
          'task_id': null,
          'created_at': '2026-10-14T05:00:00Z',
          'read_at': null,
        },
      ],
      'next_cursor': null,
    });

    final earnings = await api.earnings(year: 2026, month: 10);
    final notifications = await api.notifications();

    expect(server.requests.first.options.queryParameters['month'], '2026-10');
    expect(earnings.approvedAmount, '80000.00');
    expect(notifications.map((n) => (n.id, n.type, n.taskId)), [
      ('5', NotificationType.taskAssigned, '812'),
    ]);
  });

  test(
    'photos: presign, then PUT the bytes with the signed headers only',
    () async {
      final dir = await Directory.systemTemp.createTemp('nest_photo');
      final file = File('${dir.path}/p.jpg')
        ..writeAsBytesSync(List.filled(2048, 7));
      server.on('POST /api/v1/worker/files/ph-1/presign', 200, {
        'upload_url': 'http://storage.test/nest-files/assignments/812/ph-1.jpg?X-Amz-Signature=s',
        'headers': {'Content-Type': 'image/jpeg'},
        'expires_at': '2026-10-14T10:00:00Z',
        'already_uploaded': false,
      });
      server.on('PUT /nest-files/assignments/812/ph-1.jpg', 200);
      final progress = <double>[];

      final target = await api.presignPhoto(
        TaskPhoto(
          id: 'ph-1',
          taskId: '812',
          localPath: file.path,
          takenAt: DateTime.utc(2026),
        ),
      );
      await api.uploadPhoto(target, file.path, onProgress: progress.add);

      final [presign, put] = server.requests;
      expect((presign.body! as Map)['size_bytes'], 2048);
      expect(put.auth, isNull, reason: 'storage must not get our bearer token');
      expect(put.options.headers['content-type'], 'image/jpeg');
      expect(put.body, 2048);
      expect(progress.last, 1.0);
      await dir.delete(recursive: true);
    },
  );

  test(
    'a storage failure is retryable (a fresh URL is presigned next time)',
    () async {
      final dir = await Directory.systemTemp.createTemp('nest_photo');
      final file = File('${dir.path}/p.jpg')..writeAsBytesSync([1, 2, 3]);
      server.on('PUT /expired', 403, 'AccessDenied');

      await expectLater(
        api.uploadPhoto(
          PhotoUploadTarget(url: Uri.parse('http://storage.test/expired')),
          file.path,
        ),
        throwsA(
          isA<ApiException>().having((e) => e.isRetryable, 'retryable', isTrue),
        ),
      );
      await dir.delete(recursive: true);
    },
  );
}
