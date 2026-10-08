/// What an outbox item sends. Order of the enum = dependency order
/// (WORKER_APP_SPEC: location checks → time entries → photos → materials → completion).
enum SyncEntityType { locationCheck, timeEntry, photo, material, completion }

enum SyncItemState { pending, inFlight, failed, done }

class SyncStatus {
  const SyncStatus({
    required this.pending,
    required this.failed,
    required this.isSyncing,
    required this.isOnline,
    this.lastSyncedAt,
  });

  static const initial = SyncStatus(
    pending: 0,
    failed: 0,
    isSyncing: false,
    isOnline: true,
  );

  final int pending;
  final int failed;
  final bool isSyncing;
  final bool isOnline;
  final DateTime? lastSyncedAt;

  SyncStatus copyWith({
    int? pending,
    int? failed,
    bool? isSyncing,
    bool? isOnline,
    DateTime? lastSyncedAt,
  }) => SyncStatus(
    pending: pending ?? this.pending,
    failed: failed ?? this.failed,
    isSyncing: isSyncing ?? this.isSyncing,
    isOnline: isOnline ?? this.isOnline,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
}
