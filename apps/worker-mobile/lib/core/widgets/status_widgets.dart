import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/tasks/domain/task_status.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../time/yerevan_time.dart';
import '../ui/l10n_ext.dart';

extension StatusColors on TaskDisplayStatus {
  Color get color => switch (this) {
    TaskDisplayStatus.upcoming => AppColors.textSecondary,
    TaskDisplayStatus.today => AppColors.charcoal,
    TaskDisplayStatus.inProgress => AppColors.working,
    TaskDisplayStatus.onBreak => AppColors.onBreak,
    TaskDisplayStatus.waitingForSubmission => AppColors.warning,
    TaskDisplayStatus.synchronizationFailed => AppColors.error,
    TaskDisplayStatus.completed => AppColors.success,
    TaskDisplayStatus.cancelled => AppColors.error,
  };

  IconData get icon => switch (this) {
    TaskDisplayStatus.upcoming => Icons.event,
    TaskDisplayStatus.today => Icons.play_circle_outline,
    TaskDisplayStatus.inProgress => Icons.construction,
    TaskDisplayStatus.onBreak => Icons.coffee,
    TaskDisplayStatus.waitingForSubmission => Icons.cloud_upload_outlined,
    TaskDisplayStatus.synchronizationFailed => Icons.sync_problem,
    TaskDisplayStatus.completed => Icons.check_circle,
    TaskDisplayStatus.cancelled => Icons.cancel_outlined,
  };
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.large = false});

  final TaskDisplayStatus status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 8 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: large ? 22 : 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              context.l10n.status(status),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: large ? 18 : 13,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Global sync / connectivity banner (WORKER_APP_SPEC "SyncStatusBanner").
/// Hidden when everything is sent and online.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(syncStatusProvider).value;
    final unsynced = ref.watch(unsyncedCountProvider).value ?? 0;
    final failed = (ref.watch(_failedCountProvider).value ?? 0) > 0;
    if (status == null) return const SizedBox.shrink();

    final (Color color, IconData icon, String text)? banner = !status.isOnline
        ? (AppColors.warning, Icons.cloud_off, l10n.syncOffline)
        : failed
        ? (AppColors.error, Icons.sync_problem, l10n.syncFailedBanner)
        : status.isSyncing && unsynced > 0
        ? (AppColors.onBreak, Icons.sync, l10n.syncing)
        : unsynced > 0
        ? (
            AppColors.warning,
            Icons.cloud_upload_outlined,
            l10n.syncPending(unsynced),
          )
        : null;
    if (banner == null) return const SizedBox.shrink();

    return Material(
      color: banner.$1.withValues(alpha: 0.14),
      child: InkWell(
        onTap: () => ref.read(syncServiceProvider).syncNow(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(banner.$2, color: banner.$1),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  banner.$3,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (unsynced > 0 && status.isOnline)
                Text(
                  l10n.syncNow,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final _failedCountProvider = StreamProvider<int>(
  (ref) =>
      ref.watch(outboxProvider).watchFailedTaskIds().map((ids) => ids.length),
);

/// "Last updated 08:12" helper text.
String lastUpdatedText(BuildContext context, DateTime? at) =>
    at == null ? '' : context.l10n.lastUpdated(YerevanTime.hm(at));
