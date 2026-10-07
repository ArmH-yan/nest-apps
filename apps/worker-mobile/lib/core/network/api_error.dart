import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';
part 'api_error.g.dart';

/// The backend's error envelope: `{"error": {"code", "message", "details"}}`
/// (ARCHITECTURE §32). `code` is stable and is mapped to localized text in the UI.
@freezed
abstract class ApiErrorEnvelope with _$ApiErrorEnvelope {
  const factory ApiErrorEnvelope({required ApiErrorBody error}) =
      _ApiErrorEnvelope;

  factory ApiErrorEnvelope.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorEnvelopeFromJson(json);
}

@freezed
abstract class ApiErrorBody with _$ApiErrorBody {
  const factory ApiErrorBody({
    required String code,
    required String message,
    @Default(<String, dynamic>{}) Map<String, dynamic> details,
  }) = _ApiErrorBody;

  factory ApiErrorBody.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorBodyFromJson(json);
}
