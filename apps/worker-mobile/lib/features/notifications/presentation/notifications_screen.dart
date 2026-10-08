import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/time/yerevan_time.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/widgets/common.dart';
import '../domain/app_notification.dart';

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() =>
      ref.read(notificationRepositoryProvider).list();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).list(),
    );
  }

  Future<void> markRead(AppNotification n) async {
    if (n.readAt != null) return;
    try {
      await ref.read(notificationRepositoryProvider).markRead(n.id);
      await refresh();
    } on Object {
      // offline: stays unread, no error for the worker
    }
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

final unreadNotificationsProvider = Provider<int>(
  (ref) =>
      ref
          .watch(notificationsProvider)
          .value
          ?.where((n) => n.readAt == null)
          .length ??
      0,
);

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _icon(NotificationType t) => switch (t) {
    NotificationType.taskAssigned => Icons.assignment_add,
    NotificationType.taskChanged => Icons.edit_calendar,
    NotificationType.taskCancelled => Icons.event_busy,
    NotificationType.taskReminder => Icons.alarm,
    NotificationType.submissionAccepted => Icons.check_circle_outline,
    NotificationType.submissionFailed => Icons.sync_problem,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: items.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.read(notificationsProvider.notifier).refresh(),
        ),
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.notifications_none,
                title: l10n.notificationsEmpty,
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(notificationsProvider.notifier).refresh(),
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final n = list[i];
                    final unread = n.readAt == null;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(_icon(n.type), size: 30),
                      title: Text(
                        n.title,
                        style: TextStyle(
                          fontWeight: unread
                              ? FontWeight.w800
                              : FontWeight.w400,
                        ),
                      ),
                      subtitle: Text(
                        '${n.body}\n${YerevanTime.date(n.createdAt)} ${YerevanTime.hm(n.createdAt)}',
                      ),
                      isThreeLine: true,
                      onTap: () {
                        ref.read(notificationsProvider.notifier).markRead(n);
                        if (n.taskId != null) {
                          context.push('/tasks/${n.taskId}');
                        }
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}
