import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Local SQLite database (drift): task cache, work/break sessions, photos and
/// the sync outbox will live here (WORKER_APP_SPEC "Offline support and sync").
///
/// Foundation only: no tables yet. Each feature adds its tables to
/// `@DriftDatabase(tables: [...])`, bumps [schemaVersion] and adds a migration step.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(name: 'nest_worker');
}
