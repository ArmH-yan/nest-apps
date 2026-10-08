import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Local SQLite database (drift): task cache, work/break sessions, GPS checks,
/// photos, materials, completions and the sync outbox.
///
/// Schema changes: bump [schemaVersion] and add a step to [migration].
@DriftDatabase(
  tables: [
    CachedTasks,
    TimeEntries,
    LocationChecks,
    Photos,
    Materials,
    Completions,
    SyncItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 had no tables (foundation build).
      if (from < 2) await m.createAll();
    },
  );

  /// Wipes all local data (used on logout of a different user).
  Future<void> clearAll() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });

  static QueryExecutor _openConnection() => driftDatabase(name: 'nest_worker');
}
