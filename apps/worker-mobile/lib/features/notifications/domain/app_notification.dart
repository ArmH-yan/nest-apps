import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

enum NotificationType {
  taskAssigned,
  taskChanged,
  taskCancelled,
  taskReminder,
  submissionAccepted,
  submissionFailed,
}

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required NotificationType type,
    required String title,
    required String body,
    String? taskId,
    required DateTime createdAt,
    DateTime? readAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
