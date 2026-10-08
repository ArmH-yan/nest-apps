# CLAUDE.md — nest-apps

Operations platform for **NEST**, a company that installs safety-net and dust-protection systems on construction sites in Armenia.

## Agent rules

- Read `CLAUDE.md` and the relevant source-of-truth docs before making non-trivial changes.
- Inspect the existing repository before creating files or changing architecture.
- Do not introduce a new dependency, framework, service, or architectural pattern unless it is necessary for the requested task.
- Do not rewrite working code merely to match a preferred style.
- Do not change database schema without an Alembic migration.
- Do not change API contracts without updating the relevant documentation and clients.
- Do not modify `F:\nest_web` unless explicitly asked.
- Do not initialize Git unless explicitly asked.
- Never claim a feature is complete without running the relevant tests/checks.
- If requirements conflict, stop and ask rather than silently choosing one.
- If a requirement is ambiguous but does not affect architecture or data integrity, choose the simplest reasonable implementation and document the assumption.

## Source-of-truth docs (read before non-trivial work)

- `ARCHITECTURE.md`: the whole system, including the data model, lifecycles, API and build order. Use its section numbers when you refer to it (e.g. "§18 Worker API").
- `docs/WORKER_APP_SPEC.md`: the build spec for the Flutter worker app.

When a change affects the design, update these docs **in the same change**. Keep the two files consistent with each other: table and field names, status enums, endpoints. If code and docs disagree, ask which one is right; don't silently follow either.

## Settled decisions (don't re-propose alternatives)

- **Solo developer, fewer than 20 workers.** Choose the simplest solution that works. No microservices, Kubernetes, Kafka, Redis/Celery or BigQuery in v1 (§43).
- **Worker app = Flutter.** It was chosen deliberately for GPS geofencing, timestamp-based timers, offline-first work, photos and push. Do not suggest a PWA.
- **No Planfix or any other third-party task/CRM system.** The NEST FastAPI backend with PostgreSQL is the only system of record.
- **Manager/admin app = Next.js.** Backend = FastAPI + SQLAlchemy 2 (async) + Alembic + Pydantic. Database = PostgreSQL.
- **Each crew member tracks their own time.** A worker app "Task" is a `visit_assignment` (one worker × one visit). The crew LEAD also records materials and inspection checklists.
- **Quotes and on-site materials tracking are v1.**
- Reporting = Metabase on read-only `reporting` views.
- **Push = Firebase Cloud Messaging** (Android; APNs for iOS via FCM). Firebase is **only** the push transport: never add Firebase Auth, Firestore, Realtime Database, Storage, App Distribution, Crashlytics/Analytics or other Firebase services. No Supabase. Notification content and read state live in PostgreSQL (ARCHITECTURE §26).

## Repository layout (see ARCHITECTURE §5)

```text
apps/api/             FastAPI (app/modules/<feature>/{router,schemas,models,service}.py)
apps/manager-web/     Next.js manager/admin app
apps/worker-mobile/   Flutter "NEST Worker" (org am.nest, app id am.nest.worker)
infrastructure/       Caddy, prod compose, backups
docs/
```

Phase 1 (§41) is built: the worker app's full mock workflow, and backend auth/users/audit + CI (`.github/workflows/ci.yml`). Scheduling and the `/worker/*` API are Phase 2. The worker app's Dart package is `nest_worker`, and its Android flavors are `dev` and `prod` (`--flavor` is required). Check what is actually on disk before assuming a file exists. Git is initialized; never commit unless asked.

## Related repo: public website

- `F:\nest_web` (GitHub `ArmH-yan/nest_web`) is a Next.js 15 marketing site in its own repo. **Don't edit it unless asked.**
- Its contact form goes `src/components/contact-form.tsx` → `src/app/api/contact/route.ts` → `src/lib/contact.ts` (`submitContact`, using env vars `CONTACT_API_URL` / `CONTACT_API_KEY`).
- It will POST to `POST /api/v1/public/assessment-requests` with a service key (ARCHITECTURE §12). The backend must accept its payload field names unchanged: `name, company, phone, email, service, projectType, message`.
- Service slugs must match `nest_web/src/config/services.ts` (`safety-system`, `dust-protection`).
- Its README/AGENTS.md still mention a Planfix webhook. That is outdated.

