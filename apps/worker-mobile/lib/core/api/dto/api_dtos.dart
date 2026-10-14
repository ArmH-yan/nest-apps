import 'package:json_annotation/json_annotation.dart';

part 'api_dtos.g.dart';

// Wire format of the NEST API (ARCHITECTURE §18, §40). Each class mirrors one
// schema in apps/api/openapi.json field for field; test/core/api/contract_test.dart
// fails when they drift apart. Domain models never use these directly:
// HttpNestApi maps them (WORKER_APP_SPEC "As built").

const _dto = JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
);

// --- auth ---------------------------------------------------------------------

/// `LoginRequest`
@_dto
class LoginRequestDto {
  const LoginRequestDto({
    required this.phone,
    required this.password,
    this.email,
    this.deviceId,
  });
  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);
  final String? phone;
  final String? email;
  final String password;
  final String? deviceId;
  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}

/// `WorkerInfo`
@_dto
class WorkerInfoDto {
  const WorkerInfoDto({required this.id, required this.employeeCode});
  factory WorkerInfoDto.fromJson(Map<String, dynamic> json) =>
      _$WorkerInfoDtoFromJson(json);
  final int id;
  final String employeeCode;
  Map<String, dynamic> toJson() => _$WorkerInfoDtoToJson(this);
}

/// `MeResponse`
@_dto
class MeDto {
  const MeDto({
    required this.id,
    required this.phone,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    required this.locale,
    required this.mustChangePassword,
    required this.worker,
  });
  factory MeDto.fromJson(Map<String, dynamic> json) => _$MeDtoFromJson(json);
  final int id;
  final String phone;
  final String? email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String role;
  final String locale;
  final bool mustChangePassword;
  final WorkerInfoDto? worker;
  Map<String, dynamic> toJson() => _$MeDtoToJson(this);
}

/// `LoginResponse`
@_dto
class LoginResponseDto {
  const LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });
  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final MeDto user;
  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}

/// `TokenResponse` (`POST /auth/refresh`)
@_dto
class TokenResponseDto {
  const TokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });
  factory TokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseDtoFromJson(json);
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  Map<String, dynamic> toJson() => _$TokenResponseDtoToJson(this);
}

// --- reads --------------------------------------------------------------------

/// `WorkerConfigOut`
@_dto
class WorkerConfigDto {
  const WorkerConfigDto({
    required this.defaultGeofenceRadiusM,
    required this.maxLocationAccuracyM,
    required this.minCompletionPhotos,
    required this.startWindowMinutesBefore,
    required this.minSupportedAppVersion,
    required this.telegramBotUsername,
  });
  factory WorkerConfigDto.fromJson(Map<String, dynamic> json) =>
      _$WorkerConfigDtoFromJson(json);
  final int defaultGeofenceRadiusM;
  final int maxLocationAccuracyM;
  final int minCompletionPhotos;
  final int startWindowMinutesBefore;
  final String minSupportedAppVersion;
  final String? telegramBotUsername;
  Map<String, dynamic> toJson() => _$WorkerConfigDtoToJson(this);
}

/// `CrewMateOut`
@_dto
class CrewMateDto {
  const CrewMateDto({
    required this.workerId,
    required this.fullName,
    required this.role,
    required this.phone,
  });
  factory CrewMateDto.fromJson(Map<String, dynamic> json) =>
      _$CrewMateDtoFromJson(json);
  final int workerId;
  final String fullName;
  final String role;
  final String phone;
  Map<String, dynamic> toJson() => _$CrewMateDtoToJson(this);
}

/// `TaskOut`
@_dto
class TaskDto {
  const TaskDto({
    required this.id,
    required this.jobId,
    required this.visitId,
    required this.jobType,
    required this.title,
    required this.projectName,
    required this.customerName,
    required this.instructions,
    required this.siteName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.geofenceRadiusM,
    required this.accessNotes,
    required this.siteContactName,
    required this.siteContactPhone,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.role,
    required this.status,
    required this.crew,
  });
  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);
  final int id;
  final int jobId;
  final int visitId;
  final String jobType;
  final String title;
  final String projectName;
  final String customerName;
  final String instructions;
  final String siteName;
  final String address;
  final double latitude;
  final double longitude;
  final int? geofenceRadiusM;
  final String accessNotes;
  final String? siteContactName;
  final String? siteContactPhone;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String role;
  final String status;
  final List<CrewMateDto> crew;
  Map<String, dynamic> toJson() => _$TaskDtoToJson(this);
}

/// `CatalogItemOut`
@_dto
class CatalogItemDto {
  const CatalogItemDto({
    required this.id,
    required this.name,
    required this.unit,
  });
  factory CatalogItemDto.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemDtoFromJson(json);
  final int id;
  final String name;
  final String unit;
  Map<String, dynamic> toJson() => _$CatalogItemDtoToJson(this);
}

/// `ExpectedMaterialOut`. Quantities are decimal strings ("400.000").
@_dto
class ExpectedMaterialDto {
  const ExpectedMaterialDto({required this.item, required this.quantity});
  factory ExpectedMaterialDto.fromJson(Map<String, dynamic> json) =>
      _$ExpectedMaterialDtoFromJson(json);
  final CatalogItemDto item;
  final String quantity;
  Map<String, dynamic> toJson() => _$ExpectedMaterialDtoToJson(this);
}

