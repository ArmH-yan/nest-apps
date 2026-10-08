import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/profile/presentation/profile_screen.dart';

class NestWorkerApp extends ConsumerWidget {
  const NestWorkerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SyncLifecycle(
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: ref.watch(appRouterProvider),
        locale: ref.watch(localeProvider),
        // hy / ru / en; device language first, Armenian as fallback.
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supported) {
          for (final candidate in supported) {
            if (candidate.languageCode == locale?.languageCode) {
              return candidate;
            }
          }
          return const Locale('hy');
        },
      ),
    );
  }
}

/// Drives SyncService from app lifecycle and connectivity: sync on resume and
/// when the network returns; pause the periodic timer in the background.
class _SyncLifecycle extends ConsumerStatefulWidget {
  const _SyncLifecycle({required this.child});

  final Widget child;

  @override
  ConsumerState<_SyncLifecycle> createState() => _SyncLifecycleState();
}

class _SyncLifecycleState extends ConsumerState<_SyncLifecycle> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (ref.read(currentWorkerProvider) != null) {
          ref.read(syncServiceProvider).start();
        }
      },
      onPause: () => ref.read(syncServiceProvider).pause(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectivityProvider, (_, next) {
      final online = next.value;
      if (online != null && ref.read(currentWorkerProvider) != null) {
        ref.read(syncServiceProvider).setOnline(online);
      }
    });
    return widget.child;
  }
}
