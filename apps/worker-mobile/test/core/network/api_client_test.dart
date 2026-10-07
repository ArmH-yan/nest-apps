import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/network/api_client.dart';
import 'package:nest_worker/core/network/api_exception.dart';
import 'package:nest_worker/core/time/clock.dart';

/// Answers every request with a canned response and records what was sent.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.status = 200, this.body = const {}, this.throwError});

  final int status;
  final Object body;
  final DioExceptionType? throwError;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (throwError != null) {
      throw DioException(requestOptions: options, type: throwError!);
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient _client(_FakeAdapter adapter, {Clock? clock}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return ApiClient(
    baseUrl: 'http://api.test',
    clock: clock ?? FixedClock(DateTime.utc(2026, 10, 7, 9)),
    dio: dio,
  );
}

void main() {
  test(
    'returns JSON and sends X-Device-Time from the injected clock',
    () async {
      final adapter = _FakeAdapter(body: {'status': 'ok', 'database': 'ok'});

      final json = await _client(adapter).getJson('/health');

      expect(json, {'status': 'ok', 'database': 'ok'});
      expect(adapter.lastRequest!.uri.toString(), 'http://api.test/health');
      expect(
        adapter.lastRequest!.headers['X-Device-Time'],
        '2026-10-07T09:00:00.000Z',
      );
    },
  );

  test('maps the server error envelope to ApiException', () async {
    final adapter = _FakeAdapter(
      status: 409,
      body: {
        'error': {
          'code': 'WORKER_ALREADY_BOOKED',
          'message': 'Already booked.',
          'details': {'conflicting_visit_id': 205},
        },
      },
    );

    await expectLater(
      _client(adapter).putJson('/x', {}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', 'WORKER_ALREADY_BOOKED')
            .having((e) => e.statusCode, 'statusCode', 409)
            .having((e) => e.details['conflicting_visit_id'], 'details', 205)
            .having((e) => e.isRetryable, 'isRetryable', isFalse),
      ),
    );
  });

  test(
    'non-envelope server errors become UNKNOWN_ERROR and are retryable',
    () async {
      final adapter = _FakeAdapter(status: 502, body: {'oops': true});

      await expectLater(
        _client(adapter).getJson('/x'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', ApiException.unknownError)
              .having((e) => e.isRetryable, 'isRetryable', isTrue),
        ),
      );
    },
  );

  test('connection failures become NETWORK_ERROR (retryable)', () async {
    final adapter = _FakeAdapter(throwError: DioExceptionType.connectionError);

    await expectLater(
      _client(adapter).getJson('/x'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiException.networkError)
            .having((e) => e.statusCode, 'statusCode', isNull)
            .having((e) => e.isRetryable, 'isRetryable', isTrue),
      ),
    );
  });
}
