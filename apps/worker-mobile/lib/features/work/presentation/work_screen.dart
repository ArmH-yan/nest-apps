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
import '../../completion/presentation/completion_draft.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_status.dart';
import '../../tasks/presentation/task_providers.dart';
import '../domain/duration_calculator.dart';
import 'flip_timer.dart';

/// Active-work dashboard (WORKER_APP_SPEC "Work screen"). Every number is
/// computed from stored timestamps on each tick.
class WorkScreen extends ConsumerStatefulWidget {
  const WorkScreen({super.key});

  @override
  ConsumerState<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends ConsumerState<WorkScreen> {
  bool _busy = false;

  /// The face the timer turns to as soon as it is tapped, before the write
  /// lands. If the action fails, it is cleared and the dial turns back.
  bool? _flipTarget;

  Future<void> _toggle(bool onBreak, Task task) async {
    final actions = ref.read(workActionsProvider);
    setState(() => _flipTarget = !onBreak);
    final ok = await _run(
      () => onBreak ? actions.resumeWork(task) : actions.startBreak(task),
    );
    if (!ok && mounted) setState(() => _flipTarget = null);
  }

  Future<bool> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      return true;
    } on Object catch (e) {
      if (mounted) showMessage(context, context.l10n.error(e));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = ref.watch(activeTaskProvider);

    if (active == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navWork)),
        body: Column(
          children: [
            const SyncStatusBanner(),
            Expanded(
              child: EmptyState(
                icon: Icons.timer_off_outlined,
                title: l10n.noActiveTaskTitle,
                body: l10n.noActiveTaskBody,
                action: SecondaryButton(
                  label: l10n.myTasks,
                  onPressed: () => context.go('/tasks'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final task = active.task;
    final now =
        ref.watch(tickerProvider).value ?? ref.watch(clockProvider).now();
    final totals = DurationCalculator.totals(active.entries, now);
    final firstStart = DurationCalculator.firstStart(active.entries);
    final onBreak = active.status == TaskDisplayStatus.onBreak;
    // The stored state caught up with the tap: follow it again.
    if (_flipTarget == onBreak) _flipTarget = null;
    final stateColor = onBreak ? AppColors.onBreak : AppColors.working;
    final checks = ref.watch(locationChecksProvider(task.id)).value ?? const [];
    final startCheck = checks.where((c) => c.verified).firstOrNull;
    final actions = ref.read(workActionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navWork)),
      body: Column(
        children: [
          const SyncStatusBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  task.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                // Impossible to confuse: colour, icon and label all change.
                Container(
                  key: Key(onBreak ? 'work.state.break' : 'work.state.working'),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: stateColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        onBreak ? Icons.coffee : Icons.construction,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        onBreak ? l10n.statusOnBreak : l10n.statusInProgress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: FlipTimer(
                    showBreak: _flipTarget ?? onBreak,
                    work: totals.work,
                    breakTime: totals.breakTime,
                    onTap: _busy ? null : () => _toggle(onBreak, task),
                  ),
                ),
                const SizedBox(height: 28),
                CardSection(
                  children: [
                    InfoRow(
                      icon: Icons.play_circle_outline,
                      label: l10n.startedLabel,
                      value: firstStart == null
                          ? '—'
                          : YerevanTime.hm(firstStart),
                    ),
                    InfoRow(
                      icon: Icons.location_on_outlined,
                      label: l10n.locationLabel,
                      value: startCheck == null
                          ? '—'
                          : '✓ ${l10n.verified} (${l10n.metersValue(startCheck.distanceM.toStringAsFixed(0))})',
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onBreak)
                    PrimaryButton(
                      key: const Key('work.resume'),
                      icon: Icons.play_arrow_rounded,
                      label: l10n.resumeWorking,
                      color: AppColors.working,
                      loading: _busy,
                      onPressed: () => _run(() => actions.resumeWork(task)),
                    )
                  else
                    PrimaryButton(
                      key: const Key('work.break'),
                      icon: Icons.pause_rounded,
                      label: l10n.stopAndStartBreak,
                      color: AppColors.onBreak,
                      loading: _busy,
                      onPressed: () => _run(() => actions.startBreak(task)),
                    ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    key: const Key('work.finish'),
                    icon: Icons.flag_outlined,
                    label: l10n.finishTask,
                    onPressed: _busy
                        ? null
                        : () async {
                            final ok = await showConfirmDialog(
                              context,
                              title: l10n.finishConfirmTitle,
                              content: Text(l10n.finishConfirmBody),
                              confirmLabel: l10n.finish,
                            );
                            if (!ok || !context.mounted) return;
                            ref
                                .read(completionDraftProvider.notifier)
                                .begin(task, ref.read(clockProvider).now());
                            await context.push('/work/complete');
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
