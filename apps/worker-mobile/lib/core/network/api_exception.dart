/// Error raised by [ApiClient] for every failed request.
///
/// Repositories catch it and convert it to domain failures; the UI never sees
/// raw Dio errors or stack traces.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details = const {},
  });

  /// Client-side codes (the server's codes come from the error envelope).
  static const networkError = 'NETWORK_ERROR';
  static const timeout = 'TIMEOUT';
  static const unknownError = 'UNKNOWN_ERROR';

  /// Stable error code, e.g. `WORKER_ALREADY_BOOKED` or [networkError].
  final String code;
  final String message;

  /// HTTP status, or null when the server was never reached.
  final int? statusCode;
  final Map<String, dynamic> details;

  /// True when retrying later may succeed (outbox keeps the item pending).
  bool get isRetryable =>
      statusCode == null || statusCode! >= 500 || statusCode == 429;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
