import 'package:dio/dio.dart';

import '../time/clock.dart';
import 'api_error.dart';
import 'api_exception.dart';

/// The only place that talks HTTP. Api* repositories use it; widgets never do.
///
/// Auth (bearer token + refresh) is added with the auth feature.
class ApiClient {
  ApiClient({required String baseUrl, required Clock clock, Dio? dio})
    : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers['Accept'] = 'application/json';
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Lets the server measure device clock skew (ARCHITECTURE §18).
          options.headers['X-Device-Time'] = clock.now().toIso8601String();
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  Dio get dio => _dio;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) =>
      _send(() => _dio.get<Map<String, dynamic>>(path, queryParameters: query));

  Future<Map<String, dynamic>> putJson(String path, Object body) =>
      _send(() => _dio.put<Map<String, dynamic>>(path, data: body));

  Future<Map<String, dynamic>> postJson(String path, Object? body) =>
      _send(() => _dio.post<Map<String, dynamic>>(path, data: body));

  Future<Map<String, dynamic>> _send(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return response.data ?? const {};
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

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
