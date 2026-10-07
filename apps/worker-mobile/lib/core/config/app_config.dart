import 'package:flutter/services.dart' show appFlavor;

/// Build-time configuration (WORKER_APP_SPEC "Configuration").
///
/// Values come from `--dart-define` and the Android flavor (`--flavor dev|prod`).
/// Never put secrets here — the app binary is public.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.useMocks,
    required this.flavor,
  });

  /// Reads the compile-time environment.
  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        // Android emulator → host machine's FastAPI.
        defaultValue: 'http://10.0.2.2:8000',
      ),
      useMocks: const bool.fromEnvironment('USE_MOCKS', defaultValue: true),
      flavor: AppFlavor.parse(appFlavor),
    );
  }

  final String apiBaseUrl;

  /// When true, Mock* repositories are used instead of Api* ones.
  final bool useMocks;

  final AppFlavor flavor;
}

enum AppFlavor {
  dev,
  prod;

  /// Unknown or missing flavor (e.g. `flutter test`) is treated as dev.
  static AppFlavor parse(String? value) =>
      value == 'prod' ? AppFlavor.prod : AppFlavor.dev;
}
