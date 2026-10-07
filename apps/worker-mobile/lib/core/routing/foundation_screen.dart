import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers.dart';

/// Temporary start screen until the login/tasks features exist.
class FoundationScreen extends ConsumerWidget {
  const FoundationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.foundationHeadline,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(l10n.foundationBody, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text(
              '${config.flavor.name} · '
              '${config.useMocks ? 'mocks' : config.apiBaseUrl}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
