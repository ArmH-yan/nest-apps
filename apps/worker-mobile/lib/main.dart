import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Entry point.
///
///   flutter run --flavor dev --dart-define=USE_MOCKS=true
///   flutter run --flavor dev --dart-define=USE_MOCKS=false \
///       --dart-define=API_BASE_URL=http://10.0.2.2:8000
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: NestWorkerApp()));
}