/// `EarningsOut`. The amount is a decimal string ("80000.00"), never a double.
@_dto
class EarningsDto {
  const EarningsDto({
    required this.month,
    required this.approvedTasks,
    required this.approvedAmount,
    required this.currency,
  });
  factory EarningsDto.fromJson(Map<String, dynamic> json) =>
      _$EarningsDtoFromJson(json);
  final String month;
  final int approvedTasks;
  final String approvedAmount;
  final String currency;
  Map<String, dynamic> toJson() => _$EarningsDtoToJson(this);
}

/// `NotificationOut`
@_dto
class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.taskId,
    required this.createdAt,
    required this.readAt,
  });
  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);
  final int id;
  final String type;
  final String title;
  final String body;
  final int? taskId;
  final DateTime createdAt;
  final DateTime? readAt;
  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);
}

/// `NotificationPageOut`
@_dto
class NotificationPageDto {
  const NotificationPageDto({required this.items, required this.nextCursor});
  factory NotificationPageDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationPageDtoFromJson(json);
  final List<NotificationDto> items;
  final int? nextCursor;
  Map<String, dynamic> toJson() => _$NotificationPageDtoToJson(this);
}

// --- writes -------------------------------------------------------------------

/// `LocationCheckIn` (`PUT /worker/location-checks/{uuid}`)
@_dto
class LocationCheckBody {
  const LocationCheckBody({
    required this.taskId,
    required this.purpose,
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
    required this.isMocked,
    required this.capturedAt,
    required this.distanceM,
    required this.radiusM,
    required this.verified,
  });
  factory LocationCheckBody.fromJson(Map<String, dynamic> json) =>
      _$LocationCheckBodyFromJson(json);
  final int taskId;
  final String purpose;
  final double latitude;
  final double longitude;
  final double accuracyM;
  final bool isMocked;
  final DateTime capturedAt;
  final double distanceM;
  final double radiusM;
  final bool verified;
  Map<String, dynamic> toJson() => _$LocationCheckBodyToJson(this);
}

/// `TimeEntryIn` (`PUT /worker/time-entries/{uuid}`)
@_dto
class TimeEntryBody {
  const TimeEntryBody({
    required this.taskId,
    required this.kind,
    required this.startedAt,
    required this.endedAt,
    required this.startLocationCheckId,
  });
  factory TimeEntryBody.fromJson(Map<String, dynamic> json) =>
      _$TimeEntryBodyFromJson(json);
  final int taskId;
  final String kind;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? startLocationCheckId;
  Map<String, dynamic> toJson() => _$TimeEntryBodyToJson(this);
}

/// `MaterialMovementIn` (`PUT /worker/material-movements/{uuid}`)
@_dto
class MaterialMovementBody {
  const MaterialMovementBody({
    required this.taskId,
    required this.catalogItemId,
    required this.quantity,
    required this.movement,
    required this.note,
    required this.recordedAt,
  });
  factory MaterialMovementBody.fromJson(Map<String, dynamic> json) =>
      _$MaterialMovementBodyFromJson(json);
  final int taskId;
  final int catalogItemId;

  /// Decimal string, e.g. "420" (the server stores numeric(12,3)).
  final String quantity;
  final String movement;
  final String? note;
  final DateTime? recordedAt;
  Map<String, dynamic> toJson() => _$MaterialMovementBodyToJson(this);
}

/// `PresignIn` (`POST /worker/files/{uuid}/presign`)
@_dto
class PresignBody {
  const PresignBody({
    required this.taskId,
    required this.kind,
    required this.mimeType,
    required this.sizeBytes,
    required this.takenAt,
    required this.latitude,
    required this.longitude,
  });
  factory PresignBody.fromJson(Map<String, dynamic> json) =>
      _$PresignBodyFromJson(json);
  final int taskId;
  final String kind;
  final String mimeType;
  final int sizeBytes;
  final DateTime? takenAt;
  final double? latitude;
  final double? longitude;
  Map<String, dynamic> toJson() => _$PresignBodyToJson(this);
}

/// `PresignOut`
@_dto
class PresignDto {
  const PresignDto({
    required this.uploadUrl,
    required this.headers,
    required this.expiresAt,
    required this.alreadyUploaded,
  });
  factory PresignDto.fromJson(Map<String, dynamic> json) =>
      _$PresignDtoFromJson(json);
  final String uploadUrl;
  final Map<String, String> headers;
  final DateTime expiresAt;
  final bool alreadyUploaded;
  Map<String, dynamic> toJson() => _$PresignDtoToJson(this);
}

/// `CompletionIn` (`PUT /worker/tasks/{id}/completion/{uuid}`)
@_dto
class CompletionBody {
  const CompletionBody({
    required this.completedAt,
    required this.completionLocationCheckId,
    required this.reportedWorkSeconds,
    required this.reportedBreakSeconds,
    required this.photoIds,
    required this.comment,
  });
  factory CompletionBody.fromJson(Map<String, dynamic> json) =>
      _$CompletionBodyFromJson(json);
  final DateTime completedAt;
  final String? completionLocationCheckId;
  final int reportedWorkSeconds;
  final int reportedBreakSeconds;
  final List<String> photoIds;
  final String? comment;
  Map<String, dynamic> toJson() => _$CompletionBodyToJson(this);
}
