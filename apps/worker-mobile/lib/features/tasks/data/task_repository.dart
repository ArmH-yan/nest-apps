import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/nest_api.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/mappers.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/yerevan_time.dart';
import '../../completion/domain/completion_models.dart';
import '../domain/task.dart';
import '../domain/task_config.dart';

/// Tasks are served from the local cache (works offline) and refreshed from
/// the API when online. Local unsynced state is layered on top by providers.
class TaskRepository {
  TaskRepository({
    required AppDatabase db,
    required NestApi api,
    required Clock clock,
    required SharedPreferences prefs,
  }) : _db = db,
       _api = api,
       _clock = clock,
       _prefs = prefs;

  final AppDatabase _db;
  final NestApi _api;
  final Clock _clock;
  final SharedPreferences _prefs;

  static const _configKey = 'cache.task_config';
  static const _refreshedKey = 'cache.tasks_refreshed_at';

  List<CatalogItem>? _catalog;

  Stream<List<Task>> watchTasks() =>
      (_db.select(_db.cachedTasks)
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledStart)]))
          .watch()
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  Stream<Task?> watchTask(String id) =>
      (_db.select(_db.cachedTasks)..where((t) => t.id.equals(id)))
          .watchSingleOrNull()
          .map((r) => r?.toDomain());

  Future<Task?> getTask(String id) => watchTask(id).first;

  DateTime? get lastRefreshedAt {
    final raw = _prefs.getString(_refreshedKey);
    return raw == null ? null : DateTime.parse(raw);
  }

  /// Pulls tasks for a window around today and the config. Throws ApiException
  /// when offline — callers keep showing the cache.
  Future<void> refresh() async {
    final today = YerevanTime.day(_clock.now());
    final from = YerevanTime.at(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 7));
    final to = from.add(const Duration(days: 22));
    final config = await _api.config();
    final tasks = await _api.tasks(from: from, to: to);

    await _prefs.setString(_configKey, jsonEncode(config.toJson()));
    await _db.batch((b) {
      for (final t in tasks) {
        b.insert(
          _db.cachedTasks,
          CachedTasksCompanion.insert(
            id: t.id,
            scheduledStart: t.scheduledStart,
            payload: jsonEncode(t.toJson()),
            updatedAt: _clock.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    await _prefs.setString(_refreshedKey, _clock.now().toIso8601String());
  }

  /// Last known server config, or defaults before the first refresh.
  TaskConfig get config {
    final raw = _prefs.getString(_configKey);
    if (raw == null) return const TaskConfig();
    return TaskConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Marks a task submitted locally after the server accepted the completion.
  Future<void> markSubmitted(String taskId) async {
    final task = await getTask(taskId);
    if (task == null) return;
    await (_db.update(
      _db.cachedTasks,
    )..where((t) => t.id.equals(taskId))).write(
      CachedTasksCompanion(
        payload: Value(
          jsonEncode(
            task.copyWith(serverStatus: ServerTaskStatus.submitted).toJson(),
          ),
        ),
      ),
    );
  }

  Future<List<CatalogItem>> catalog() async =>
      _catalog ??= await _api.catalog();

  Future<List<ExpectedMaterial>> expectedMaterials(String taskId) =>
      _api.expectedMaterials(taskId);
}
