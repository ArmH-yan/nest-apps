// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: json['id'] as String,
  jobId: json['jobId'] as String,
  visitId: json['visitId'] as String,
  jobType: $enumDecode(_$JobTypeEnumMap, json['jobType']),
  title: json['title'] as String,
  projectName: json['projectName'] as String,
  customerName: json['customerName'] as String,
  instructions: json['instructions'] as String? ?? '',
  siteName: json['siteName'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  geofenceRadiusM: (json['geofenceRadiusM'] as num?)?.toDouble(),
  accessNotes: json['accessNotes'] as String? ?? '',
  siteContactName: json['siteContactName'] as String?,
  siteContactPhone: json['siteContactPhone'] as String?,
  scheduledStart: DateTime.parse(json['scheduledStart'] as String),
  scheduledEnd: DateTime.parse(json['scheduledEnd'] as String),
  role: $enumDecode(_$TaskRoleEnumMap, json['role']),
  crew:
      (json['crew'] as List<dynamic>?)
          ?.map((e) => CrewMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CrewMember>[],
  serverStatus: $enumDecode(_$ServerTaskStatusEnumMap, json['serverStatus']),
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'jobId': instance.jobId,
  'visitId': instance.visitId,
  'jobType': _$JobTypeEnumMap[instance.jobType]!,
  'title': instance.title,
  'projectName': instance.projectName,
  'customerName': instance.customerName,
  'instructions': instance.instructions,
  'siteName': instance.siteName,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'geofenceRadiusM': instance.geofenceRadiusM,
  'accessNotes': instance.accessNotes,
  'siteContactName': instance.siteContactName,
  'siteContactPhone': instance.siteContactPhone,
  'scheduledStart': instance.scheduledStart.toIso8601String(),
  'scheduledEnd': instance.scheduledEnd.toIso8601String(),
  'role': _$TaskRoleEnumMap[instance.role]!,
  'crew': instance.crew.map((e) => e.toJson()).toList(),
  'serverStatus': _$ServerTaskStatusEnumMap[instance.serverStatus]!,
};

const _$JobTypeEnumMap = {
  JobType.survey: 'survey',
  JobType.installation: 'installation',
  JobType.inspection: 'inspection',
  JobType.maintenance: 'maintenance',
  JobType.dismantling: 'dismantling',
};

const _$TaskRoleEnumMap = {TaskRole.lead: 'lead', TaskRole.member: 'member'};

const _$ServerTaskStatusEnumMap = {
  ServerTaskStatus.assigned: 'assigned',
  ServerTaskStatus.inProgress: 'inProgress',
  ServerTaskStatus.submitted: 'submitted',
  ServerTaskStatus.cancelled: 'cancelled',
};

_CrewMember _$CrewMemberFromJson(Map<String, dynamic> json) => _CrewMember(
  workerId: json['workerId'] as String,
  fullName: json['fullName'] as String,
  role: $enumDecode(_$TaskRoleEnumMap, json['role']),
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$CrewMemberToJson(_CrewMember instance) =>
    <String, dynamic>{
      'workerId': instance.workerId,
      'fullName': instance.fullName,
      'role': _$TaskRoleEnumMap[instance.role]!,
      'phone': instance.phone,
    };
