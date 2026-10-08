import 'package:drift/native.dart';
import 'package:nest_worker/core/api/mock_data.dart';
import 'package:nest_worker/core/api/mock_nest_api.dart';
import 'package:nest_worker/core/location/location_service.dart';
import 'package:nest_worker/core/media/photo_capture_service.dart';
import 'package:nest_worker/core/storage/app_database.dart';
import 'package:nest_worker/core/sync/outbox.dart';
import 'package:nest_worker/core/sync/sync_service.dart';
import 'package:nest_worker/core/time/clock.dart';
import 'package:nest_worker/core/time/yerevan_time.dart';
import 'package:nest_worker/features/auth/domain/worker.dart';
import 'package:nest_worker/features/completion/data/completion_repository.dart';
import 'package:nest_worker/features/completion/data/completion_service.dart';
import 'package:nest_worker/features/profile/data/settings_repository.dart';
import 'package:nest_worker/features/tasks/data/task_repository.dart';
import 'package:nest_worker/features/work/data/work_actions.dart';
import 'package:nest_worker/features/work/data/work_session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns fake file paths instead of opening the camera.
class FakePhotoCapture implements PhotoCaptureService {
  int counter = 0;

  @override
  Future<List<String>> pick(
    PhotoSource source, {
    required String fileStem,
  }) async => ['/fake/${fileStem}_${counter++}.jpg'];
}

/// The real data layer wired by hand: in-memory SQLite, MockNestApi with no
/// latency, a FixedClock at 09:05 Yerevan today.
class Harness {
  Harness._(this.prefs, {GpsSource gps = GpsSource.mockAtSite})
    : clock = FixedClock(YerevanTime.at(2026, 10, 7, 9, 5)),
      db = AppDatabase(NativeDatabase.memory()) {
    api = MockNestApi(clock: clock)..scenario.latency = Duration.zero;
    outbox = Outbox(db, clock);
    tasks = TaskRepository(db: db, api: api, clock: clock, prefs: prefs);
    sessions = WorkSessionRepository(db: db, outbox: outbox, clock: clock);
    completions = CompletionRepository(
      db: db,
      outbox: outbox,
      workSessions: sessions,
    );
    sync = SyncService(
      db: db,
      api: api,
      clock: clock,
      completions: completions,
      tasks: tasks,
    );
    location = MockLocationService(source: gps, clock: clock);
    work = WorkActions(
      tasks: tasks,
      sessions: sessions,
      completions: completions,
      outbox: outbox,
      location: location,
      sync: sync,
      clock: clock,
    );
    completionService = CompletionService(
      completions: completions,
      sessions: sessions,
      tasks: tasks,
      capture: capture,
      sync: sync,
      clock: clock,
    );
  }

  static Future<Harness> create({GpsSource gps = GpsSource.mockAtSite}) async {
    SharedPreferences.setMockInitialValues({});
    final h = Harness._(await SharedPreferences.getInstance(), gps: gps);
    await h.tasks.refresh();
    return h;
  }

  final SharedPreferences prefs;
  final FixedClock clock;
  final AppDatabase db;
  late final MockNestApi api;
  late final Outbox outbox;
  late final TaskRepository tasks;
  late final WorkSessionRepository sessions;
  late final CompletionRepository completions;
  late final SyncService sync;
  late final LocationService location;
  late final WorkActions work;
  late final CompletionService completionService;
  final FakePhotoCapture capture = FakePhotoCapture();

  /// "Install Safety Net – Building A", today 09:00, crew lead, installation.
  static const buildingA = 'asg-101';

  Future<void> dispose() async {
    await sync.dispose();
    await db.close();
  }

  Future<int> outboxCount() => outbox.unsyncedCount();

  Worker get worker => MockData.worker;
}
