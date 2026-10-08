import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/completion/presentation/completion_done_screen.dart';
import '../../features/completion/presentation/completion_screen.dart';
import '../../features/history/presentation/history_screens.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/tasks/presentation/task_details_screen.dart';
import '../../features/tasks/presentation/task_providers.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/work/presentation/verify_location_screen.dart';
import '../../features/work/presentation/work_screen.dart';
import '../theme/app_colors.dart';
import '../ui/l10n_ext.dart';
import '../widgets/common.dart';

/// Routes (WORKER_APP_SPEC "Navigation").
final appRouterProvider = Provider<GoRouter>((ref) {
  // Re-evaluates redirects when the session changes.
  final auth = ValueNotifier<AsyncValue<Object?>>(const AsyncLoading());
  ref.listen(
    authControllerProvider,
    (_, next) => auth.value = next,
    fireImmediately: true,
  );

  final router = GoRouter(
    initialLocation: '/tasks',
    refreshListenable: auth,
    redirect: (context, state) {
      final session = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      if (session.isLoading && !session.hasValue) {
        return loc == '/splash' ? null : '/splash';
      }
      final worker = session.value;
      if (worker == null) return loc == '/login' ? null : '/login';
      if (worker.mustChangePassword) {
        return loc == '/change-password' ? null : '/change-password';
      }
      if (loc == '/login' || loc == '/splash' || loc == '/change-password') {
        return '/tasks';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const Scaffold(body: LoadingState()),
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/change-password',
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/work/complete',
        builder: (_, _) => const CompletionScreen(),
      ),
      GoRoute(
        path: '/work/done/:taskId',
        builder: (_, s) =>
            CompletionDoneScreen(taskId: s.pathParameters['taskId']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (_, _) => const TasksScreen(),
                routes: [
                  GoRoute(
                    path: ':taskId',
                    builder: (_, s) =>
                        TaskDetailsScreen(taskId: s.pathParameters['taskId']!),
                    routes: [
                      GoRoute(
                        path: 'verify-location',
                        builder: (_, s) => VerifyLocationScreen(
                          taskId: s.pathParameters['taskId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/work', builder: (_, _) => const WorkScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (_, _) => const HistoryScreen(),
                routes: [
                  GoRoute(
                    path: ':taskId',
                    builder: (_, s) => HistoryDetailScreen(
                      taskId: s.pathParameters['taskId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    auth.dispose();
  });
  return router;
});

class _HomeShell extends ConsumerWidget {
  const _HomeShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final active = ref.watch(activeTaskProvider);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: shell.currentIndex,
        indicatorColor: AppColors.primary,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: l10n.navTasks,
          ),
          NavigationDestination(
            key: const Key('nav.work'),
            icon: Badge(
              isLabelVisible: active != null,
              backgroundColor: AppColors.working,
              smallSize: 10,
              child: const Icon(Icons.timer_outlined),
            ),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.navWork,
          ),
          NavigationDestination(
            key: const Key('nav.history'),
            icon: const Icon(Icons.history),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            key: const Key('nav.profile'),
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
