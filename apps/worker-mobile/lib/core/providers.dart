import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/completion/data/completion_repository.dart';
import '../features/completion/data/completion_service.dart';
import '../features/earnings/data/earnings_repository.dart';
import '../features/notifications/data/notification_repository.dart';
import '../features/profile/data/settings_repository.dart';
import '../features/tasks/data/task_repository.dart';
import '../features/work/data/work_actions.dart';
import '../features/work/data/work_session_repository.dart';
import 'api/mock_nest_api.dart';
import 'api/nest_api.dart';
import 'config/app_config.dart';
import 'location/location_service.dart';
import 'media/photo_capture_service.dart';
import 'network/api_client.dart';
import 'storage/app_database.dart';
import 'storage/token_storage.dart';
import 'sync/outbox.dart';
import 'sync/sync_models.dart';
import 'sync/sync_service.dart';
import 'time/clock.dart';

/// App-wide dependency graph. `main.dart` overrides [sharedPreferencesProvider];
/// tests override whatever they need (clock, database, API, location, camera).
///
/// The Mock/Api decision is made in exactly one place: [nestApiProvider].

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    baseUrl: ref.watch(appConfigProvider).apiBaseUrl,
    clock: ref.watch(clockProvider),
  ),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final mockApiScenarioProvider = Provider<MockApiScenario>(
  (ref) => MockApiScenario(),
);

final nestApiProvider = Provider<NestApi>((ref) {
  if (ref.watch(appConfigProvider).useMocks) {
    return MockNestApi(
      clock: ref.watch(clockProvider),
      scenario: ref.watch(mockApiScenarioProvider),
    );
  }
  // The HTTP implementation (ApiClient + DTOs) is added once the backend's
  // /api/v1/worker endpoints exist (ARCHITECTURE §41, Phase 2).
  throw UnsupportedError(
    'USE_MOCKS=false is not supported yet: the worker API is not built.',
  );
});

final outboxProvider = Provider<Outbox>(
  (ref) => Outbox(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    api: ref.watch(nestApiProvider),
    tokens: ref.watch(tokenStorageProvider),
    prefs: ref.watch(sharedPreferencesProvider),
    db: ref.watch(appDatabaseProvider),
  ),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(
    db: ref.watch(appDatabaseProvider),
    api: ref.watch(nestApiProvider),
    clock: ref.watch(clockProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  ),
);

final workSessionRepositoryProvider = Provider<WorkSessionRepository>(
  (ref) => WorkSessionRepository(
    db: ref.watch(appDatabaseProvider),
    outbox: ref.watch(outboxProvider),
    clock: ref.watch(clockProvider),
  ),
);

final completionRepositoryProvider = Provider<CompletionRepository>(
  (ref) => CompletionRepository(
    db: ref.watch(appDatabaseProvider),
    outbox: ref.watch(outboxProvider),
    workSessions: ref.watch(workSessionRepositoryProvider),
  ),
);

final earningsRepositoryProvider = Provider<EarningsRepository>(
  (ref) => EarningsRepository(
    api: ref.watch(nestApiProvider),
    clock: ref.watch(clockProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  ),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(nestApiProvider)),
);

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    db: ref.watch(appDatabaseProvider),
    api: ref.watch(nestApiProvider),
    clock: ref.watch(clockProvider),
    completions: ref.watch(completionRepositoryProvider),
    tasks: ref.watch(taskRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final service = ref.watch(syncServiceProvider);
  yield service.status;
  yield* service.statusStream;
});

final unsyncedCountProvider = StreamProvider<int>(
  (ref) => ref.watch(outboxProvider).watchUnsyncedCount(),
);

/// Device connectivity (feeds SyncService; the outbox retries when it returns).
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> r) =>
      r.any((c) => c != ConnectivityResult.none);
  yield online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(online);
});

/// Dev setting: where GPS fixes come from.
class GpsSourceNotifier extends Notifier<GpsSource> {
  @override
  GpsSource build() {
    final useMocks = ref.watch(appConfigProvider).useMocks;
    return ref
        .watch(settingsRepositoryProvider)
        .gpsSource(
          fallback: useMocks ? GpsSource.mockAtSite : GpsSource.device,
        );
  }

  Future<void> set(GpsSource source) async {
    await ref.read(settingsRepositoryProvider).setGpsSource(source);
    state = source;
  }
}

final gpsSourceProvider = NotifierProvider<GpsSourceNotifier, GpsSource>(
  GpsSourceNotifier.new,
);

final locationServiceProvider = Provider<LocationService>((ref) {
  final source = ref.watch(gpsSourceProvider);
  return source == GpsSource.device
      ? const GeolocatorLocationService()
      : MockLocationService(source: source, clock: ref.watch(clockProvider));
});

final photoCaptureServiceProvider = Provider<PhotoCaptureService>(
  (ref) => ImagePickerPhotoCaptureService(),
);

final workActionsProvider = Provider<WorkActions>(
  (ref) => WorkActions(
    tasks: ref.watch(taskRepositoryProvider),
    sessions: ref.watch(workSessionRepositoryProvider),
    completions: ref.watch(completionRepositoryProvider),
    outbox: ref.watch(outboxProvider),
    location: ref.watch(locationServiceProvider),
    sync: ref.watch(syncServiceProvider),
    clock: ref.watch(clockProvider),
  ),
);

final completionServiceProvider = Provider<CompletionService>(
  (ref) => CompletionService(
    completions: ref.watch(completionRepositoryProvider),
    sessions: ref.watch(workSessionRepositoryProvider),
    tasks: ref.watch(taskRepositoryProvider),
    capture: ref.watch(photoCaptureServiceProvider),
    sync: ref.watch(syncServiceProvider),
    clock: ref.watch(clockProvider),
  ),
);
