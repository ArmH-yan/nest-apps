import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../api/nest_api.dart';
import '../config/app_config.dart';

/// Push transport (ARCHITECTURE §26): FCM on Android (APNs via FCM on iOS).
/// Firebase only carries the buzz — the notification list and read state come
/// from the NEST API. Only `firebase_core` + `firebase_messaging` are used.
abstract interface class PushService {
  /// Asks for permission, gets this phone's token and registers it with the
  /// API (`PUT /worker/devices/{token}`). Safe to call at every sign-in.
  Future<void> register();

  /// Forgets the token on this phone (logout). The server also drops it.
  Future<void> unregister();

  /// Task ids of pushes the worker tapped (app in background or closed).
  Stream<String> get openedTaskIds;

  /// A push arrived while the app was open: refresh notifications and tasks.
  Stream<void> get received;
}

/// Mocks, tests, and builds without a Firebase project.
class NoopPushService implements PushService {
  const NoopPushService();

  @override
  Future<void> register() async {}

  @override
  Future<void> unregister() async {}

  @override
  Stream<String> get openedTaskIds => const Stream.empty();

  @override
  Stream<void> get received => const Stream.empty();
}

/// Firebase config comes from `android/app/google-services.json` (one file for
/// both flavors' apps, never committed) via the Google services Gradle plugin.
/// Without the file, initialization fails, sign-in ignores it and push is off.
class FcmPushService implements PushService {
  FcmPushService({required NestApi api}) : _api = api;

  final NestApi _api;
  final _opened = StreamController<String>.broadcast();
  final _received = StreamController<void>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
  bool _listening = false;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  Future<void> _ensureInitialized() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }

  @override
  Future<void> register() async {
    await _ensureInitialized();
    // Android 13+ shows the system dialog once; later calls return the answer.
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;
    // firebase_messaging 17 deprecates tokens for FID "direct send"
    // (register/onRegistered). The backend's FCM HTTP v1 sender targets
    // registration tokens; switching to FIDs is a later, server+app change.
    // ignore: deprecated_member_use
    final token = await _messaging.getToken();
    if (token != null) await _send(token);
    if (_listening) return;
    _listening = true;
    _subscriptions
      // ignore: deprecated_member_use
      ..add(_messaging.onTokenRefresh.listen((t) => unawaited(_send(t))))
      ..add(FirebaseMessaging.onMessage.listen((_) => _received.add(null)))
      ..add(FirebaseMessaging.onMessageOpenedApp.listen(_open));
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _open(initial);
  }

  Future<void> _send(String token) async {
    try {
      await _api.registerDevice(
        token: token,
        platform: Platform.isIOS ? 'ios' : 'android',
        appVersion: AppConfig.version,
      );
    } on Object catch (e) {
      // offline: the next sign-in or app start registers again
      debugPrint('push: registering the device failed: $e');
    }
  }

  void _open(RemoteMessage message) {
    final taskId = message.data['assignment_id'];
    if (taskId is String && taskId.isNotEmpty) _opened.add(taskId);
  }

  @override
  Future<void> unregister() async {
    if (Firebase.apps.isEmpty) return;
    try {
      // ignore: deprecated_member_use
      await _messaging.deleteToken(); // the next sign-in gets a fresh token
    } on Object catch (e) {
      debugPrint('push: deleting the token failed: $e');
    }
  }

  @override
  Stream<String> get openedTaskIds => _opened.stream;

  @override
  Stream<void> get received => _received.stream;

  Future<void> dispose() async {
    for (final s in _subscriptions) {
      await s.cancel();
    }
    await _opened.close();
    await _received.close();
  }
}
