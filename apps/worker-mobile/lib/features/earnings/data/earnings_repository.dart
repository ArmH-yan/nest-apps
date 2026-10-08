import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/nest_api.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/yerevan_time.dart';
import '../domain/earnings_summary.dart';

/// This month's approved earnings. The last server answer is cached so the
/// header still shows a number offline. The cache is cleared on logout.
class EarningsRepository {
  EarningsRepository({
    required NestApi api,
    required Clock clock,
    required SharedPreferences prefs,
  }) : _api = api,
       _clock = clock,
       _prefs = prefs;

  final NestApi _api;
  final Clock _clock;
  final SharedPreferences _prefs;

  static const cacheKey = 'cache.earnings';

  /// Cached summary for the current Yerevan month, or null if there is none.
  EarningsSummary? cached() {
    final raw = _prefs.getString(cacheKey);
    if (raw == null) return null;
    final summary = EarningsSummary.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    final today = YerevanTime.day(_clock.now());
    return summary.year == today.year && summary.month == today.month
        ? summary
        : null;
  }

  /// Fetches the current month. Throws ApiException when offline.
  Future<EarningsSummary> refresh() async {
    final today = YerevanTime.day(_clock.now());
    final summary = await _api.earnings(year: today.year, month: today.month);
    await _prefs.setString(cacheKey, jsonEncode(summary.toJson()));
    return summary;
  }
}
