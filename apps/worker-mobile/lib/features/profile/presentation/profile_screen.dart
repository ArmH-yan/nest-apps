import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/api/mock_nest_api.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/common.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/settings_repository.dart';

/// Chosen UI language (null = device language).
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => ref.watch(settingsRepositoryProvider).locale;

  Future<void> set(Locale? locale) async {
    await ref.read(settingsRepositoryProvider).setLocale(locale);
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

final _locationPermissionProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final p = await Geolocator.checkPermission();
  return p == LocationPermission.always || p == LocationPermission.whileInUse;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final unsynced = await ref.read(outboxProvider).unsyncedCount();
    if (!context.mounted) return;
    final ok = await showConfirmDialog(
      context,
      title: l10n.logoutConfirmTitle,
      confirmLabel: l10n.logout,
      content: unsynced > 0
          ? Text(l10n.logoutUnsyncedBody(unsynced))
          : const SizedBox.shrink(),
    );
    if (ok) await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final worker = ref.watch(currentWorkerProvider);
    final config = ref.watch(appConfigProvider);
    final unsynced = ref.watch(unsyncedCountProvider).value ?? 0;
    final locale = ref.watch(localeProvider);
    final settings = ref.watch(settingsRepositoryProvider);
    final locationGranted = ref.watch(_locationPermissionProvider).value;
    final location = ref.read(locationServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary,
              child: Text(
                (worker?.fullName ?? '?').characters.first,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            worker?.fullName ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          CardSection(
            children: [
              InfoRow(
                icon: Icons.badge_outlined,
                label: l10n.employeeId,
                value: worker?.employeeCode ?? '',
              ),
              InfoRow(
                icon: Icons.phone,
                label: l10n.phone,
                value: worker?.phone ?? '',
              ),
              InfoRow(
                icon: Icons.business,
                label: l10n.company,
                value: worker?.companyName ?? '',
              ),
            ],
          ),
          CardSection(
            title: l10n.settings,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.notifications),
                value: settings.notificationsEnabled,
                onChanged: (v) async {
                  await settings.setNotificationsEnabled(v);
                  ref.invalidate(settingsRepositoryProvider);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.locationPermission),
                subtitle: Text(
                  locationGranted == true ? '✓' : l10n.manageInSettings,
                ),
                trailing: const Icon(Icons.open_in_new),
                onTap: location.openAppSettings,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.cameraPermission),
                subtitle: Text(l10n.manageInSettings),
                trailing: const Icon(Icons.open_in_new),
                onTap: location.openAppSettings,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: const Key('profile.language'),
                initialValue: locale?.languageCode ?? '',
                decoration: InputDecoration(
                  labelText: l10n.language,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: '', child: Text(l10n.languageDevice)),
                  const DropdownMenuItem(value: 'hy', child: Text('Հայերեն')),
                  const DropdownMenuItem(value: 'ru', child: Text('Русский')),
                  const DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (code) => ref
                    .read(localeProvider.notifier)
                    .set(code == null || code.isEmpty ? null : Locale(code)),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.unsyncedItems),
                subtitle: Text('$unsynced'),
                trailing: TextButton(
                  onPressed: () => ref.read(syncServiceProvider).syncNow(),
                  child: Text(l10n.syncNow),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.appVersion),
                subtitle: Text('1.0.0 · ${config.flavor.name}'),
              ),
            ],
          ),
          if (config.flavor == AppFlavor.dev) const _DeveloperSection(),
          const SizedBox(height: 8),
          DangerButton(
            key: const Key('profile.logout'),
            label: l10n.logout,
            onPressed: () => _logout(context, ref),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Dev-flavor only: switch mock GPS scenarios and simulate failures
/// (WORKER_APP_SPEC "Mock data").
class _DeveloperSection extends ConsumerStatefulWidget {
  const _DeveloperSection();

  @override
  ConsumerState<_DeveloperSection> createState() => _DeveloperSectionState();
}

class _DeveloperSectionState extends ConsumerState<_DeveloperSection> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gps = ref.watch(gpsSourceProvider);
    final MockApiScenario scenario = ref.watch(mockApiScenarioProvider);
    final useMocks = ref.watch(appConfigProvider).useMocks;

    return CardSection(
      title: l10n.developer,
      children: [
        DropdownButtonFormField<GpsSource>(
          key: const Key('dev.gps'),
          initialValue: gps,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.gpsSource,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final s in GpsSource.values)
              DropdownMenuItem(value: s, child: Text(s.name)),
          ],
          onChanged: (s) {
            if (s != null) ref.read(gpsSourceProvider.notifier).set(s);
          },
        ),
        if (useMocks) ...[
          SwitchListTile(
            key: const Key('dev.offline'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.simulateOffline),
            value: scenario.offline,
            onChanged: (v) {
              setState(() => scenario.offline = v);
              ref.read(syncServiceProvider).setOnline(!v);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.failNextUpload),
            value: scenario.failNextUpload,
            onChanged: (v) => setState(() => scenario.failNextUpload = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.rejectNextCompletion),
            value: scenario.rejectNextCompletion,
            onChanged: (v) => setState(() => scenario.rejectNextCompletion = v),
          ),
        ],
      ],
    );
  }
}
