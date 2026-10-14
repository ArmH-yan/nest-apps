import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import '../time/clock.dart';
import 'api_error.dart';
import 'api_exception.dart';

/// The only place that talks HTTP. `HttpNestApi` uses it; widgets never do.
///
/// - Sends `X-Device-Time` so the server can measure clock skew (§18).
/// - Sends the access token and, when the server answers 401, refreshes it once
///   (one refresh at a time, shared by all waiting requests) and retries.
/// - If the server rejects the refresh token, the session is over: tokens are
///   cleared and [onSessionExpired] runs (the app shows the login screen).
///   Being offline is not a rejection; the session stays.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required Clock clock,
    Dio? dio,
    TokenStorage? tokens,
    this.onSessionExpired,
  }) : _dio = dio ?? Dio(),
       _tokens = tokens {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers['Accept'] = 'application/json';
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['X-Device-Time'] = clock
              .now()
              .toUtc()
              .toIso8601String();
          final stored = _usesAuth(options) ? await _tokens?.read() : null;
          if (stored != null) {
            options.headers['Authorization'] = 'Bearer ${stored.accessToken}';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final options = error.requestOptions;
          final retried = options.extra[_retriedKey] == true;
          if (error.response?.statusCode != 401 ||
              _tokens == null ||
              !_usesAuth(options) ||
              retried) {
            handler.next(error);
            return;
          }
          final outcome = await _refreshOnce();
          if (outcome != _Refresh.ok) {
            if (outcome == _Refresh.rejected) onSessionExpired?.call();
            handler.next(error);
            return;
          }
          try {
            options.extra[_retriedKey] = true;
            handler.resolve(await _dio.fetch<Object?>(options));
          } on DioException catch (e) {
            handler.next(e);
          }
        },
      ),
    );
  }

  static const _retriedKey = 'nest.retried';
  static const refreshPath = '/api/v1/auth/refresh';
  static const _noAuthPaths = {'/api/v1/auth/login', refreshPath};

  final Dio _dio;
  final TokenStorage? _tokens;

  /// Called when the server rejects the refresh token (signed out elsewhere,
  /// deactivated, or the token was reused).
  void Function()? onSessionExpired;

  Future<_Refresh>? _refreshing;

  Dio get dio => _dio;

  bool _usesAuth(RequestOptions options) =>
      !_noAuthPaths.contains(options.path);

  Future<_Refresh> _refreshOnce() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  Future<_Refresh> _refresh() async {
    final stored = await _tokens!.read();
    if (stored == null) return _Refresh.rejected;
    try {
      // No interceptors, so a 401 here can't recurse. Same transport as _dio.
      final bare = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: _dio.options.connectTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
        ),
      )..httpClientAdapter = _dio.httpClientAdapter;
      final response = await bare.post<Map<String, dynamic>>(
        refreshPath,
        data: {'refresh_token': stored.refreshToken},
      );
      final data = response.data!;
      await _tokens.write(
        StoredTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
        ),
      );
      return _Refresh.ok;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _tokens.clear();
        return _Refresh.rejected;
      }
      return _Refresh.unavailable;
    }
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async => _asMap(
    await _send(() => _dio.get<Object?>(path, queryParameters: query)),
  );

  Future<List<Object?>> getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final data = await _send(
      () => _dio.get<Object?>(path, queryParameters: query),
    );
    if (data is List<Object?>) return data;
    throw _unexpected();
  }

  Future<Map<String, dynamic>> putJson(String path, Object body) async =>
      _asMap(await _send(() => _dio.put<Object?>(path, data: body)));

  Future<Map<String, dynamic>> postJson(String path, Object? body) async =>
      _asMap(await _send(() => _dio.post<Object?>(path, data: body)));

  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    try {
      return (await request()).data;
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data == null || data == '') return const {}; // 204 No Content
    if (data is Map<String, dynamic>) return data;
    throw _unexpected();
  }

  static ApiException _unexpected() => const ApiException(
    code: ApiException.unknownError,
    message: 'Unexpected server response.',
  );

  /// Maps any Dio failure to an [ApiException] using the server's envelope
  /// when present.
  static ApiException toApiException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          code: ApiException.timeout,
          message: 'The server did not respond in time.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          code: ApiException.networkError,
          message: 'No connection to the server.',
        );
      default:
        break;
    }
    final response = e.response;
    final data = response?.data;
    if (data is Map<String, dynamic> && data['error'] is Map) {
      try {
        final envelope = ApiErrorEnvelope.fromJson(data);
        return ApiException(
          code: envelope.error.code,
          message: envelope.error.message,
          statusCode: response?.statusCode,
          details: envelope.error.details,
        );
      } on Object {
        // fall through to the generic error below
      }
    }
    return ApiException(
      code: ApiException.unknownError,
      message: 'Unexpected server response.',
      statusCode: response?.statusCode,
    );
  }
}

enum _Refresh { ok, rejected, unavailable }
