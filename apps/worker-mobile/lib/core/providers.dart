import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'network/api_client.dart';
import 'storage/app_database.dart';
import 'storage/token_storage.dart';
import 'time/clock.dart';

/// App-wide infrastructure providers. `main.dart` overrides [appConfigProvider];
/// tests override any of these (e.g. [clockProvider] with a FixedClock).
///
/// Feature repositories pick Mock* vs Api* implementations from
/// `appConfigProvider.useMocks` — the only place that choice is made.
final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

final clockProvider = Provider<Clock>((ref) => const SystemClock());

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
