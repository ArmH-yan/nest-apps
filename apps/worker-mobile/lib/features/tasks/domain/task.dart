import 'package:freezed_annotation/freezed_annotation.dart';

import 'task_config.dart';

part 'task.freezed.dart';
part 'task.g.dart';

enum JobType { survey, installation, inspection, maintenance, dismantling }

enum TaskRole { lead, member }

/// Assignment status as stored on the server (ARCHITECTURE §11).
enum ServerTaskStatus { assigned, inProgress, submitted, cancelled }

/// A worker's assignment to one visit of a job (`visit_assignment`).
/// JSON here is only the app's local cache format, not the API DTO.
@freezed
abstract class Task with _$Task {
  const Task._();

  const factory Task({
    required String id,
    required String jobId,
    required String visitId,
    required JobType jobType,
    required String title,
    required String projectName,
    required String customerName,
    @Default('') String instructions,
    required String siteName,
    required String address,
    required double latitude,
    required double longitude,
    double? geofenceRadiusM,
    @Default('') String accessNotes,
    String? siteContactName,
    String? siteContactPhone,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    required TaskRole role,
    @Default(<CrewMember>[]) List<CrewMember> crew,
    required ServerTaskStatus serverStatus,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  bool get isLead => role == TaskRole.lead;

  /// Radius from the site, falling back to the server default.
  double radiusM(TaskConfig config) =>
      geofenceRadiusM ?? config.defaultGeofenceRadiusM;

  /// Crew lead records materials for these job types (ARCHITECTURE §16).
  bool get leadRecordsMaterials =>
      isLead &&
      (jobType == JobType.installation ||
          jobType == JobType.dismantling ||
          jobType == JobType.inspection);

  /// At least one material row is mandatory for these.
  bool get materialsRequired =>
      isLead &&
      (jobType == JobType.installation || jobType == JobType.dismantling);
}

@freezed
abstract class CrewMember with _$CrewMember {
  const factory CrewMember({
    required String workerId,
    required String fullName,
    required TaskRole role,
    String? phone,
  }) = _CrewMember;

  factory CrewMember.fromJson(Map<String, dynamic> json) =>
      _$CrewMemberFromJson(json);
}
