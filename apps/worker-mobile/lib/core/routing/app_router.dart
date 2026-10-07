import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'foundation_screen.dart';

/// Route table. Feature routes from WORKER_APP_SPEC "Navigation" (/login,
/// /tasks, /work, /history, /profile, …) are added as each feature is built.
abstract final class AppRoutes {
  static const home = '/';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const FoundationScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
