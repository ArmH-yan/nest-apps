import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/time/yerevan_time.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../completion/presentation/completion_screen.dart' show PhotoThumb;
import '../../tasks/domain/task_status.dart';
import '../../tasks/presentation/task_providers.dart';
import '../../work/domain/time_entry.dart';

/// Finished tasks (submitted, waiting or failed), newest first, grouped by day.
final historyProvider = Provider<AsyncValue<List<TaskView>>>(
  (ref) => ref
      .watch(taskViewsProvider)
      .whenData(
        (views) =>
            views
                .where((v) => v.status.isFinished && v.completion != null)
                .toList()
              ..sort(
                (a, b) => b.completion!.completedAt.compareTo(
                  a.completion!.completedAt,
                ),
              ),
      ),
);

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final history = ref.watch(historyProvider);
    final now =
        ref.watch(minuteTickerProvider).value ?? ref.watch(clockProvider).now();

    String dayHeader(DateTime at) {
      final day = YerevanTime.day(at);
      final today = YerevanTime.day(now);
      if (day == today) return l10n.sectionToday;
      if (day == today.subtract(const Duration(days: 1))) {
        return l10n.sectionYesterday;
      }
      return YerevanTime.date(at);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: Column(
        children: [
          const SyncStatusBanner(),
          Expanded(
            child: history.when(
              loading: () => const LoadingState(),
              error: (e, _) => ErrorState(error: e),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.history,
                    title: l10n.historyEmptyTitle,
                    body: l10n.historyEmptyBody,
                  );
                }
                final children = <Widget>[];
                String? lastHeader;
                for (final v in items) {
                  final at = v.completion!.completedAt.toUtc();
                  final header = dayHeader(at);
                  if (header != lastHeader) {
                    children.add(SectionHeader(header));
                    lastHeader = header;
                  }
                  children.add(_HistoryTile(view: v));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: children,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.view});

  final TaskView view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = view.completion!;
    final ok = view.status == TaskDisplayStatus.completed;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        key: Key('history.${view.id}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(view.status.icon, color: view.status.color, size: 32),
        title: Text(
          view.task.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          [
            l10n.workingDuration(
              l10n.hoursMinutesOf(Duration(milliseconds: c.totalWorkMs)),
            ),
            l10n.completedAtTime(YerevanTime.hm(c.completedAt.toUtc())),
            if (!ok) l10n.status(view.status),
          ].join('\n'),
        ),
        isThreeLine: !ok,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/history/${view.id}'),
      ),
    );
  }
}

class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final view = ref.watch(taskViewProvider(taskId)).value;
    if (view == null || view.completion == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.historyTitle)),
        body: EmptyState(icon: Icons.search_off, title: l10n.taskNotFound),
      );
    }
    final task = view.task;
    final c = view.completion!;
    final photos = ref.watch(photosProvider(taskId)).value ?? const [];
    final materials = ref.watch(materialsProvider(taskId)).value ?? const [];
    final checks = ref.watch(locationChecksProvider(taskId)).value ?? const [];
    final completionCheck = checks
        .where((x) => x.id == c.completionLocationCheckId)
        .firstOrNull;
    final reason = ref.watch(syncFailureMessageProvider(taskId)).value;

    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge(view.status, large: true),
          ),
          if (view.status == TaskDisplayStatus.synchronizationFailed) ...[
            const SizedBox(height: 12),
            MessageBanner(
              message: reason ?? l10n.syncFailedBanner,
              color: AppColors.error,
              icon: Icons.sync_problem,
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              icon: Icons.refresh,
              label: l10n.retry,
              onPressed: () async {
                await ref.read(outboxProvider).retryTask(taskId);
                await ref.read(syncServiceProvider).syncNow();
              },
            ),
          ],
          const SizedBox(height: 12),
          CardSection(
            title: l10n.taskInformation,
            children: [
              InfoRow(label: l10n.project, value: task.projectName),
              InfoRow(label: l10n.customer, value: task.customerName),
              InfoRow(
                label: l10n.address,
                value: '${task.siteName}, ${task.address}',
              ),
              InfoRow(
                label: l10n.workTime,
                value: formatHms(Duration(milliseconds: c.totalWorkMs)),
              ),
              InfoRow(
                label: l10n.breakTime,
                value: formatHms(Duration(milliseconds: c.totalBreakMs)),
              ),
              InfoRow(
                label: l10n.completionTime,
                value:
                    '${YerevanTime.date(c.completedAt.toUtc())} ${YerevanTime.hm(c.completedAt.toUtc())}',
              ),
              InfoRow(
                label: l10n.completionLocation,
                value: completionCheck == null
                    ? l10n.notRecorded
                    : '${completionCheck.latitude.toStringAsFixed(5)}, ${completionCheck.longitude.toStringAsFixed(5)}',
              ),
              if ((c.comment ?? '').isNotEmpty)
                InfoRow(label: l10n.comment, value: c.comment!),
            ],
          ),
          CardSection(
            title: l10n.workAndBreaks,
            children: [
              for (final e in view.entries)
                InfoRow(
                  icon: e.kind == TimeEntryKind.work
                      ? Icons.construction
                      : Icons.coffee,
                  label: e.kind == TimeEntryKind.work
                      ? l10n.sessionWork
                      : l10n.sessionBreak,
                  value:
                      '${YerevanTime.hm(e.startedAt)} – ${e.endedAt == null ? '…' : YerevanTime.hm(e.endedAt!)}  (${l10n.hoursMinutesOf(e.durationAt(e.endedAt ?? e.startedAt))})',
                ),
            ],
          ),
          if (materials.isNotEmpty)
            CardSection(
              title: l10n.materialsTitle,
              children: [
                for (final m in materials)
                  InfoRow(
                    label: l10n.movement(m.movement),
                    value: '${m.itemName}: ${m.quantity} ${m.unit}',
                  ),
              ],
            ),
          CardSection(
            title: '${l10n.photos} (${photos.length})',
            children: [
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (final p in photos)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: PhotoThumb(photo: p),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