## Backend conventions (apps/api)

- Router → Service → SQLAlchemy session. There is **no repository layer** on the backend. Business rules, transitions, audit logging and task enqueueing go in `service.py`.
- Every lifecycle (request, project, job, visit, assignment, quote) is defined as **one transition table** `(from, to, allowed_roles, guard)` with unit tests.
- Use `timestamptz` everywhere, stored in UTC and displayed in `Asia/Yerevan`. Money is `numeric(12,2)` + currency `AMD`, never float.
- Records created on a device use client-generated UUID primary keys, and `/worker/*` writes are **idempotent PUTs**:
  - same body → 200
  - conflicting body on a finalized record → 409
- The database enforces invariants with `btree_gist` exclusion constraints: no overlapping assignments per worker, and no overlapping time entries.
- GPS data and device time are **untrusted**. Store them, recompute on the server, and **flag** problems instead of rejecting the data.
- Errors use the shape `{"error": {"code", "message", "details"}}` with stable codes, because the app maps codes to localized messages.
- Authorization happens in the query (`WHERE worker_id = :me`). If a worker requests another worker's object, return 404.
- Background work uses a Postgres-backed queue (procrastinate) and is enqueued in the same transaction as the business change.
- Schema changes are made only through Alembic migrations.
- Tests run against a real PostgreSQL instance (Docker), not SQLite.

## Flutter conventions (apps/worker-mobile)

- Feature-based layout: `data / domain / presentation`. Use Riverpod, GoRouter, Dio, freezed/json_serializable, drift (local DB + outbox) and flutter_secure_storage (tokens).
- UI never calls HTTP, GPS or storage directly. Go through repository/service interfaces.
  - The Mock/Api switch is the `NestApi` interface (`MockNestApi` now, HTTP later), chosen only in `nestApiProvider` from `USE_MOCKS`. Repositories are shared by both modes (see WORKER_APP_SPEC "As built").
  - Widget tests: use `test/support/app_harness.dart`. Its `settle()` interleaves real and fake time because drift completes queries on real async time; `pumpAndSettle` never settles because of the 1 s ticker.
- **Timers come from stored timestamps**, using an injectable `Clock`. Never use a counter as the source of truth.
- Every write = local change + outbox item in **one drift transaction**.
- Strings go in ARB files (hy/ru/en). Colors and text styles come only from `core/theme`.
- Never put secrets in the app. Config comes from `--dart-define` (`API_BASE_URL`, `USE_MOCKS`), with `dev`/`prod` flavors.

## Manager web conventions (apps/manager-web)

- Generate the typed API client from FastAPI's `openapi.json` (`openapi-typescript`). Don't hand-write API types.
- Auth uses HttpOnly cookies and CSRF protection on state-changing requests.

## Commands

One-time setup:

```bash
cp .env.example .env                    # repo root; used by docker compose AND apps/api (set JWT_SECRET)
cd apps/api && python -m venv .venv && .venv/Scripts/python -m pip install -e ".[dev]"
cd apps/manager-web && npm install && cp .env.example .env.local
```

```bash
# database (repo root)
docker compose up -d db                 # PostgreSQL 17 on localhost:5433 (+ nest_test DB)

# backend (apps/api, venv at apps/api/.venv; on Bash use .venv/Scripts/<tool>)
.venv/Scripts/uvicorn app.main:app --reload --port 8000     # http://localhost:8000/health, /docs
.venv/Scripts/alembic upgrade head      # migrations (URL from DATABASE_URL)
.venv/Scripts/alembic revision --autogenerate -m "..."      # new migration (review it!)
.venv/Scripts/ruff format . && .venv/Scripts/ruff check . && .venv/Scripts/mypy app tests alembic/env.py
.venv/Scripts/pytest                    # uses TEST_DATABASE_URL (nest_test), migrates it to head
.venv/Scripts/python -m app.cli create-user --phone +374... --first-name A --last-name B --role ADMIN   # prompts for the password; WORKER needs --employee-code

# manager web (apps/manager-web)
npm run dev                             # http://localhost:3001
npm run lint && npm run typecheck && npm run build
npm run gen:api                         # regenerate src/lib/api/schema.d.ts (API must be running)

# worker app (apps/worker-mobile; in Git Bash first: export PATH="/f/flutter/flutter-sdk/bin:$PATH")
dart run build_runner build --delete-conflicting-outputs   # after changing freezed/json/drift code
flutter gen-l10n                        # after changing ARB files
dart format lib test && flutter analyze && flutter test
flutter run --flavor dev                # mocks by default (USE_MOCKS=true)
flutter run --flavor dev --dart-define=USE_MOCKS=false --dart-define=API_BASE_URL=http://10.0.2.2:8000
flutter build apk --flavor dev --debug
```

