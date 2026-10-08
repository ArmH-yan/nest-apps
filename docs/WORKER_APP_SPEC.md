# NEST Worker — Flutter App Build Spec

You are building a production-quality Flutter mobile application from an empty folder (`apps/worker-mobile/` in the `nest-apps` monorepo).

Read `ARCHITECTURE.md` (repo root) first. It defines:
- the backend data model: §8
- the lifecycles: §11
- the worker API: §18
- GPS and timer rules: §19
- offline sync: §23

This spec must stay consistent with those sections.

---

## PROJECT

Application name: **NEST Worker**

NEST Worker is the mobile app for NEST field workers, who install safety nets and dust protection on construction sites in Armenia.

Workers:
- receive tasks assigned by managers in the NEST manager web app
- travel to the site and verify their GPS location
- track work and break time
- record materials (crew lead)
- upload photos of completed work
- submit the completed task

All data goes to the **NEST backend** (FastAPI, `/api/v1/worker/*`). There is **no third-party task system** (no Planfix, no CRM).

```text
NEST Worker (Flutter)  →  NEST API (FastAPI)  →  PostgreSQL
```

For this build phase, implement the full app against **mock repositories**. Structure it so that the API repositories can replace the mocks later without touching any UI code.

---

## DEFINITIONS

- **Task** = one worker's assignment to one visit (one day) of a job. On the backend this is a `visit_assignment`, and its ID is the task ID.
- A multi-day installation shows up as a separate task for each day.
- A crew of 3 workers means 3 separate tasks for the same visit, one per worker.
- Every worker verifies location, runs their own timer and submits their own completion.
- One crew member has the role **LEAD**. The lead has extra completion steps (materials, inspection checklist).

---

## IMPORTANT DEVELOPMENT RULES

- Start from an empty folder and initialize a Flutter project (`org: am.nest`, app id `am.nest.worker`).
- Use a clean, feature-based architecture (presentation / domain / data).
- Never put HTTP calls, GPS calls or storage calls inside widgets.
- Add a dependency only when it provides real value.

### Packages

| Concern | Package |
|---|---|
| UI | Flutter, Material 3 |
| State | `flutter_riverpod` (+ `riverpod_annotation` / generator optional) |
| Navigation | `go_router` |
| HTTP | `dio` |
| Models | `freezed` + `json_serializable` |
| Local database (tasks cache, sessions, outbox) | `drift` (SQLite) |
| Secure session storage (tokens) | `flutter_secure_storage` |
| Small preferences (language, last tab) | `shared_preferences` |
| GPS | `geolocator` |
| Photos | `image_picker` (camera + gallery; it also resizes/compresses, so no separate compression package) |
| Connectivity | `connectivity_plus` |
| IDs | `uuid` |
| Map preview | v1: schematic site/radius preview + "Navigate" (`geo:` intent → Google Maps / Yandex Navigator) via `url_launcher`. `google_maps_flutter` needs an API key and is deferred |
| Localization | `flutter_localizations` + ARB files (`intl`) |
| Push (later phase; stub interface now) | `firebase_core` + `firebase_messaging` only — FCM is the push transport (APNs on iOS). No other Firebase packages (no Auth, Firestore, Realtime Database, Storage, Crashlytics, Analytics) |

**Why drift instead of SharedPreferences for app data:** the active session, multiple work/break entries, photo queue and outbox must be written atomically and survive the app being killed. SharedPreferences is only for small preferences.

### Configuration

- `--dart-define=API_BASE_URL=...`
- `--dart-define=USE_MOCKS=true|false`
- Build flavors `dev` and `prod`.
- No secrets in source code.

---

## TARGET PLATFORM

- Primary: **Android** (min SDK 24).
- Keep it compatible with iOS where practical: add permission strings in Info.plist and avoid Android-only APIs, except optional ones such as WorkManager background sync.
- Designed for phones.

---

## DESIGN SYSTEM

The visual identity is based on construction safety.

Colors:
- Construction yellow (primary)
- Dark charcoal / black
- White
- Light gray
- Plus semantic success / warning / error colors

The app should feel professional, industrial, modern, minimal and high contrast. It must be easy to read outdoors and extremely simple for workers.

- Material 3.
- No heavy gradients, decorative animations or complicated dashboards.
- Large buttons (min height 56dp), large readable text, clear icons.
- Rounded cards with subtle elevation.
- Important actions must be visually obvious.

