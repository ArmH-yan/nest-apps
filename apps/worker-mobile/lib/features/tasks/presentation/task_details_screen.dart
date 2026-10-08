import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/time/yerevan_time.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/launchers.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../work/domain/task_state_machine.dart';
import '../domain/task.dart';
import '../domain/task_status.dart';
import 'task_providers.dart';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final view = ref.watch(taskViewProvider(taskId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taskInformation)),
      body: view.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(error: e),
        data: (v) => v == null
            ? EmptyState(icon: Icons.search_off, title: l10n.taskNotFound)
            : _Details(view: v),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.view});

  final TaskView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final task = view.task;
    final config = ref.watch(taskConfigProvider);
    final now =
        ref.watch(minuteTickerProvider).value ?? ref.watch(clockProvider).now();
    final active = ref.watch(activeTaskProvider);
    final checks = ref.watch(locationChecksProvider(task.id)).value ?? const [];
    final lastCheck = checks.isEmpty ? null : checks.last;

    // Why the task can't be started (ignoring the GPS step, which comes next).
    final blocker = TaskStateMachine.check(
      action: TaskAction.start,
      task: task,
      status: view.status,
      config: config,
      now: now,
      otherActiveTaskId: active?.id,
      hasVerifiedStartCheck: true,
    );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(view.status, large: true),
              ),
              const SizedBox(height: 16),
              CardSection(
                title: l10n.taskInformation,
                children: [
                  InfoRow(
                    icon: Icons.category_outlined,
                    label: l10n.jobType(task.jobType),
                    value: task.projectName,
                  ),
                  InfoRow(
                    icon: Icons.business,
                    label: l10n.customer,
                    value: task.customerName,
                  ),
                  InfoRow(
                    icon: Icons.event,
                    label: l10n.scheduledDate,
                    value: YerevanTime.date(task.scheduledStart),
                  ),
                  InfoRow(
                    icon: Icons.schedule,
                    label: l10n.scheduledTime,
                    value:
                        '${YerevanTime.hm(task.scheduledStart)} – ${YerevanTime.hm(task.scheduledEnd)}',
                  ),
                  InfoRow(
                    icon: Icons.badge_outlined,
                    label: l10n.yourRole,
                    value: task.isLead ? l10n.roleLead : l10n.roleMember,
                  ),
                  if (task.instructions.isNotEmpty)
                    InfoRow(
                      icon: Icons.description_outlined,
                      label: l10n.instructions,
                      value: task.instructions,
                    ),
                ],
              ),
              if (task.crew.isNotEmpty)
                CardSection(
                  title: l10n.crew,
                  children: [
                    for (final m in task.crew)
                      InfoRow(
                        icon: m.role == TaskRole.lead
                            ? Icons.engineering
                            : Icons.person_outline,
                        label: m.role == TaskRole.lead
                            ? l10n.roleLead
                            : l10n.roleMember,
                        value: m.fullName,
                        trailing: m.phone == null
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.call),
                                onPressed: () => callPhone(m.phone!),
                              ),
                      ),
                    if (task.siteContactName != null)
                      InfoRow(
                        icon: Icons.contact_phone_outlined,
                        label: l10n.siteContact,
                        value: task.siteContactName!,
                        trailing: task.siteContactPhone == null
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.call),
                                onPressed: () =>
                                    callPhone(task.siteContactPhone!),
                              ),
                      ),
                  ],
                ),
              CardSection(
                title: l10n.workLocation,
                children: [
                  _MapPreview(task: task, radius: task.radiusM(config)),
                  const SizedBox(height: 8),
                  InfoRow(
                    icon: Icons.place_outlined,
                    label: l10n.address,
                    value: '${task.siteName}, ${task.address}',
                  ),
                  if (task.accessNotes.isNotEmpty)
                    InfoRow(
                      icon: Icons.info_outline,
                      label: l10n.accessNotes,
                      value: task.accessNotes,
                    ),
                  InfoRow(
                    icon: Icons.gps_fixed,
                    label: l10n.coordinates,
                    value:
                        '${task.latitude.toStringAsFixed(5)}, ${task.longitude.toStringAsFixed(5)}',
                  ),
                  InfoRow(
                    icon: Icons.radar,
                    label: l10n.workRadius,
                    value: l10n.metersValue(
                      task.radiusM(config).toStringAsFixed(0),
                    ),
                  ),
                  if (lastCheck != null)
                    InfoRow(
                      icon: Icons.my_location,
                      label: l10n.currentDistance,
                      value:
                          '${l10n.metersValue(lastCheck.distanceM.toStringAsFixed(0))} · ${YerevanTime.hm(lastCheck.capturedAt)}',
                    ),
                  const SizedBox(height: 8),
                  SecondaryButton(
                    icon: Icons.navigation_outlined,
                    label: l10n.navigate,
                    onPressed: () => openNavigation(
                      task.latitude,
                      task.longitude,
                      task.siteName,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _BottomAction(view: view, blocker: blocker),
      ],
    );
  }
}

class _BottomAction extends ConsumerWidget {
  const _BottomAction({required this.view, required this.blocker});

  final TaskView view;
  final TaskActionError? blocker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final config = ref.watch(taskConfigProvider);
    final status = view.status;

    final Widget child;
    if (status.isActive) {
      child = PrimaryButton(
        icon: Icons.timer_outlined,
        label: l10n.openWorkScreen,
        onPressed: () => context.go('/work'),
      );
    } else if (status == TaskDisplayStatus.synchronizationFailed) {
      final reason = ref.watch(syncFailureMessageProvider(view.id)).value;
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MessageBanner(
            message: reason ?? l10n.syncFailedBanner,
            color: AppColors.error,
            icon: Icons.sync_problem,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            icon: Icons.refresh,
            label: l10n.retry,
            onPressed: () async {
              await ref.read(outboxProvider).retryTask(view.id);
              await ref.read(syncServiceProvider).syncNow();
            },
          ),
        ],
      );
    } else if (status.isFinished || status == TaskDisplayStatus.cancelled) {
      child = status == TaskDisplayStatus.cancelled
          ? MessageBanner(
              message: l10n.errCancelled,
              color: AppColors.error,
              icon: Icons.cancel_outlined,
            )
          : SecondaryButton(
              icon: Icons.history,
              label: l10n.goToHistory,
              onPressed: () => context.go('/history/${view.id}'),
            );
    } else if (blocker != null) {
      child = MessageBanner(
        message: l10n.actionError(
          blocker!,
          view.task,
          config.startWindowMinutesBefore,
        ),
        color: AppColors.warning,
        icon: Icons.lock_clock,
      );
    } else {
      child = PrimaryButton(
        key: const Key('details.verify'),
        icon: Icons.my_location,
        label: l10n.verifyMyLocation,
        onPressed: () => context.push('/tasks/${view.id}/verify-location'),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(blurRadius: 8, color: Color(0x22000000))],
        ),
        child: child,
      ),
    );
  }
}

/// Location preview without a maps SDK/API key: a schematic target with the
/// geofence radius. "Navigate" opens a real map app.
class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.task, required this.radius});

  final Task task;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    height: 140,
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.outline),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
        ),
        const Icon(Icons.location_on, size: 44, color: AppColors.charcoal),
        Positioned(
          bottom: 8,
          right: 12,
          child: Text(
            '⌀ ${(radius * 2).toStringAsFixed(0)} m',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}
