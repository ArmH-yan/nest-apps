# NEST Worker (apps/worker-mobile)

Flutter app for NEST field workers. Build spec: `../../docs/WORKER_APP_SPEC.md`;
conventions: `../../CLAUDE.md`.

- Dart package: `nest_worker`. Android application ID: `am.nest.worker` (`am.nest.worker.dev` for the dev flavor). iOS bundle ID: `am.nest.worker`.
- Flavors: `dev`, `prod` (Android). `--flavor` is required for Android runs and builds.
- Config via `--dart-define`: `API_BASE_URL` (default `http://10.0.2.2:8000`, the emulator's view of the host) and `USE_MOCKS` (default `true`).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed / json / drift
flutter gen-l10n                                           # ARB → lib/core/l10n/generated
dart format lib test && flutter analyze && flutter test
flutter run --flavor dev                                   # needs an emulator or device
flutter build apk --flavor dev --debug
```

Layout:

```text
lib/
  main.dart, app.dart
  core/       config, network (ApiClient), storage (drift DB, secure tokens),
              time (Clock), theme, routing, l10n (ARB + generated), providers.dart
  features/   auth, tasks, work, completion, history, profile, notifications
              (each: data / domain / presentation — empty until built)
test/         mirrors lib/
```

Generated files (`*.g.dart`, `*.freezed.dart`, `lib/core/l10n/generated/`) are committed and
excluded from analysis; regenerate them after changing models, tables or ARB files.