Create a centralized theme (`core/theme`): `AppColors`, `AppTextStyles`, `AppTheme.light()`. Colors are never hard-coded in widgets. Tokens: `primary`, `onPrimary`, `background`, `surface`, `textPrimary`, `textSecondary`, `success`, `warning`, `error`, `working`, `onBreak`.

Reusable components (`core/widgets`):

```text
PrimaryButton · SecondaryButton · DangerButton
TaskCard · StatusBadge · TimerDisplay · SectionHeader · InfoRow
LocationStatusCard · PhotoGrid · SyncStatusBanner
EmptyState · ErrorState · LoadingState · ConfirmDialog
```

---

## LOCALIZATION

Languages: **Armenian (hy)**, **Russian (ru)**, **English (en)**. The default is the device language, falling back to hy.

- All user-facing strings go in ARB files. No hard-coded strings in widgets.
- The user can change the language in Profile.
- Dates and times are shown in `Asia/Yerevan` using 24h format.

---

## NAVIGATION

A bottom navigation bar with: **Tasks · Work · History · Profile**.

GoRouter routes:

```text
/login
/tasks
/tasks/:taskId
/tasks/:taskId/verify-location
/work                         (active task; empty state if none)
/work/complete                (completion flow)
/history
/history/:taskId
/profile
/notifications
```

- Redirect to `/login` when there is no session.
- If a task is active (working or on break) when the app opens, show a persistent banner on the Tasks screen that links to `/work`.

---

## AUTHENTICATION

Login screen:
- NEST logo placeholder
- "NEST Worker"
- Phone number field
- Password field
- "Log In" button
- "Forgot password?" link. It opens a dialog: "Contact your manager to reset your password." There is no self-service reset in v1.

Behaviour:
- `AuthRepository` interface with `MockAuthRepository` now and `ApiAuthRepository` later.
- On login, the API returns an access token, a refresh token and the worker profile. Tokens go in `flutter_secure_storage`.
- If the backend sets `mustChangePassword`, show a **Change Password** screen before `/tasks`.
- The session persists across restarts. **Logging out with unsynced outbox items** shows a warning: "You have N unsynced items. Logging out will keep them on this device until you log in again." Do not delete them.
- After login, go to `/tasks`.

---

## DOMAIN MODEL

The domain models live in `features/*/domain` and are independent of API DTOs.

```text
Worker            id, fullName, employeeCode, phone, companyName, locale
TaskConfig        defaultGeofenceRadiusM, maxLocationAccuracyM, minCompletionPhotos,
                  startWindowMinutesBefore, minSupportedAppVersion
Task              id (assignment id), jobId, visitId, jobType (survey | installation |
                  inspection | maintenance | dismantling), title, projectName, customerName,
                  description/instructions, siteName, address, latitude, longitude,
                  geofenceRadiusM, accessNotes, siteContactName, siteContactPhone,
                  scheduledStart, scheduledEnd, role (lead | member), crew (List<CrewMember>),
                  serverStatus (assigned | inProgress | submitted | cancelled)
TimeEntry         id (uuid), taskId, kind (work | break), startedAt, endedAt?, startLocationCheckId?
LocationCheck     id (uuid), taskId, purpose (start | resume | completion | manual),
                  latitude, longitude, accuracyM, isMocked, capturedAt,
                  distanceM, radiusM, verified
TaskPhoto         id (uuid), taskId, localPath, kind (before | after | photo), takenAt,
                  latitude?, longitude?, uploadState (pending | uploading(progress) | uploaded | failed)
MaterialEntry     id (uuid), taskId, catalogItemId, itemName, unit, quantity,
                  movement (installed | retrieved | damaged | lost | adjustment), note?
TaskCompletion    id (uuid), taskId, workerId, completedAt, completionLocationCheckId,
                  timeEntries, totalWorkDuration, totalBreakDuration, photos, materials,
                  comment?
SyncItem          id, entityType, entityId, operation, payloadJson, attempts,
                  lastError?, state (pending | inFlight | failed | done), createdAt
AppNotification   id, type, title, body, taskId?, createdAt, readAt?
EarningsSummary   year, month, approvedTasks, approvedAmount (decimal string), currency
```

### Task display status

