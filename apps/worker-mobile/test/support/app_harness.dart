import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/app.dart';
import 'package:nest_worker/core/api/mock_nest_api.dart';
import 'package:nest_worker/core/providers.dart';
import 'package:nest_worker/core/storage/app_database.dart';
import 'package:nest_worker/core/storage/token_storage.dart';
import 'package:nest_worker/core/time/clock.dart';
import 'package:nest_worker/core/time/yerevan_time.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'harness.dart' show FakePhotoCapture;

class MemoryTokenStorage implements TokenStorage {
  StoredTokens? _tokens;

  @override
  Future<void> clear() async => _tokens = null;

  @override
  Future<StoredTokens?> read() async => _tokens;

  @override
  Future<void> write(StoredTokens tokens) async => _tokens = tokens;
}

/// Pumps the whole app with in-memory/fake infrastructure.
class AppHarness {
  AppHarness._(this.prefs);

  final SharedPreferences prefs;
  final clock = FixedClock(YerevanTime.at(2026, 10, 7, 9, 5));
  final db = AppDatabase(NativeDatabase.memory());
  final tokens = MemoryTokenStorage();
  final scenario = MockApiScenario()..latency = Duration.zero;
  final capture = FakePhotoCapture();

  static Future<AppHarness> create({
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    return AppHarness._(await SharedPreferences.getInstance());
  }

  Widget build() => ProviderScope(
    retry: (_, _) => null,
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      clockProvider.overrideWithValue(clock),
      appDatabaseProvider.overrideWithValue(db),
      tokenStorageProvider.overrideWithValue(tokens),
      mockApiScenarioProvider.overrideWithValue(scenario),
      photoCaptureServiceProvider.overrideWithValue(capture),
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
    ],
    child: const NestWorkerApp(),
  );

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(build());
    await settle(tester);
  }

  /// pumpAndSettle can't be used: tickers and spinners never settle.
  /// Each step lets real async work finish (drift completes queries on real
  /// time in widget tests) and then advances fake time by 100 ms.
  Future<void> settle(WidgetTester tester, [int frames = 12]) async {
    for (var i = 0; i < frames; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> login(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('login.phone')),
      '+37491000007',
    );
    await tester.enterText(find.byKey(const Key('login.password')), 'nest1234');
    await tester.tap(find.byKey(const Key('login.submit')));
    await settle(tester, 20);
  }

  /// Unmounts the app so stream subscriptions and timers are cancelled.
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await db.close();
  }
}
