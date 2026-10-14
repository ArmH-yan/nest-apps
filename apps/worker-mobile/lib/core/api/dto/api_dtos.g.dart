// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequestDto _$LoginRequestDtoFromJson(Map<String, dynamic> json) =>
    LoginRequestDto(
      phone: json['phone'] as String?,
      password: json['password'] as String,
      email: json['email'] as String?,
      deviceId: json['device_id'] as String?,
    );

Map<String, dynamic> _$LoginRequestDtoToJson(LoginRequestDto instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'email': instance.email,
      'password': instance.password,
      'device_id': instance.deviceId,
    };

WorkerInfoDto _$WorkerInfoDtoFromJson(Map<String, dynamic> json) =>
    WorkerInfoDto(
      id: (json['id'] as num).toInt(),
      employeeCode: json['employee_code'] as String,
    );

Map<String, dynamic> _$WorkerInfoDtoToJson(WorkerInfoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_code': instance.employeeCode,
    };

MeDto _$MeDtoFromJson(Map<String, dynamic> json) => MeDto(
  id: (json['id'] as num).toInt(),
  phone: json['phone'] as String,
  email: json['email'] as String?,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  fullName: json['full_name'] as String,
  role: json['role'] as String,
  locale: json['locale'] as String,
  mustChangePassword: json['must_change_password'] as bool,
  worker: json['worker'] == null
      ? null
      : WorkerInfoDto.fromJson(json['worker'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MeDtoToJson(MeDto instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'full_name': instance.fullName,
  'role': instance.role,
  'locale': instance.locale,
  'must_change_password': instance.mustChangePassword,
  'worker': instance.worker?.toJson(),
};

LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    LoginResponseDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      user: MeDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseDtoToJson(LoginResponseDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'user': instance.user.toJson(),
    };

TokenResponseDto _$TokenResponseDtoFromJson(Map<String, dynamic> json) =>
    TokenResponseDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$TokenResponseDtoToJson(TokenResponseDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
    };

WorkerConfigDto _$WorkerConfigDtoFromJson(Map<String, dynamic> json) =>
    WorkerConfigDto(
      defaultGeofenceRadiusM: (json['default_geofence_radius_m'] as num)
          .toInt(),
      maxLocationAccuracyM: (json['max_location_accuracy_m'] as num).toInt(),
      minCompletionPhotos: (json['min_completion_photos'] as num).toInt(),
      startWindowMinutesBefore: (json['start_window_minutes_before'] as num)
          .toInt(),
      minSupportedAppVersion: json['min_supported_app_version'] as String,
      telegramBotUsername: json['telegram_bot_username'] as String?,
    );

Map<String, dynamic> _$WorkerConfigDtoToJson(WorkerConfigDto instance) =>
    <String, dynamic>{
      'default_geofence_radius_m': instance.defaultGeofenceRadiusM,
      'max_location_accuracy_m': instance.maxLocationAccuracyM,
      'min_completion_photos': instance.minCompletionPhotos,
      'start_window_minutes_before': instance.startWindowMinutesBefore,
      'min_supported_app_version': instance.minSupportedAppVersion,
      'telegram_bot_username': instance.telegramBotUsername,
    };

CrewMateDto _$CrewMateDtoFromJson(Map<String, dynamic> json) => CrewMateDto(
  workerId: (json['worker_id'] as num).toInt(),
  fullName: json['full_name'] as String,
  role: json['role'] as String,
  phone: json['phone'] as String,
);

Map<String, dynamic> _$CrewMateDtoToJson(CrewMateDto instance) =>
    <String, dynamic>{
      'worker_id': instance.workerId,
      'full_name': instance.fullName,
      'role': instance.role,
      'phone': instance.phone,
    };

TaskDto _$TaskDtoFromJson(Map<String, dynamic> json) => TaskDto(
  id: (json['id'] as num).toInt(),
  jobId: (json['job_id'] as num).toInt(),
  visitId: (json['visit_id'] as num).toInt(),
  jobType: json['job_type'] as String,
  title: json['title'] as String,
  projectName: json['project_name'] as String,
  customerName: json['customer_name'] as String,
  instructions: json['instructions'] as String,
  siteName: json['site_name'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  geofenceRadiusM: (json['geofence_radius_m'] as num?)?.toInt(),
  accessNotes: json['access_notes'] as String,
  siteContactName: json['site_contact_name'] as String?,
  siteContactPhone: json['site_contact_phone'] as String?,
  scheduledStart: DateTime.parse(json['scheduled_start'] as String),
  scheduledEnd: DateTime.parse(json['scheduled_end'] as String),
  role: json['role'] as String,
  status: json['status'] as String,
  crew: (json['crew'] as List<dynamic>)
      .map((e) => CrewMateDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TaskDtoToJson(TaskDto instance) => <String, dynamic>{
  'id': instance.id,
  'job_id': instance.jobId,
  'visit_id': instance.visitId,
  'job_type': instance.jobType,
  'title': instance.title,
  'project_name': instance.projectName,
  'customer_name': instance.customerName,
  'instructions': instance.instructions,
  'site_name': instance.siteName,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'geofence_radius_m': instance.geofenceRadiusM,
  'access_notes': instance.accessNotes,
  'site_contact_name': instance.siteContactName,
  'site_contact_phone': instance.siteContactPhone,
  'scheduled_start': instance.scheduledStart.toIso8601String(),
  'scheduled_end': instance.scheduledEnd.toIso8601String(),
  'role': instance.role,
  'status': instance.status,
  'crew': instance.crew.map((e) => e.toJson()).toList(),
};

CatalogItemDto _$CatalogItemDtoFromJson(Map<String, dynamic> json) =>
    CatalogItemDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$CatalogItemDtoToJson(CatalogItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
    };

ExpectedMaterialDto _$ExpectedMaterialDtoFromJson(Map<String, dynamic> json) =>
    ExpectedMaterialDto(
      item: CatalogItemDto.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as String,
    );

Map<String, dynamic> _$ExpectedMaterialDtoToJson(
  ExpectedMaterialDto instance,
) => <String, dynamic>{
  'item': instance.item.toJson(),
  'quantity': instance.quantity,
};

EarningsDto _$EarningsDtoFromJson(Map<String, dynamic> json) => EarningsDto(
  month: json['month'] as String,
  approvedTasks: (json['approved_tasks'] as num).toInt(),
  approvedAmount: json['approved_amount'] as String,
  currency: json['currency'] as String,
);

Map<String, dynamic> _$EarningsDtoToJson(EarningsDto instance) =>
    <String, dynamic>{
      'month': instance.month,
      'approved_tasks': instance.approvedTasks,
      'approved_amount': instance.approvedAmount,
      'currency': instance.currency,
    };

NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    NotificationDto(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      taskId: (json['task_id'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
    );

Map<String, dynamic> _$NotificationDtoToJson(NotificationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'task_id': instance.taskId,
      'created_at': instance.createdAt.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
    };

NotificationPageDto _$NotificationPageDtoFromJson(Map<String, dynamic> json) =>
    NotificationPageDto(
      items: (json['items'] as List<dynamic>)
          .map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: (json['next_cursor'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NotificationPageDtoToJson(
  NotificationPageDto instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'next_cursor': instance.nextCursor,
};

LocationCheckBody _$LocationCheckBodyFromJson(Map<String, dynamic> json) =>
    LocationCheckBody(
      taskId: (json['task_id'] as num).toInt(),
      purpose: json['purpose'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyM: (json['accuracy_m'] as num).toDouble(),
      isMocked: json['is_mocked'] as bool,
      capturedAt: DateTime.parse(json['captured_at'] as String),
      distanceM: (json['distance_m'] as num).toDouble(),
      radiusM: (json['radius_m'] as num).toDouble(),
      verified: json['verified'] as bool,
    );

Map<String, dynamic> _$LocationCheckBodyToJson(LocationCheckBody instance) =>
    <String, dynamic>{
      'task_id': instance.taskId,
      'purpose': instance.purpose,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy_m': instance.accuracyM,
      'is_mocked': instance.isMocked,
      'captured_at': instance.capturedAt.toIso8601String(),
      'distance_m': instance.distanceM,
      'radius_m': instance.radiusM,
      'verified': instance.verified,
    };

TimeEntryBody _$TimeEntryBodyFromJson(Map<String, dynamic> json) =>
    TimeEntryBody(
      taskId: (json['task_id'] as num).toInt(),
      kind: json['kind'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      startLocationCheckId: json['start_location_check_id'] as String?,
    );

Map<String, dynamic> _$TimeEntryBodyToJson(TimeEntryBody instance) =>
    <String, dynamic>{
      'task_id': instance.taskId,
      'kind': instance.kind,
      'started_at': instance.startedAt.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'start_location_check_id': instance.startLocationCheckId,
    };

MaterialMovementBody _$MaterialMovementBodyFromJson(
  Map<String, dynamic> json,
) => MaterialMovementBody(
  taskId: (json['task_id'] as num).toInt(),
  catalogItemId: (json['catalog_item_id'] as num).toInt(),
  quantity: json['quantity'] as String,
  movement: json['movement'] as String,
  note: json['note'] as String?,
  recordedAt: json['recorded_at'] == null
      ? null
      : DateTime.parse(json['recorded_at'] as String),
);

Map<String, dynamic> _$MaterialMovementBodyToJson(
  MaterialMovementBody instance,
) => <String, dynamic>{
  'task_id': instance.taskId,
  'catalog_item_id': instance.catalogItemId,
  'quantity': instance.quantity,
  'movement': instance.movement,
  'note': instance.note,
  'recorded_at': instance.recordedAt?.toIso8601String(),
};

PresignBody _$PresignBodyFromJson(Map<String, dynamic> json) => PresignBody(
  taskId: (json['task_id'] as num).toInt(),
  kind: json['kind'] as String,
  mimeType: json['mime_type'] as String,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  takenAt: json['taken_at'] == null
      ? null
      : DateTime.parse(json['taken_at'] as String),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PresignBodyToJson(PresignBody instance) =>
    <String, dynamic>{
      'task_id': instance.taskId,
      'kind': instance.kind,
      'mime_type': instance.mimeType,
      'size_bytes': instance.sizeBytes,
      'taken_at': instance.takenAt?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

PresignDto _$PresignDtoFromJson(Map<String, dynamic> json) => PresignDto(
  uploadUrl: json['upload_url'] as String,
  headers: Map<String, String>.from(json['headers'] as Map),
  expiresAt: DateTime.parse(json['expires_at'] as String),
  alreadyUploaded: json['already_uploaded'] as bool,
);

Map<String, dynamic> _$PresignDtoToJson(PresignDto instance) =>
    <String, dynamic>{
      'upload_url': instance.uploadUrl,
      'headers': instance.headers,
      'expires_at': instance.expiresAt.toIso8601String(),
      'already_uploaded': instance.alreadyUploaded,
    };

CompletionBody _$CompletionBodyFromJson(Map<String, dynamic> json) =>
    CompletionBody(
      completedAt: DateTime.parse(json['completed_at'] as String),
      completionLocationCheckId:
          json['completion_location_check_id'] as String?,
      reportedWorkSeconds: (json['reported_work_seconds'] as num).toInt(),
      reportedBreakSeconds: (json['reported_break_seconds'] as num).toInt(),
      photoIds: (json['photo_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$CompletionBodyToJson(CompletionBody instance) =>
    <String, dynamic>{
      'completed_at': instance.completedAt.toIso8601String(),
      'completion_location_check_id': instance.completionLocationCheckId,
      'reported_work_seconds': instance.reportedWorkSeconds,
      'reported_break_seconds': instance.reportedBreakSeconds,
      'photo_ids': instance.photoIds,
      'comment': instance.comment,
    };
