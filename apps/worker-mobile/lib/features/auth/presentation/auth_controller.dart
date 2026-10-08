import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/mock_seeder.dart';
import '../../../core/providers.dart';
import '../domain/worker.dart';

/// Session state: `null` = signed out. Restored offline from local storage.
class AuthController extends AsyncNotifier<Worker?> {
  @override
  Future<Worker?> build() async {
    final worker = await ref.read(authRepositoryProvider).restore();
    if (worker != null) await _afterSignIn();
    return worker;
  }

  Future<void> login(String phone, String password) async {
    final worker = await ref
        .read(authRepositoryProvider)
        .login(phone: phone.trim(), password: password);
    await _afterSignIn();
    state = AsyncData(worker);
  }

  Future<void> changePassword(String current, String next) async {
    final worker = state.value;
    if (worker == null) return;
    state = AsyncData(
      await ref
          .read(authRepositoryProvider)
          .changePassword(
            worker: worker,
            currentPassword: current,
            newPassword: next,
          ),
    );
  }

  Future<void> logout() async {
    ref.read(syncServiceProvider).pause();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<void> _afterSignIn() async {
    if (ref.read(appConfigProvider).useMocks) {
      await MockSeeder.seedIfEmpty(
        ref.read(appDatabaseProvider),
        ref.read(clockProvider).now(),
      );
    }
    unawaited(ref.read(syncServiceProvider).start());
    // Refresh in the background; the cached list shows immediately.
    unawaited(
      ref.read(taskRepositoryProvider).refresh().catchError((Object _) {}),
    );
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, Worker?>(
  AuthController.new,
);

final currentWorkerProvider = Provider<Worker?>(
  (ref) => ref.watch(authControllerProvider).value,
);
