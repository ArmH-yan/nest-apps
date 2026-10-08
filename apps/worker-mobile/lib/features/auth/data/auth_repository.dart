import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/nest_api.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/token_storage.dart';
import '../../earnings/data/earnings_repository.dart';
import '../domain/worker.dart';

/// Session handling. Tokens live in secure storage; the (non-secret) worker
/// profile in SharedPreferences so the app opens offline.
class AuthRepository {
  AuthRepository({
    required NestApi api,
    required TokenStorage tokens,
    required SharedPreferences prefs,
    required AppDatabase db,
  }) : _api = api,
       _tokens = tokens,
       _prefs = prefs,
       _db = db;

  final NestApi _api;
  final TokenStorage _tokens;
  final SharedPreferences _prefs;
  final AppDatabase _db;

  static const _workerKey = 'session.worker';
  static const _lastWorkerIdKey = 'session.last_worker_id';

  /// The signed-in worker, or null. Works offline.
  Future<Worker?> restore() async {
    final raw = _prefs.getString(_workerKey);
    if (raw == null || await _tokens.read() == null) return null;
    return Worker.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<Worker> login({
    required String phone,
    required String password,
  }) async {
    final result = await _api.login(phone: phone, password: password);
    // A different worker on this device: local data belongs to someone else.
    final lastId = _prefs.getString(_lastWorkerIdKey);
    if (lastId != null && lastId != result.worker.id) await _db.clearAll();

    await _tokens.write(
      StoredTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      ),
    );
    await _prefs.setString(_workerKey, jsonEncode(result.worker.toJson()));
    await _prefs.setString(_lastWorkerIdKey, result.worker.id);
    return result.worker;
  }

  Future<Worker> changePassword({
    required Worker worker,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    final updated = worker.copyWith(mustChangePassword: false);
    await _prefs.setString(_workerKey, jsonEncode(updated.toJson()));
    return updated;
  }

  /// Signs out. Unsynced local data is kept on the device on purpose
  /// (WORKER_APP_SPEC "Authentication"). Pay figures are not.
  Future<void> logout() async {
    await _tokens.clear();
    await _prefs.remove(_workerKey);
    await _prefs.remove(EarningsRepository.cacheKey);
  }
}