## Accepted development assumptions

These are documented in ARCHITECTURE §34 and were accepted by the user on 2026-10-07:

- PostgreSQL 17, running in Docker on host port 5433.
- Docker Compose runs only PostgreSQL. The API runs from the local venv (`apps/api/.venv`).
- `GET /health` lives outside `/api/v1`.
- The manager web app has no Tailwind for now.

## Known issues (deliberately deferred)

- `apps/manager-web`: `npm audit` reports 5 high-severity advisories for the transitive `braces` package. ESLint's tooling pulls it in; it is dev-only and not part of the built app.
  - **Do not run `npm audit fix --force`**, and don't make unrelated dependency upgrades.
  - Dependency and security updates will be done deliberately in a separate step.

Before reporting work as done, run the formatter, linter/analyzer and tests for each app you touched, and report any failures honestly.

## Environment

- Windows 11. Both PowerShell 5.1 and Git Bash are available; Bash paths look like `/f/nest-apps`.
- Installed: Python 3.14, Node 24, Docker 29.
- **Flutter 3.47.3 (Dart 3.13.3)** is installed at `F:\flutter\flutter-sdk` and is on the user PATH. A shell started before the PATH change may not see it; then call `F:\flutter\flutter-sdk\bin\flutter.bat` directly. Use only this SDK. There is a second, unused SDK at `C:\Users\armhy\develop\flutter`, and the user PATH entry `C:\tools\dart-sdk\bin` points to a folder that doesn't exist.
- The Android toolchain is OK: SDK 37, licenses accepted, Java from Android Studio's bundled JBR (`F:\Android\Android Studio\jbr`).
  - Installed for Flutter builds: NDK `28.2.13676358` (r28c), plus Platform 35 and CMake 3.22.1, which Gradle installed automatically.
  - **`sdkmanager` is deprecated here and breaks on `;` package names.** Install SDK packages with the new CLI instead: `C:\Users\armhy\AppData\Local\Android\sdk\cmdline-tools\latest\bin\android.exe --sdk=C:\Users\armhy\AppData\Local\Android\sdk sdk install ndk/<version>` (list packages with `sdk list --all`).
- A native Windows PostgreSQL already listens on **5432**; the project's Docker PostgreSQL is mapped to host port **5433**. Don't stop or reuse the native one.
- Docker Desktop must be running for `docker compose`.
- `apps/worker-mobile/android/gradle.properties` sets `kotlin.incremental=false`. The project is on `F:` and the pub cache is on `C:`, which breaks Kotlin incremental compilation of plugins on Windows. Keep the setting.
- Emulator: AVD `Pixel_9_Pro` (Android 16, API 36). Launch it with `flutter emulators --launch Pixel_9_Pro`; if it hangs "offline", restart it with `emulator -avd Pixel_9_Pro -no-snapshot-load`.
- Local ports:
  - nest_web: 3000
  - manager-web: 3001
  - API: 8000 (Swagger at `/docs`)
  - Postgres (Docker): 5433 → container 5432
  - MinIO: 9000
  - Metabase: 3030

## Working preferences

- The user is the project owner and the sole developer. Give a recommendation, not a survey of options.
- Explain trade-offs briefly when you suggest changing a settled decision, and then only if there is a strong new reason.
- Keep the MVP scope from ARCHITECTURE §42. Put anything else in "later".
