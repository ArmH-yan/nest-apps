import '../../../core/api/nest_api.dart';
import '../domain/app_notification.dart';

/// In-app notification list (`GET /worker/notifications`). Push delivery is
/// `PushService` (core/push); content always comes from the API.
class NotificationRepository {
  NotificationRepository(this._api);

  final NestApi _api;

  Future<List<AppNotification>> list() async {
    final items = await _api.notifications();
    return [...items]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markRead(String id) => _api.markNotificationRead(id);
}
