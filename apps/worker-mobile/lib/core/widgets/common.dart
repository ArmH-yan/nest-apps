import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../time/yerevan_time.dart';
import '../ui/l10n_ext.dart';
import 'buttons.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(letterSpacing: 0.8, color: AppColors.textSecondary),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class CardSection extends StatelessWidget {
  const CardSection({super.key, required this.children, this.title});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
          ],
          ...children,
        ],
      ),
    ),
  );
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: Icons.error_outline,
      title: l10n.error(error),
      action: onRetry == null
          ? null
          : SecondaryButton(label: l10n.tryAgain, onPressed: onRetry),
    );
  }
}

/// Coloured message box (warnings, errors, info).
class MessageBanner extends StatelessWidget {
  const MessageBanner({
    super.key,
    required this.message,
    required this.color,
    this.icon = Icons.info_outline,
    this.action,
  });

  final String message;
  final Color color;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.5)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
        ?action,
      ],
    ),
  );
}

/// Yes/no dialog with large buttons. Returns true on confirm.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: content),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: confirmLabel,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 8),
            SecondaryButton(
              label: context.l10n.cancel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// "Today 09:00 – 17:00" / "Tomorrow …" / "09.10.2026 …"
String scheduleText(
  BuildContext context,
  DateTime start,
  DateTime end,
  DateTime now,
) {
  final l10n = context.l10n;
  final day = YerevanTime.day(start);
  final today = YerevanTime.day(now);
  final dayLabel = day == today
      ? l10n.today
      : day == today.add(const Duration(days: 1))
      ? l10n.tomorrow
      : YerevanTime.date(start);
  return '$dayLabel · ${YerevanTime.hm(start)} – ${YerevanTime.hm(end)}';
}