`TaskDisplayStatus` is **derived** by a pure function `deriveStatus(task, localState, now)`:

```text
upcoming               serverStatus=assigned, scheduled day > today
today                  serverStatus=assigned, scheduled day == today, nothing started
inProgress             open WORK entry locally
onBreak                open BREAK entry locally
waitingForSubmission   completion saved locally, outbox not yet confirmed
synchronizationFailed  completion (or any task item) in outbox state=failed
completed              serverStatus=submitted (or local completion confirmed by server)
cancelled              serverStatus=cancelled
```

### Allowed actions (state machine)

```text
today            → inProgress            (requires verified START location check)
inProgress       → onBreak               (closes WORK entry, opens BREAK entry)
onBreak          → inProgress            (closes BREAK entry, opens WORK entry)
inProgress       → waitingForSubmission  (via completion flow; closes WORK entry)
onBreak          → waitingForSubmission  (closes BREAK entry first)
waitingForSubmission → completed         (server confirms)
waitingForSubmission → synchronizationFailed → waitingForSubmission (retry)
```

Every other transition is rejected with a typed domain error. Rules:
- Only **one active task** per worker at a time.
- A task can only be started on its scheduled day, from `startWindowMinutesBefore` before the scheduled start. Otherwise show "This task is not scheduled for today."
- A cancelled or completed task can't be started.

---

## REPOSITORIES AND SERVICES

These are interfaces in the domain layer. Their implementations live in the data layer.

```dart
abstract class AuthRepository
abstract class WorkerRepository          // me, config
abstract class TaskRepository            // list tasks (today/upcoming), task details, expected materials
abstract class WorkSessionRepository     // local time entries + active task (drift)
abstract class LocationRepository        // persist location checks
abstract class PhotoRepository           // local photo store + upload queue
abstract class MaterialRepository        // catalog items for picker, material entries
abstract class TaskCompletionRepository  // save completion locally + enqueue
abstract class HistoryRepository
abstract class NotificationRepository
```

Services:

```text
LocationService              wraps geolocator: permission, service enabled, current position (+accuracy, isMocked)
LocationVerificationService  pure logic: haversine distance, radius + accuracy rules → LocationVerificationResult
WorkTimerService             start/break/resume/finish; all writes via WorkSessionRepository in one transaction
DurationCalculator           pure: totals from List<TimeEntry> + now
PhotoUploadService           presign → PUT → confirm, progress stream, retry
SyncService                  processes the outbox (see OFFLINE)
ConnectivityService
Clock                        injectable `DateTime now()` (tests)
```

Implementations:
- `Mock*` repositories for now, with deterministic data. They simulate latency and can be switched to simulate failures.
- `Api*` repositories later. They use `ApiClient` (Dio + auth interceptor + refresh-token handling + error mapping).
- API DTOs are kept in `data/dto`, with mappers to domain models.

**The UI must not know whether data comes from mocks or the API.** This is selected by a single provider override based on `USE_MOCKS`.

**As built (Phase 1, 2026-10-07).** The Mock/Api switch sits one level lower than the list above. This avoids duplicating the local-storage and outbox logic in every Mock*/Api* pair:

- **`NestApi`** (`lib/core/api/nest_api.dart`) is the single remote interface. `MockNestApi` is the deterministic in-memory backend with failure switches. An HTTP implementation (on `ApiClient` + DTOs) is added once the backend `/api/v1/worker/*` endpoints exist. `nestApiProvider` is the only place that reads `USE_MOCKS`.
- The **repositories** are concrete classes over the drift DB + `NestApi`, and are the same in mock and API mode:
  - `AuthRepository`
  - `TaskRepository`: task cache, config, catalog, expected materials
  - `WorkSessionRepository`: time entries + location checks
  - `CompletionRepository`: photos, materials, completion (covers PhotoRepository, MaterialRepository and TaskCompletionRepository)
  - `NotificationRepository`
  - `EarningsRepository`: this month's approved earnings, with a SharedPreferences cache
  - `SettingsRepository`

  History is derived from local completions, so there is no HistoryRepository.
