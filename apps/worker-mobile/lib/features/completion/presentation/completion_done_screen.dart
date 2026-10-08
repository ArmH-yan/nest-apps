import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../tasks/domain/task_status.dart';
import '../../tasks/presentation/task_providers.dart';

/// After Submit: "saved, will be sent" until the server confirms, then
/// "submitted ✓" (WORKER_APP_SPEC "Submit").
class CompletionDoneScreen extends ConsumerWidget {
  const CompletionDoneScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(taskViewProvider(taskId)).value?.status;
    final confirmed = status == TaskDisplayStatus.completed;
    final failed = status == TaskDisplayStatus.synchronizationFailed;
    final color = confirmed
        ? AppColors.success
        : failed
        ? AppColors.error
        : AppColors.warning;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SyncStatusBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      confirmed
                          ? Icons.check_circle
                          : failed
                          ? Icons.sync_problem
                          : Icons.cloud_upload_outlined,
                      size: 112,
                      color: color,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      key: const Key('done.title'),
                      confirmed
                          ? l10n.submittedTitle
                          : failed
                          ? l10n.statusSyncFailed
                          : l10n.savedOfflineTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: color),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      confirmed ? l10n.submittedBody : l10n.savedOfflineBody,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      key: const Key('done.history'),
                      icon: Icons.history,
                      label: l10n.goToHistory,
                      onPressed: () => context.go('/history'),
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: l10n.myTasks,
                      onPressed: () => context.go('/tasks'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
