import 'package:drift/drift.dart';

/// Local tables (WORKER_APP_SPEC "Offline support and sync").
/// Every write that must reach the server is paired with a [SyncItems] row
/// in the same transaction.

/// Server task list cache. `payload` is the Task's local JSON form.
@DataClassName('CachedTaskRow')
class CachedTasks extends Table {
  TextColumn get id => text()();
  DateTimeColumn get scheduledStart => dateTime()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TimeEntryRow')
class TimeEntries extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get kind => text()(); // TimeEntryKind.name
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get startLocationCheckId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocationCheckRow')
class LocationChecks extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get purpose => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get accuracyM => real()();
  BoolColumn get isMocked => boolean()();
  DateTimeColumn get capturedAt => dateTime()();
  RealColumn get distanceM => real()();
  RealColumn get radiusM => real()();
  BoolColumn get verified => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PhotoRow')
class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get localPath => text().nullable()();
  TextColumn get kind => text()();
  DateTimeColumn get takenAt => dateTime()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get uploadState => text()();
  RealColumn get progress => real().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MaterialRow')
class Materials extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get catalogItemId => text()();
  TextColumn get itemName => text()();
  TextColumn get unit => text()();
  RealColumn get quantity => real()();
  TextColumn get movement => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CompletionRow')
class Completions extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().unique()();
  TextColumn get workerId => text()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get completionLocationCheckId => text().nullable()();
  TextColumn get comment => text().nullable()();
  IntColumn get totalWorkMs => integer()();
  IntColumn get totalBreakMs => integer()();

  /// Server accepted it (task is `completed`).
  BoolColumn get confirmed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The outbox. Processed FIFO per task by SyncService.
@DataClassName('SyncItemRow')
class SyncItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get taskId => text()();
  TextColumn get entityType => text()(); // SyncEntityType.name
  TextColumn get entityId => text()();
  TextColumn get payload => text()(); // JSON body
  TextColumn get state => text()(); // SyncItemState.name
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get lastErrorMessage => text().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