- The **services** are `WorkActions` (GPS verification + work/break actions, i.e. the WorkTimerService role), `CompletionService` (photos + submit) and `SyncService` (outbox and photo upload, i.e. the PhotoUploadService role). `LocationService` has `GeolocatorLocationService` and `MockLocationService` implementations, and `PhotoCaptureService` is implemented with image_picker.
- **Dismantling:** the "retrieved" rows are pre-filled from the expected list. At submit, the difference (expected − retrieved) is saved as `lost` rows.

### Backend API the Api* repositories will call (ARCHITECTURE.md §18)

```text
POST /api/v1/auth/login · /auth/refresh · /auth/logout · /auth/change-password
GET  /api/v1/me
GET  /api/v1/worker/config
GET  /api/v1/worker/tasks?from=&to=
GET  /api/v1/worker/tasks/{taskId}
GET  /api/v1/worker/tasks/{taskId}/expected-materials
PUT  /api/v1/worker/location-checks/{uuid}
PUT  /api/v1/worker/time-entries/{uuid}
PUT  /api/v1/worker/material-movements/{uuid}
POST /api/v1/worker/files/{uuid}/presign      → { uploadUrl, headers }
POST /api/v1/worker/files/{uuid}/confirm
PUT  /api/v1/worker/tasks/{taskId}/completion/{uuid}
GET  /api/v1/worker/history?cursor=
GET  /api/v1/worker/earnings?month=YYYY-MM    → { month, approved_tasks, approved_amount, currency }
GET  /api/v1/worker/notifications?cursor=
POST /api/v1/worker/notifications/{id}/read
PUT  /api/v1/worker/devices/{fcmToken}
```

- Every request sends the `X-Device-Time` header.
- All writes are idempotent by UUID, so they are safe to retry.
- Error responses have the shape `{ "error": { "code", "message", "details" } }`. Map each `code` to a localized message.

---

## TASKS SCREEN (`/tasks`)

Header:
- "My Tasks"
- Worker name
- Current date
- Top right, before the notification bell: **works done** (✓ count) and, right of it, **money earned** (yellow pill, `80 000 ֏`). Both are for the current Yerevan month and count **only manager-approved tasks** (ARCHITECTURE §8 "Worker pay"). Tapping either opens a sheet that says only approved tasks are counted. The values come from `GET /worker/earnings` via `EarningsRepository`. The last answer is cached in SharedPreferences, so the header still shows numbers offline; the cache is ignored once the month changes and removed on logout. Pull-to-refresh reloads it. Amounts are decimal strings and are never parsed into a double (`formatMoney`).
- Notification bell with unread count

Sections: **Today** (emphasized) and **Upcoming**. The list supports pull-to-refresh and shows cached data when offline, with a "Last updated 08:12" note.

Each `TaskCard` shows:
- Title
- Project / customer
- Site address
- Scheduled date and time
- Job type icon
- LEAD badge, if the worker is the lead
- `StatusBadge`

Example:

```text
Install Safety Net – Building A          LEAD
Davtashen Residential · Arm Build LLC
09:00 – 17:00 · Today
Davtashen 3rd district, Yerevan
[ READY TO START ]
```

Tapping a card opens `/tasks/:taskId`.

---

## TASK DETAILS (`/tasks/:taskId`)

**Task information:** title, job type, project, customer, instructions, scheduled date/time, role, crew members (names; tap to call), site contact (tap to call).

**Work location:**
- Address and access notes
- Map preview with a pin and a radius circle
- "Navigate" button (opens Google Maps or Yandex Navigator via `url_launcher`)
- Required coordinates
- Work radius
- Current distance from the worker, shown once a fix is available

Primary button: **"Verify My Location"**. It is only shown when the task can be started; otherwise the reason is shown instead.

---

## GPS VERIFICATION (`/tasks/:taskId/verify-location`)

This is one of the most important features. Never put GPS logic in widgets.

Algorithm (`LocationVerificationService` + `LocationService`):

1. Check whether location services are enabled. If not: state `servicesDisabled`.
2. Check or request permission. If denied: `permissionDenied`. If permanently denied: `permissionDeniedForever`, with an "Open settings" button.
3. Get the current position (high accuracy, timeout ~20 s). On timeout: `timeout`.
4. If `accuracy > maxLocationAccuracyM`: `lowAccuracy`, with the message "GPS signal is weak. Move to an open area and try again."
5. Compute the Haversine distance to the task's coordinates.
6. Verified if `distance ≤ task.geofenceRadiusM` (falling back to `config.defaultGeofenceRadiusM`). **The radius is never hard-coded.**
7. Save a `LocationCheck` (purpose `start`, with `isMocked` from geolocator) locally and enqueue it for sync. This happens **for failed checks too**.

