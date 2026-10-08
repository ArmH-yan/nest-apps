import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where GPS fixes come from. `mock*` scenarios are dev-only (Profile → Developer).
enum GpsSource {
  device,
  mockAtSite,
  mockOutside,
  mockLowAccuracy,
  mockPermissionDenied,
  mockServicesDisabled,
}

/// Small per-device preferences (language, dev switches).
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _localeKey = 'settings.locale';
  static const _gpsKey = 'dev.gps_source';
  static const _notificationsKey = 'settings.notifications_enabled';

  /// null = follow the device language.
  Locale? get locale {
    final code = _prefs.getString(_localeKey);
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) => locale == null
      ? _prefs.remove(_localeKey)
      : _prefs.setString(_localeKey, locale.languageCode);

  GpsSource gpsSource({required GpsSource fallback}) {
    final raw = _prefs.getString(_gpsKey);
    return raw == null ? fallback : GpsSource.values.byName(raw);
  }

  Future<void> setGpsSource(GpsSource source) =>
      _prefs.setString(_gpsKey, source.name);

  bool get notificationsEnabled => _prefs.getBool(_notificationsKey) ?? true;

  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_notificationsKey, value);
}
