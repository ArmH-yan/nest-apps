import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/time/yerevan_time.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../earnings/presentation/earnings_header.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../domain/task_status.dart';
import 'task_providers.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    ref.invalidate(earningsProvider);
    try {
      await ref.read(taskRepositoryProvider).refresh();
    } on Object catch (e) {
      if (context.mounted) showMessage(context, context.l10n.error(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final worker = ref.watch(currentWorkerProvider);
    final views = ref.watch(taskViewsProvider);
    final active = ref.watch(activeTaskProvider);
    final now =
        ref.watch(minuteTickerProvider).value ?? ref.watch(clockProvider).now();
    final unread = ref.watch(unreadNotificationsProvider);
    final lastRefreshed = ref.watch(taskRepositoryProvider).lastRefreshedAt;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.myTasks, overflow: TextOverflow.ellipsis),
            Text(
              // Date first: next to the header counters the name may be truncated.
              '${YerevanTime.date(now)} · ${worker?.fullName ?? ''}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          const EarningsHeaderStats(),
          IconButton(
            iconSize: 30,
            tooltip: l10n.notifications,
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SyncStatusBanner(),
          if (active != null)
            Material(
              color: active.status.color,
              child: InkWell(
                onTap: () => context.go('/work'),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(active.status.icon, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.activeTaskBanner(active.task.title),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: views.when(
              loading: () => const LoadingState(),
              error: (e, _) =>
                  ErrorState(error: e, onRetry: () => _refresh(context, ref)),
              data: (all) {
                final today = all
                    .where(
                      (v) =>
                          v.status != TaskDisplayStatus.upcoming &&
                          !v.status.isFinished &&
                          v.status != TaskDisplayStatus.cancelled,
                    )
                    .toList();
                final upcoming = all
                    .where((v) => v.status == TaskDisplayStatus.upcoming)
                    .toList();
                return RefreshIndicator(
                  onRefresh: () => _refresh(context, ref),
                  child: today.isEmpty && upcoming.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            EmptyState(
                              icon: Icons.assignment_turned_in_outlined,
                              title: l10n.emptyTasksTitle,
                              body: l10n.emptyTasksBody,
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: [
                            if (today.isNotEmpty) ...[
                              SectionHeader(l10n.sectionToday),
                              for (final v in today)
                                TaskCard(view: v, now: now, emphasized: true),
                            ],
                            if (upcoming.isNotEmpty) ...[
                              SectionHeader(l10n.sectionUpcoming),
                              for (final v in upcoming)
                                TaskCard(view: v, now: now),
                            ],
                            if (lastRefreshed != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  lastUpdatedText(context, lastRefreshed),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.view,
    required this.now,
    this.emphasized = false,
  });

  final TaskView view;
  final DateTime now;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final task = view.task;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: emphasized
            ? const BorderSide(color: AppColors.primary, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        key: Key('task.${task.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/tasks/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(task.title, style: theme.textTheme.titleLarge),
                  ),
                  if (task.isLead)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.leadBadge,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.jobType(task.jobType)} · ${task.projectName} · ${task.customerName}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              _IconText(
                Icons.schedule,
                scheduleText(
                  context,
                  task.scheduledStart,
                  task.scheduledEnd,
                  now,
                ),
              ),
              const SizedBox(height: 4),
              _IconText(Icons.place_outlined, task.address),
              const SizedBox(height: 12),
              StatusBadge(view.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
    ],
  );
}