```text
LocationVerificationResult
  verified, distanceMeters, accuracyMeters, isMocked,
  currentLatitude, currentLongitude, workLatitude, workLongitude, radiusMeters, timestamp
```

### UI states

| State | Text | Actions |
|---|---|---|
| checking | "Checking your location…" + spinner | — |
| verified | ✓ **Location Verified** — "You are at the work location." Distance: 32 m · Work location: Building A | **Start Working Timer** (enabled) |
| outside | ⚠ **You're outside the work area** — "Move closer to the assigned work location to start working." Distance: 870 m (allowed 150 m) | Try again · Navigate; Start disabled |
| lowAccuracy | "GPS signal is weak…" | Try again |
| permissionDenied | "Location permission is required to start working." | Allow location / Open settings |
| servicesDisabled | "Location services are disabled." | Open location settings · Try again |
| timeout / error | Friendly message | Try again |

If `isMocked` is true, still allow verification but record it. Don't accuse the worker in the UI; the server flags it for the manager.

GPS verification is **not tamper-proof**. Don't claim it is anywhere in the UI or the code comments.

---

## WORK TIMER

Pressing **Start Working Timer** does the following:
1. In one local transaction: create a WORK `TimeEntry` (`startedAt = clock.now()`, linked to the start location check) and mark the task active.
2. Enqueue the time entry for sync.
3. Navigate to `/work`.

**The timer is business-critical:**
- It is never a `counter++`, and `Timer.periodic` is never the source of truth.
- `Timer.periodic(1s)` (or a ticker) only **triggers a repaint**.
- The displayed value is always computed as `clock.now() − startedAt` (plus the sum of closed entries for totals).
- The state is read from drift on app start and resume, so it stays correct after:
  - the app being minimized or killed
  - the screen locking
  - the device rebooting
  - lifecycle changes

---

## BREAK TIMER

**"Stop & Start Break"** does, in one transaction:
1. Close the open WORK entry (`endedAt = now`).
2. Open a BREAK entry (`startedAt = now`). Task status becomes `onBreak`.
3. Enqueue both entries.

**"Resume Working"** does, in one transaction:
1. Close the BREAK entry.
2. Open a new WORK entry. Status becomes `inProgress`.
3. Take a non-blocking location fix (purpose `resume`). Record it, but never block on it.

A task can have any number of cycles:

```text
Work  09:00 → 12:00
Break 12:00 → 12:30
Work  12:30 → 17:00
```

`DurationCalculator` returns the total work time and the total break time.

---

## WORK SCREEN (`/work`)

```text
Install Safety Net – Building A

● WORKING                (or  ● ON BREAK  — different color, label and icon)

      ╭───────────────╮      round FlipTimer
     │   WORK TIME     │     front: work timer (green), back: break timer (blue)
     │   06:42:18      │     large value + the other total small underneath
     │ BREAK 00:32:14  │     ring sweeps once a minute (derived from the value)
     │ Tap to take a   │
     │     break       │
      ╰───────────────╯

STARTED      09:02
LOCATION     ✓ Verified (32 m)
SYNC         ✓ Synced  /  ⟳ 3 items waiting  /  ⚠ Sync failed — Retry

[ STOP & START BREAK ]   (primary; becomes RESUME WORKING while on break)
[ FINISH TASK ]          (secondary)
```

- WORKING, ON BREAK and COMPLETED must be impossible to confuse: use a different color, label and icon for each.
- If there is no active task, show an EmptyState: "No active task. Start a task from My Tasks."
- **Finish Task** asks for confirmation, then opens `/work/complete`.
- **FlipTimer** (`features/work/presentation/flip_timer.dart`): tapping the dial does the same as the primary button. On the work face it starts a break; on the break face it resumes work. The dial turns over (600 ms 3D rotation around the vertical axis) as soon as it is tapped. If the action fails, it turns back and the error is shown. Otherwise it follows the stored state, so the two buttons below still work and stay in sync. The values shown are always computed from stored timestamps (see WORK TIMER).

---

## COMPLETION FLOW (`/work/complete`)

