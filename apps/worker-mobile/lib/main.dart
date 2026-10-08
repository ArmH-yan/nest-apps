import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';

/// Entry point.
///
///   flutter run --flavor dev                              (mock backend)
///   flutter run --flavor dev --dart-define=USE_MOCKS=false \
///       --dart-define=API_BASE_URL=http://10.0.2.2:8000   (real API, Phase 2)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      // Riverpod 3 retries failing providers by default; errors here are
      // shown to the worker with a Retry button instead.
      retry: (_, _) => null,
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const NestWorkerApp(),
    ),
  );
}
