import '../../features/auth/domain/worker.dart';
import '../../features/completion/domain/completion_models.dart';
import '../../features/earnings/domain/earnings_summary.dart';
import '../../features/notifications/domain/app_notification.dart';
import '../../features/tasks/domain/task.dart';
import '../../features/tasks/domain/task_config.dart';
import '../../features/work/domain/location_check.dart';
import '../../features/work/domain/time_entry.dart';

/// The NEST backend as seen by the app (ARCHITECTURE §18 `/api/v1/worker/*`).
///
/// This is the single Mock/Api switch point: `MockNestApi` now, an HTTP
/// implementation (on top of ApiClient + DTOs) when the backend endpoints
/// exist. Repositories own local storage and call this; the UI never sees it.
///
/// Every method throws `ApiException` on failure.
abstract interface class NestApi {
  Future<LoginResult> login({required String phone, required String password});

  /// Revokes the session on the server. Best effort: callers ignore failures
  /// (e.g. offline), the local sign-out happens anyway.
  Future<void> logout();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Worker> me();

  Future<TaskConfig> config();

  /// Tasks (assignments) between [from] and [to], inclusive by scheduled start.
  Future<List<Task>> tasks({required DateTime from, required DateTime to});

  Future<List<ExpectedMaterial>> expectedMaterials(String taskId);

  Future<List<CatalogItem>> catalog();

  Future<void> putLocationCheck(LocationCheck check);

  Future<void> putTimeEntry(TimeEntry entry);

  Future<void> putMaterial(MaterialEntry material);

  /// Step 1–3 of a photo upload: presign → PUT bytes → confirm.
  Future<PhotoUploadTarget> presignPhoto(TaskPhoto photo);

  Future<void> uploadPhoto(
    PhotoUploadTarget target,
    String localPath, {
    void Function(double progress)? onProgress,
  });

  Future<void> confirmPhoto(String photoId);

  Future<void> putCompletion(TaskCompletion completion);

  /// Approved tasks and their pay for one Yerevan calendar month.
  Future<EarningsSummary> earnings({required int year, required int month});

  Future<List<AppNotification>> notifications();

  Future<void> markNotificationRead(String id);
}

class LoginResult {
  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.worker,
  });

  final String accessToken;
  final String refreshToken;
  final Worker worker;
}

/// Where to PUT a photo's bytes (a presigned storage URL).
class PhotoUploadTarget {
  const PhotoUploadTarget({
    required this.url,
    this.headers = const {},
    this.alreadyUploaded = false,
  });

  final Uri url;

  /// Must be sent with the PUT (they are part of the signature).
  final Map<String, String> headers;

  /// The server already has the file (a replay): skip the PUT, just confirm.
  final bool alreadyUploaded;
}