This is a stepper on one screen, or a short sequence of screens. When it is entered, the open entry is closed at the moment the worker confirms "Finish". A non-blocking completion location fix is taken.

### 1. Summary

Shows: task, work time, break time, total duration, location verification, completion time.

### 2. Materials (LEAD only, and only for INSTALLATION / DISMANTLING / INSPECTION)

- **Installation**: add rows of item (picker from catalog, e.g. "Safety net 10×5 m", "Anchor M12") + quantity + unit → `installed`.
- **Dismantling**: shows the expected list (from `expected-materials`) with editable "retrieved" quantities. Any difference is recorded as `lost` / `damaged`, with an optional note.
- **Inspection**: mark damaged items or make adjustments. Show a placeholder for the inspection checklist (a later phase).
- At least one material row is required for installation and dismantling leads.

### 3. Photos of Completed Work

- **Take Photo** / **Choose From Gallery**, multiple photos, shown in a grid.
- Photos are resized to at most 1600 px (JPEG quality 80) by `image_picker` and copied into app documents. The original isn't kept.
- Each tile shows its upload state: pending, a progress ring, uploaded, or failed with retry. A photo can be removed until it is submitted.
- At least `config.minCompletionPhotos` photos (default 1) are required. Until then the Submit button stays disabled and a hint is shown.
- `PhotoRepository` + `PhotoUploadService` handle the upload: presign → PUT → confirm. Mocks simulate progress and failures.

### 4. Comment (optional)

A multiline text field.

### 5. Confirm

```text
Submit Task?

Task:      Install Safety Net – Building A
Work time: 07:15:32
Break time: 00:35:12
Photos:    4
Materials: 3 items            (lead only)
Location:  ✓ Verified

[ Submit Task ]   [ Cancel ]
```

### Submit

1. In one local transaction, create the `TaskCompletion` (uuid) with:
   - `taskId`, `workerId`
   - `timeEntries` (every work and break session)
   - `totalWorkDuration`, `totalBreakDuration`
   - `completedAt`, completion location check
   - photos, materials, `comment`
2. Enqueue it. The task status becomes `waitingForSubmission`.
3. Show a success screen:
   - "Task saved. It will be sent automatically." (offline)
   - or "Task submitted ✓" (once the server confirms)
4. Go to History.

Photos may still be uploading after submit. The outbox sends the completion **only after** all of its photos are confirmed, and the server checks that the photo minimum is met.

---

## OFFLINE SUPPORT AND SYNC

Construction sites often have poor connectivity, so the app is **offline-first**. These actions work with no network:

```text
Viewing cached tasks · verifying location · starting work · starting/ending breaks
· finishing · selecting photos · materials · comment · submitting (queued)
```

### Outbox (drift table `sync_items`)

- Every write action stores its local change **and** appends an outbox item in the **same transaction**.
- `SyncService` runs:
  - on connectivity regained
  - on app start/resume
  - every 30 s while the app is in the foreground and items are pending
  - through Android `WorkManager` as a periodic background job, if it is cheap to add (optional)
- It processes items in FIFO order per task. Dependencies come first: location checks → time entries → photos → materials → completion.
- Outcomes:
  - `2xx`: done.
  - Network error or `5xx`: exponential backoff (max ~10 min), item stays pending.
  - `409` / `422`: item becomes `failed` with the server's localized message. The task shows `synchronizationFailed` with **Retry** and the message.
  - `401`: refresh the token. If refresh fails, ask the worker to log in again, and **keep the outbox**.
- Because every PUT is keyed by a UUID, replays are safe.

### UI

- A global `SyncStatusBanner` shows: offline · syncing · N items waiting · sync failed.
- An offline indicator appears in app bars when there is no connection.

### Task list refresh

- The server data is merged with local state. Local unsynced state wins for display.
- A task that the server now reports as `cancelled` while it is active locally shows a blocking dialog: "This task was cancelled by your manager. Your recorded time will be sent for review." The data is still synced.

---

## HISTORY (`/history`)

Completed tasks, grouped by date:

```text
TODAY
✓ Install Safety Net – Building A
  7h 15m working · Completed 17:04

YESTERDAY
✓ Install Protective Net – Building C
  6h 42m working · Completed 16:51
```

Tasks that are waiting for sync or failed to sync are listed at the top with their status.

