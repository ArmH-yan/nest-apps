import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/money_format.dart';
import '../domain/earnings_summary.dart';

/// This month's approved earnings. Emits the cached value first, then the
/// fresh one. null means nothing is known yet (offline, no cache).
final earningsProvider = StreamProvider<EarningsSummary?>((ref) async* {
  final repo = ref.watch(earningsRepositoryProvider);
  final cached = repo.cached();
  yield cached;
  try {
    yield await repo.refresh();
  } on ApiException {
    // Offline or server error: keep showing the cached value.
  }
});

/// Tasks-screen header counters: works done, then money earned (right).
/// Both cover manager-approved tasks in the current Yerevan month.
class EarningsHeaderStats extends ConsumerWidget {
  const EarningsHeaderStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(earningsProvider).value;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatPill(
          key: const Key('header.worksDone'),
          icon: Icons.task_alt,
          text: summary == null ? '—' : '${summary.approvedTasks}',
          tooltip: context.l10n.worksDoneThisMonth,
          onTap: () => _showDetails(context, summary),
        ),
        const SizedBox(width: 6),
        _StatPill(
          key: const Key('header.earned'),
          text: summary == null
              ? '— ֏'
              : formatMoney(summary.approvedAmount, currency: summary.currency),
          tooltip: context.l10n.earnedThisMonth,
          highlight: true,
          onTap: () => _showDetails(context, summary),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context, EarningsSummary? summary) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.earningsTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              if (summary == null)
                Text(l10n.earningsUnavailable, style: theme.textTheme.bodyLarge)
              else ...[
                _DetailRow(
                  icon: Icons.task_alt,
                  label: l10n.worksDoneThisMonth,
                  value: '${summary.approvedTasks}',
                ),
                _DetailRow(
                  icon: Icons.payments_outlined,
                  label: l10n.earnedThisMonth,
                  value: formatMoney(
                    summary.approvedAmount,
                    currency: summary.currency,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                l10n.earningsApprovedOnly,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    super.key,
    this.icon,
    required this.text,
    required this.tooltip,
    required this.onTap,
    this.highlight = false,
  });

  final IconData? icon;
  final String text;
  final String tooltip;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final fg = highlight ? AppColors.onPrimary : Colors.white;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: highlight
            ? AppColors.primary
            : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 4),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