`/history/:taskId` is a read-only view of:
- task info
- every work/break session, with work and break totals
- photos
- materials
- completion time and location
- comment
- sync status

---

## PROFILE (`/profile`)

- Avatar placeholder, name, employee ID, phone, company ("NEST").
- Settings:
  - Notifications (the system permission and the in-app toggle)
  - Location permission status, with a button to open settings
  - Camera permission status
  - Language (hy / ru / en)
  - App version
  - "Unsynced items: N" with a **Sync now** button
  - **Log out** (with the unsynced-items warning)

---

## NOTIFICATIONS (`/notifications`)

A list of notifications. Unread ones are bold. Tapping one marks it read and opens the related task.

Mock examples:
- New task assigned: Install Safety Net – Building A
- Your task starts today at 09:00
- Task schedule changed: Dust Protection Installation – Building B moved to tomorrow 10:00
- Task cancelled
- Task submitted successfully
- Task submission failed — tap to retry

Create a `PushService` interface with a no-op mock for now. FCM (Android; APNs on iOS via FCM) is wired in a later phase. Firebase is only the delivery transport; the notification list and read state come from the NEST API: register the token via `PUT /worker/devices/{token}`, and a push tap opens the task.

---

## ERROR, LOADING AND EMPTY STATES

Every one of these needs designed UI. Never show raw exceptions or debug text:

```text
No internet (with cached data / without cached data)
GPS disabled · Location permission denied (and permanently denied) · GPS weak/low accuracy
Outside work area
Photo upload failed · Task submission failed (with server reason)
Task already completed · Task cancelled · Task not scheduled today · Another task already active
Session expired
Unknown server error (with request ID in small text)
Empty task list · Loading tasks · Loading task details
Retrying synchronization
App version too old ("Please update NEST Worker")
```

---

## STATE MANAGEMENT

Use Riverpod. Keep UI state, domain logic and data access separate, and avoid large StatefulWidgets.

Example providers:

```text
authControllerProvider            currentWorkerProvider       taskConfigProvider
tasksProvider                     taskDetailsProvider(id)     taskDisplayStatusProvider(id)
activeTaskProvider                timeEntriesProvider(taskId) workTimerProvider (ticker → durations)
locationVerificationProvider(id)  completionControllerProvider(taskId)
photosProvider(taskId)            materialsProvider(taskId)
syncStatusProvider                notificationsProvider        connectivityProvider
```

Use `AsyncValue` for loading and error states. Stream the providers from drift where possible, so the UI updates when sync changes data.

---

## PROJECT STRUCTURE

```text
lib/
  main.dart                    (bootstrap: flavors, ProviderScope overrides: mocks vs api)
  app.dart
  core/
    config/        (AppConfig from dart-define)
    theme/
    routing/
    network/       (ApiClient, interceptors, error mapping)
    storage/       (drift database, secure storage)
    sync/          (SyncService, outbox)
    location/      (LocationService)
    time/          (Clock, DurationCalculator, formatters)
    errors/        (AppFailure types)
    l10n/          (ARB files)
    widgets/
  features/
    auth/          data/ domain/ presentation/
    tasks/         data/ domain/ presentation/
    work/          data/ domain/ presentation/
    completion/    data/ domain/ presentation/   (photos, materials, submit)
    history/       data/ domain/ presentation/
    profile/       data/ domain/ presentation/
    notifications/ data/ domain/ presentation/
test/
  (mirrors lib/)
integration_test/
  full_workflow_test.dart
```

---

## MOCK DATA

Mock data must be deterministic: no random values on rebuild. All dates are relative to "today".

- Worker: **Arman Harutyunyan**, employee code `NEST-007`, phone `+374 91 000 007`. Password `nest1234` for the mock login.
- Config: radius 150 m, accuracy limit 100 m, at least 1 photo, start window 120 min.
- Tasks:
  1. **Install Safety Net – Building A**. Today 09:00–17:00, INSTALLATION, LEAD. Davtashen 3rd district, Yerevan (40.2262, 44.4930). Customer "Arm Build LLC". Crew: Arman (lead), David, Karen.
  2. **Dust Protection Installation – Building B**. Tomorrow 10:00–16:00, INSTALLATION, MEMBER. Komitas Ave, Yerevan (40.2045, 44.5160).
  3. **Install Protective Net – Building C**. Completed yesterday, with history: work 6h42m, 2 cycles, 3 photos. Arabkir, Yerevan (40.2080, 44.5050).
  4. **Safety Net Inspection – Building D**. In 3 days, INSPECTION, MEMBER. Ajapnyak, Yerevan.
  5. **Dismantle Safety Net – Building E**. Today 14:00–18:00, DISMANTLING, LEAD. Expected materials: 300 m² net, 40 anchors. Use it to test dismantling and to test "another task already active".
- Catalog: Safety net 10×5 m (pcs), Safety net (m²), Dust net (m²), Anchor M12 (pcs), Steel cable 8 mm (m).
- Approved pay (`MockData.approvedPay`): tasks approved 1, 3 and 6 days ago (25 000 + 30 000 + 25 000 ֏), plus 10, 20 and 40 days ago (35 000, 20 000, 25 000 ֏). Whether the older ones count depends on the date: on 7 October the header shows **3** and **80 000 ֏**.
- Mock location: the `MockLocationService` can be switched between "at site (32 m)", "outside (870 m)", "low accuracy", "permission denied" and "services disabled". Add a dev-only menu in Profile (`dev` flavor only) to switch the mock GPS scenario and to simulate offline/failure modes.

---

## TESTING

Add unit tests for the business logic. At minimum:

- **GPS**:
  - Haversine distance on known coordinates
  - inside/outside radius, including the boundary
  - radius taken from the task vs the config fallback
  - low-accuracy rejection
- **Durations**:
  - a single open work entry
  - multiple work/break cycles
  - an open break entry
  - totals after a simulated app restart (reload from drift with an injected clock)
  - no reliance on ticks: advancing the injected clock changes the result without any timer firing
- **State machine**: every allowed transition, and the invalid transitions rejected (e.g. completed → inProgress, upcoming → inProgress, starting a second active task).
- **Status derivation**: `deriveStatus` for each case.
- **Completion validation**: the photo minimum, lead materials required, member skips materials.
- **Outbox**:
  - ordering
  - retry/backoff on a network error
  - `409` → failed
  - a replay produces no duplicates
  - logout keeps the items
- **Earnings**: only the current Yerevan month is counted; the cache is served offline and ignored in a new month; `formatMoney` output.
- **Widget tests**: TaskCard states, Work screen in WORKING vs ON BREAK (tapping the FlipTimer turns it over), Verify Location states, header counters.
- **Integration test**: the full mock workflow.

---

## DEVELOPMENT PROCESS

Work incrementally, in this order:

1. Initialize the Flutter project, flavors and dependencies.
2. Core: config, theme, l10n skeleton, routing, drift database, Clock.
3. Domain models, state machine, DurationCalculator, LocationVerificationService, plus their tests.
4. Mock repositories and services.
5. Login → Tasks → Task Details.
6. GPS verification flow.
7. Work timer → break timer.
8. Completion: materials, photos, comment, confirm, submit.
9. Outbox + SyncService (against mocks with simulated failures), sync UI.
10. History, Profile, Notifications.
11. Error, loading and empty states everywhere.
12. Remaining tests.
13. Run `dart format .`, `flutter analyze` and `flutter test`. Fix every issue.

Don't stop after building only UI mockups. The project must compile and run.

---

## FINAL EXPECTATION

A working Flutter prototype that launches on an Android emulator or device and supports this complete local/mock workflow, **including in airplane mode**:

```text
LOGIN
↓
TASK LIST
↓
OPEN TODAY'S TASK
↓
TASK DETAILS
↓
VERIFY LOCATION  → LOCATION VERIFIED
↓
START WORKING → WORK TIMER
↓
START BREAK → BREAK TIMER
↓
RESUME WORK → WORK TIMER
↓
(kill and reopen the app: timer still correct)
↓
FINISH TASK
↓
MATERIALS (lead) → ADD PHOTOS → ADD COMMENT
↓
CONFIRM COMPLETION
↓
WAITING FOR SUBMISSION → (back online) → COMPLETED
↓
HISTORY
```

All backend functionality sits behind repositories and services, so `Api*` implementations can replace the mocks without redesigning the app.

Before finishing, run `flutter analyze` and `flutter test` and fix every error caused by the implementation. If an emulator or device is available, run the app and check the main workflow by hand.
