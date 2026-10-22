# NEST Operations Platform — Architecture Plan

## 1. Overview

NEST installs safety-net and dust-protection systems on construction sites in Armenia. This platform runs the operational side of the business:

1. **Clients** (construction companies) — submit assessment requests through the existing public website.
```
github repo link: https://github.com/ArmH-yan/nest_web
local directory: "F:\nest_web"
```
2. **Managers / admins** — use the NEST manager web app to review requests, survey sites, prepare quotes, plan projects, schedule crews, review timesheets and track materials on site.
3. **Workers** — use the **NEST Worker** Flutter app to:
   - see assigned tasks
   - verify their GPS position at the site
   - track work and break time
   - record materials
   - upload photos and submit completed work, even with poor connectivity
4. **Reporting** — operational reports are read from PostgreSQL (Metabase). A separate warehouse (BigQuery) is a later option, not part of v1.

### Context and constraints

- **Solo developer**, fewer than 20 field workers.
- **Mixed work:** short single visits (site surveys, inspections) and multi-day crew installations/dismantlings.
- **Each crew member tracks their own time** (GPS check-in, work/break timer, completion).
- **Quotes and on-site materials tracking are required in v1.**
- **No third-party task system (Planfix or similar).** NEST's own backend and manager app are the system. The public website sends its leads to the NEST backend.
- The public website already exists as a separate Next.js project and stays that way.

### Core architectural principle

> **PostgreSQL is the source of truth for operational data. All clients talk to the FastAPI backend; nothing talks to PostgreSQL directly except the backend (and a read-only reporting role).**

---

# 2. High-Level Architecture

```text
 ┌────────────────────┐   ┌────────────────────┐   ┌──────────────────────┐
 │ PUBLIC WEBSITE     │   │ MANAGER WEB APP    │   │ NEST WORKER          │
 │ nest_web (separate)│   │ Next.js            │   │ Flutter (Android 1st,│
 │ Next.js 15         │   │ MANAGER, ADMIN     │   │ iOS compatible)      │
 │                    │   │                    │   │                      │
 │ /api/contact proxy │   │ requests, projects │   │ tasks, GPS check,    │
 │                    │   │ quotes, calendar,  │   │ work/break timer,    │
 │                    │   │ timesheets, ...    │   │ photos, materials,   │
 │                    │   │                    │   │ local DB + outbox    │
 └─────────┬──────────┘   └─────────┬──────────┘   └──────────┬───────────┘
           │ HTTPS + service key    │ HTTPS + cookie session  │ HTTPS + bearer tokens
           └────────────────────────┼─────────────────────────┘
                                    ▼
                ┌──────────────────────────────────────────┐
                │              FASTAPI  (Python)           │
                │  modular monolith                        │
                │                                          │
                │  auth · requests · companies/sites       │
                │  projects · quotes · catalog · materials │
                │  jobs · scheduling · time tracking       │
                │  files · notifications · audit           │
                │                                          │
                │  + task worker (Postgres-backed queue)   │
                └──┬──────────────┬───────────────┬────────┘
                   │ SQL          │ S3 API        │ HTTPS
                   ▼              ▼               ▼
           ┌──────────────┐ ┌─────────────┐ ┌──────────────────────┐
           │  POSTGRESQL  │ │ OBJECT      │ │ FCM (worker push)    │
           │  source of   │ │ STORAGE     │ │ Telegram (manager    │
           │  truth       │ │ photos/PDFs │ │   alerts, optional)  │
           └──────┬───────┘ └─────────────┘ └──────────────────────┘
                  │ read-only role
                  ▼
           ┌──────────────┐
           │  METABASE    │  reporting
           └──────────────┘
```

Every client app goes through the API. The only other thing allowed to connect to PostgreSQL is Metabase, and it uses a read-only role.

---

# 3. Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| Public website | Next.js 15 + TypeScript (`nest_web`, separate repo) | Marketing site + assessment request form |
| Manager web app | Next.js + React + TypeScript | Manager/admin UI (desktop-first) |
| Worker app | Flutter + Dart (Material 3, Riverpod, GoRouter, Dio, drift) | NEST Worker mobile app, Android first, iOS compatible |
| Backend | FastAPI + Python | API and business logic |
| Database | PostgreSQL (with `btree_gist`) | Operational source of truth |
| ORM / migrations | SQLAlchemy 2.x + Alembic | Database access and schema migrations |
| Validation | Pydantic | API/request validation |
| Background tasks | Rows in PostgreSQL + a worker process (`app.cli push-worker`), §37 | Push, reminders, PDF generation |
| File storage | S3-compatible (Cloudflare R2 / Hetzner Object Storage; RustFS locally) | Photos, quote PDFs |
| Push notifications | Firebase Cloud Messaging (FCM) for Android; APNs for iOS (delivered via FCM) | Worker app push. **Firebase is used only as the push transport** — no Firebase Auth, Firestore, Realtime Database, Storage, App Distribution or other Firebase services |
| Manager alerts | In-app list + Telegram bot (optional) | New requests, flagged timesheets |
| Maps | Google Maps (display) + deep links to Google Maps / Yandex Navigator | Site location, navigation |
| PDF | WeasyPrint (HTML → PDF) | Quotes in hy/ru/en |
| Reporting | Metabase on read-only Postgres role | Operational reports and KPIs |
| API contract | OpenAPI (FastAPI) → TS client (`openapi-typescript`); Dart DTOs checked against it | One contract for both apps |
| Hosting | One VM, Docker Compose, Caddy (automatic HTTPS) | Simple production |
| CI/CD | GitHub Actions | Tests, build, deploy, APK build |

**Deferred, not v1:** BigQuery + ETL, Redis/Celery, load balancer, Kubernetes, live GPS tracking.

### Why Flutter for workers (not a PWA)

The worker app has requirements that a PWA cannot meet reliably, especially on iOS:

- **GPS verification**: accurate positions with an accuracy value, permission and "location disabled" handling, and detection of mocked locations on Android.
- **Business-critical timers**: work and break sessions are stored as timestamps in a local database. They survive the app being killed, the phone locking or rebooting, and having no network.
- **Offline-first workflow**: start, break, resume, finish and selecting photos all work without internet. A durable outbox syncs the data later.
- **Camera and gallery** with background upload, progress and retry.
- **Native push** (FCM/APNs).

---

# 4. Why FastAPI

The backend is implemented in Python using FastAPI. It is responsible for:

- REST API
- Authentication and authorization
- Business rules and status transitions
- Database access
- Scheduling and crew assignment
- Time tracking ingestion and validation (GPS, clock-skew, overlaps)
- Quotes and PDF generation
- Materials ledger
- File handling (presigned uploads)
- Notifications
- Integration with external services (website, FCM, storage)

The website, manager app and worker app must **not connect directly to PostgreSQL**.

```text
nest_web (server) ──┐
                    │
Manager web app ────┼──→ FastAPI ──→ PostgreSQL
                    │
NEST Worker app ────┘
```

This keeps security and business logic centralized. The mobile app contains no secrets other than the user's own tokens.

---

# 5. Repository Structure

This repository (`nest-apps`) is a monorepo for the backend, the manager web app and the worker app. The public website stays in its own repo (`nest_web`), because it is deployed and released on its own schedule.

```text
nest-apps/
│
├── apps/
│   ├── api/
│   │   ├── app/
│   │   │   ├── main.py
│   │   │   ├── core/              # config, security, logging, errors
│   │   │   ├── db/                # engine/session, base, naming conventions
│   │   │   ├── tasks/             # background task definitions
│   │   │   └── modules/
│   │   │       ├── auth/
│   │   │       ├── users/
│   │   │       ├── companies/     # companies, contacts, sites
│   │   │       ├── requests/      # assessment requests (public intake)
│   │   │       ├── projects/
│   │   │       ├── quotes/
│   │   │       ├── catalog/
│   │   │       ├── materials/
│   │   │       ├── jobs/          # jobs, visits, assignments, status history
│   │   │       ├── timetracking/  # time entries, location checks, completions
│   │   │       ├── workers/       # worker profile, time off
│   │   │       ├── worker_api/    # /worker/* endpoints used by the mobile app
│   │   │       ├── files/
│   │   │       ├── notifications/
│   │   │       └── audit/
│   │   ├── alembic/
│   │   ├── tests/
│   │   ├── Dockerfile
│   │   └── pyproject.toml
│   │
│   ├── manager-web/               # Next.js manager/admin app
│   │   ├── app/
│   │   ├── components/
│   │   ├── features/
│   │   ├── lib/api/               # generated OpenAPI client
│   │   └── package.json
│   │
│   └── worker-mobile/             # Flutter: NEST Worker
│       ├── lib/
│       │   ├── core/              # theme, routing, network, storage, sync, errors, widgets
│       │   └── features/          # auth, tasks, work, completion, history, profile, notifications
│       ├── test/
│       └── pubspec.yaml
│
├── infrastructure/
│   ├── Caddyfile
│   ├── docker-compose.prod.yml
│   └── backup/
│
├── docs/
│   ├── WORKER_APP_SPEC.md         # build spec for NEST Worker
│   ├── API.md
│   ├── DATABASE.md
│   ├── SECURITY.md
│   └── DEPLOYMENT.md
│
├── docker-compose.yml
├── .env.example
├── .gitignore
├── ARCHITECTURE.md
└── README.md
```

Each backend module contains:

```text
router.py      HTTP layer
schemas.py     Pydantic models
models.py      SQLAlchemy models
service.py     business rules, transactions, status transitions
```

There is no separate repository layer on the backend. Services use the SQLAlchemy session directly. If a module's queries get complex, move them into a `queries.py` in that module. (The Flutter app *does* use repository interfaces, so it can swap mock and API implementations; see `docs/WORKER_APP_SPEC.md`.)

---

# 6. User Roles

Roles are fixed. Each user has exactly one, stored as an enum column on `users`.

### ADMIN

Full system access: manage users, catalog, prices, settings (geofence defaults, photo rules), all data, reports.

### MANAGER

Operational access:

- review and convert requests
- manage companies, contacts, sites (including the map pin and geofence radius)
- create projects, quotes, jobs
- schedule visits and assign crews
- review and approve timesheets; see GPS check results and flags
- manage worker time off
- view materials on sites
- reset worker passwords
- view operational reports

### WORKER

Uses the NEST Worker app only, and sees **only their own** assignments:

- view assigned tasks (today / upcoming / history)
- view site and job information allowed by policy (no prices)
- verify location, track work and break time
- record materials (crew lead)
- upload photos, add comments, submit completion
- see their own approved work and pay for the current month (§8 "Worker pay")

### CLIENT

Clients don't log in. They use the public request form only. A client portal is a future option.

---

# 7. Authentication

Authentication is handled by FastAPI.

```text
POST /api/v1/auth/login   (phone or email + password)
        │
        ▼
FastAPI verifies credentials (Argon2id)
        │
        ▼
Access token (short-lived, ~15 min) + refresh token (rotating, stored hashed)
```

- **Manager web app**: both tokens are stored in Secure, HttpOnly, SameSite=Lax cookies. Use CSRF protection on state-changing requests.
- **Worker app**: tokens are kept in `flutter_secure_storage` and sent as a `Bearer` header. Refresh tokens are long-lived (e.g. 60 days, sliding), so workers aren't logged out while they're offline in the field.
- **Login identifier**: phone is required for all users and email is optional.
- **No self-registration.** Managers create worker accounts and set an initial password. Workers must change it on first login.
- **Forgot password (v1)**: the app tells the worker to contact their manager, who resets the password in the manager app. SMS reset can come later.
- **Refresh token rotation** is backed by the `refresh_tokens` table. Reusing an old refresh token revokes the whole token family.
- **Logout and deactivation** revoke all of the user's refresh tokens and remove their FCM device tokens.
- **Rate-limit** login attempts.

Passwords are never stored as plaintext.

**As built (Phase 1, 2026-10-08)** — `apps/api/app/modules/{auth,users,audit}`:

- `POST /auth/login` takes `{phone | email, password, device_id?}` and returns `{access_token, refresh_token, token_type, expires_in, user}`. `user` has the same shape as `GET /me`, which includes `worker: {id, employee_code}` for workers. Phones are normalized (`+374 91 00-00-07` → `+37491000007`) and emails are lower-cased.
- The access token is an HS256 JWT signed with `JWT_SECRET` (required setting). It carries `sub`, `role` and `fid`, the refresh-token family. Refresh tokens are random strings, stored as SHA-256 hashes. Each refresh rotates the token, and reusing a rotated token revokes the family (`REFRESH_TOKEN_REUSED`).
- While `must_change_password` is set, only `/me`, `/auth/change-password` and `/auth/logout` work; everything else returns `403 PASSWORD_CHANGE_REQUIRED`. Changing the password signs out all other sessions. Logout revokes all of the user's refresh tokens.
- Login rate limit: after 5 failed attempts for the same phone/email within 15 minutes, the API returns `429 TOO_MANY_LOGIN_ATTEMPTS`. Failures are counted from `audit_logs` (`auth.login_failed`), so no extra store is needed. Wrong passwords and unknown phones return the same `401 INVALID_CREDENTIALS`; a wrong current password on change returns `400 INVALID_CREDENTIALS`.
- The worker app uses Bearer tokens. **The manager web app (Phase 3) uses cookies**: `POST /auth/web/login` (managers/admins only, else `403 NOT_A_MANAGER`) sets `nest_access` (HttpOnly, path `/`), `nest_refresh` (HttpOnly, path `/api/v1/auth/web`) and `nest_csrf` (readable). Every cookie-authenticated write must send `X-CSRF-Token` = `nest_csrf` (double-submit; `403 CSRF_FAILED`). `POST /auth/web/refresh` rotates (a rejected refresh also clears the cookies), `POST /auth/web/logout` revokes and clears. `COOKIE_DOMAIN` (e.g. `.nest.am`) lets `manager.nest.am` read the CSRF cookie set by `api.nest.am`. Removing FCM device tokens on logout comes with push.
- Accounts are created with `python -m app.cli create-user …` until the manager app's worker management exists. The password is prompted for, never passed as an argument.
- Router dependencies: `CurrentAuth`, `PasswordChangeAuth`, `require_roles(...)` (`app/modules/auth/dependencies.py`).

---

# 8. PostgreSQL Data Model

## Conventions

- Primary keys: `bigint` identity for records created on the server. **Records created on a device** (time entries, location checks, completions, photos, material movements) use a **client-generated UUID** as the primary key, which makes offline sync idempotent.
- Human-facing references (`REQ-2026-0042`, `Q-2026-0017`) are separate unique columns.
- All timestamps are `timestamptz`, stored in UTC and displayed in `Asia/Yerevan`.
- Records created on a device store both the device timestamp (`*_at`) and `received_at` (server time).
- Money: `numeric(12,2)` with `currency` (default `AMD`), never float.
- Records are not hard-deleted. Use `is_active` / `archived_at` instead.
- Every table has `created_at` and `updated_at`.
- Enums are Postgres enums or `text` + `CHECK`. The allowed transitions live in the service layer (§9–§11).

## Entity overview

```text
companies ──< contacts
    │
    └──< sites ──< projects ──< jobs ──< job_visits ──< visit_assignments >── workers ── users
           │          │                                      │                          │
           │          ├──< quotes ──< quote_lines            ├──< time_entries          ├──< refresh_tokens
           │          │                   │                  ├──< location_checks       ├──< device_tokens
           │          └──< assessment_    │                  ├──1 assignment_completions└──< notifications
           │               requests       ▼                  └──< files (photos)
           └──< site_material_movements >── catalog_items

jobs ──< job_status_history     workers ──< worker_time_off     audit_logs
```

**A `visit_assignment` is what the worker app calls a "Task":** one worker, on one visit (one day) of one job. Each crew member has their own assignment, timer, GPS checks and completion.

## Tables

### users

```text
id
phone            unique, required
email            unique, nullable
password_hash
first_name
last_name
role             ADMIN | MANAGER | WORKER
locale           hy | ru | en | hi | id   (hi = Hindi, id = Indonesian; worker-facing only)
telegram_chat_id nullable (linked via the NEST bot, §26a; all roles)
must_change_password
is_active
created_at, updated_at
```

### refresh_tokens

```text
id
user_id
family_id
token_hash
expires_at
revoked_at
replaced_by_id
user_agent / device_id
created_at
```

### device_tokens

```text
id
user_id
fcm_token        unique
platform         android | ios
app_version
last_seen_at
created_at
```

A token belongs to whoever signed in on that phone last (`PUT /worker/devices/{token}` moves it). It is deleted on logout (which signs out everywhere), when the worker is deactivated, and when FCM reports it UNREGISTERED. Migration `0007`.

### notifications

```text
id
user_id
type             TASK_ASSIGNED | TASK_CHANGED | TASK_CANCELLED | TASK_REMINDER | SUBMISSION_ACCEPTED | ...
title
body
data             jsonb (e.g. assignment_id)
read_at
created_at
dedupe_key       unique, nullable: generated notifications that must exist once (task reminders)
push_status      PENDING | SENT | SKIPPED | FAILED   (the row is its own push job, §26)
push_attempts
next_push_at     retry backoff
pushed_at
push_error
```

### workers

```text
id
user_id          unique
employee_code
skills           text[]   (e.g. safety_net, dust_net, rope_access)
is_active
created_at, updated_at
```

### worker_time_off

```text
id
worker_id
period           tstzrange, whole Yerevan days [first 00:00, last+1 00:00)
reason           VACATION | SICK | OTHER
note
created_by
created_at
```

As built (migration `0006`, `app/modules/workers/models.py`):
- Absences of one worker may not overlap: the exclusion constraint `no_time_off_overlap` returns `409 TIME_OFF_OVERLAP`.
- Time off doesn't block scheduling (§14). Instead, each row reports `booked_tasks`, the number of the worker's non-cancelled tasks that fall inside it.
- Creating and deleting time off is audited (`time_off.created`, `time_off.deleted`).

### companies

```text
id
name
tax_id           nullable (ՀՎՀՀ)
phone
email
address
notes
created_at, updated_at
```

### contacts

```text
id
company_id       nullable (private persons)
full_name
position
phone
email
preferred_locale
created_at, updated_at
```

### sites

A physical construction site.

```text
id
company_id
name                 e.g. "Davtashen residential block 3"
address
latitude             numeric(9,6)
longitude            numeric(9,6)
location_confirmed   boolean (pin placed/checked by a person)
geofence_radius_m    nullable → falls back to settings.default_geofence_radius_m
access_notes         gate code, foreman, parking, height notes
created_at, updated_at
```

### settings

A key/value table (admin-editable). It includes:

```text
default_geofence_radius_m        e.g. 150
max_location_accuracy_m          e.g. 100  (worse fixes are rejected as "too inaccurate")
min_completion_photos            e.g. 1
start_window_minutes_before      e.g. 120  (how early a task can be started)
clock_skew_flag_seconds          e.g. 300
```

### services

Keys match the website's `src/config/services.ts` slugs.

```text
id
slug             safety-system | dust-protection | ...
name_hy, name_ru, name_en
is_active
```

### assessment_requests

The raw intake from the website. The submitted data is kept exactly as received.

```text
id
reference        REQ-YYYY-NNNN
status           NEW | IN_REVIEW | CONVERTED | REJECTED | SPAM
source           website | phone | manual
locale
submitted_name
submitted_company
submitted_phone
submitted_email
service_slug
project_type
message
site_address     nullable
latitude, longitude  nullable
preferred_date   nullable
contact_id       nullable  (set during review)
project_id       nullable  (set on conversion)
reviewed_by
created_at, updated_at
```

### projects

One engagement at one site.

```text
id
reference        P-YYYY-NNNN (reference_counters, per Yerevan year)
name             e.g. "Davtashen Residential" (shown as the project in the worker app)
site_id
company_id       nullable (private persons)
primary_contact_id
service_slug
status           LEAD | SURVEY | QUOTED | WON | LOST | INSTALLED | DISMANTLED | CLOSED
expected_install_date
expected_dismantle_date
manager_id
notes
created_at, updated_at
```

### catalog_items

Shared by quotes and the materials ledger.

```text
id
sku
name_hy, name_ru, name_en
kind             MATERIAL | LABOR | SERVICE | RENTAL
unit             m2 | m | pcs | day | lump
default_price
is_trackable     boolean  (physical item tracked on site)
is_active
```

### quotes

```text
id
reference        Q-YYYY-NNNN
project_id
version          1, 2, 3 … (a revision creates a new version)
status           DRAFT | SENT | ACCEPTED | REJECTED | EXPIRED | SUPERSEDED
locale
currency         AMD
valid_until
subtotal
discount
vat
total
pdf_file_id      nullable
sent_at
decided_at
created_by
created_at, updated_at
```

### quote_lines

```text
id
quote_id
position
catalog_item_id  nullable (free-text lines allowed)
description
quantity
unit
unit_price
line_total
```

A quote is locked once it is SENT. Any change after that creates a new version, and the old version becomes SUPERSEDED.

### jobs

One piece of work on a project.

```text
id
project_id
site_id
job_type         SURVEY | INSTALLATION | INSPECTION | MAINTENANCE | DISMANTLING
status           DRAFT | SCHEDULED | IN_PROGRESS | COMPLETED | CANCELLED | NO_ACCESS
priority
title            e.g. "Install Safety Net – Building A"
instructions
estimated_hours
created_by
created_at, updated_at
```

### job_visits

Each time the crew is on site. A survey has one visit. An installation may have several days of visits.

```text
id
job_id
period           tstzrange (scheduled start, end)
status           PLANNED | DONE | CANCELLED
```

### visit_assignments  (= worker app "Task")

```text
id
visit_id
worker_id
role             LEAD | MEMBER
period           tstzrange  (copied from the visit; kept in sync by the service)
status           ASSIGNED | IN_PROGRESS | SUBMITTED | CANCELLED
pay_amount       numeric(12,2), nullable  (fixed pay for this task, entered by the manager)
currency         default 'AMD'
reviewed_by      nullable (timesheet approval)
reviewed_at
review_flags     text[]  (e.g. OUTSIDE_GEOFENCE, MOCK_LOCATION, CLOCK_SKEW, TOTALS_MISMATCH)
assigned_by
assigned_at
```

Double-booking is prevented **by the database**:

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE visit_assignments
  ADD CONSTRAINT no_worker_overlap
  EXCLUDE USING gist (worker_id WITH =, period WITH &&)
  WHERE (status <> 'CANCELLED');
```

When this constraint is violated, the API returns `409 WORKER_ALREADY_BOOKED`. The service checks first so the error can name the conflicting visit (`details.conflicting_visit_id`); the constraint still catches races. Ranges are `[)`, so back-to-back visits don't overlap.

Also: `UNIQUE (visit_id, worker_id)` (a removed worker's row is CANCELLED and reused when they are added back) and a partial unique index allowing one active LEAD per visit.

**Worker pay (decided 2026-10-08):** each assignment pays a fixed `pay_amount` that the manager enters when assigning the crew (it can be edited until the timesheet is approved; changes are audited). There are no hourly or daily rates. A task counts as **earned** once its timesheet is approved (`reviewed_at` is set, status `SUBMITTED`). The worker app shows the current Yerevan month's approved count and total (`GET /worker/earnings`, §18). Workers see only their own pay; job and quote prices stay hidden (§6).

### time_entries  (work and break sessions)

```text
id               uuid (client-generated)
assignment_id
worker_id
kind             WORK | BREAK
started_at       device timestamp
ended_at         nullable while running
start_location_check_id  nullable
received_at
client_clock_offset_s    (server_now − device_now measured at sync)
```

- A task can have any number of alternating WORK and BREAK entries.
- Totals are always computed as `Σ(ended_at − started_at)` and never taken from a counter.
- Entries for one worker must not overlap:

```sql
ALTER TABLE time_entries
  ADD CONSTRAINT no_time_overlap
  EXCLUDE USING gist (worker_id WITH =,
                      tstzrange(started_at, coalesce(ended_at, 'infinity')) WITH &&);
```

### location_checks

```text
id               uuid (client-generated)
assignment_id
worker_id
purpose          START | RESUME | COMPLETION | MANUAL
latitude
longitude
accuracy_m
is_mocked        boolean (Android reports this)
captured_at      device timestamp
received_at
client_distance_m
client_verified  boolean
server_distance_m   (recomputed by the server from the site pin)
radius_m            (radius applied)
server_verified     boolean  (inside the radius and accurate enough)
override_reason     nullable (manager override, Phase 3)
overridden_by       nullable
```

### assignment_completions

```text
id               uuid (client-generated)
assignment_id    unique
completed_at     device timestamp
completion_location_check_id
reported_work_seconds
reported_break_seconds
work_seconds        (recomputed from time_entries)
break_seconds
comment
received_at
```

The server recomputes the totals from `time_entries`. If they don't match the reported totals, it adds the `TOTALS_MISMATCH` flag.

### job_status_history

```text
id
job_id
old_status
new_status
changed_by
changed_at
comment
```

### job_notes

```text
id
job_id
visit_id         nullable
author_id
content
created_at
```

### job_checklists (inspections)

```text
id               uuid
assignment_id
template_code    e.g. SAFETY_NET_INSPECTION_V1
answers          jsonb
completed_at
```

### site_material_movements

An append-only ledger. The current quantity of materials on a site is computed from it.

```text
id               uuid (client-generated when recorded in the app)
site_id
project_id
job_id           nullable
assignment_id    nullable
catalog_item_id
quantity         positive number
movement         INSTALLED | RETRIEVED | DAMAGED | LOST | ADJUSTMENT
recorded_by
recorded_at
note
```

```sql
-- what is currently on a site (and what the dismantling crew must bring back)
SELECT catalog_item_id,
       SUM(CASE WHEN movement IN ('INSTALLED','ADJUSTMENT') THEN quantity
                ELSE -quantity END) AS on_site
FROM site_material_movements
WHERE site_id = :site_id
GROUP BY catalog_item_id
HAVING SUM(CASE WHEN movement IN ('INSTALLED','ADJUSTMENT') THEN quantity
                ELSE -quantity END) <> 0;
```

Warehouse stock management is out of scope for v1.

### files

Metadata only. The file bytes live in object storage (§24).

```text
id               uuid (client-generated for app uploads)
owner_type       ASSIGNMENT | JOB | QUOTE | REQUEST | SITE
owner_id
kind             PHOTO_BEFORE | PHOTO_AFTER | PHOTO | PDF | OTHER
storage_key
file_name
mime_type
size_bytes
taken_at         nullable (EXIF / device time)
latitude, longitude  nullable
uploaded_by      nullable (public uploads)
status           PENDING | UPLOADED
created_at
```

### audit_logs

See §31.

### Not in v1

`worker_locations` (continuous live tracking). The app only takes location fixes at specific moments: start, resume and completion.

---

# 9. Assessment Request Lifecycle

A request is an **intake record**. It never gets scheduled or completed; that happens to projects and jobs.

```text
NEW
 │
 ▼
IN_REVIEW ──── REJECTED
 │       └──── SPAM
 ▼
CONVERTED  → creates/links company, contact, site, project (status LEAD or SURVEY)
```

---

# 10. Project Lifecycle

```text
LEAD → SURVEY → QUOTED ─┬─► LOST
                        ▼
                       WON → INSTALLED → DISMANTLED → CLOSED
```

- SURVEY: a survey job is scheduled or done.
- QUOTED: a quote has been SENT.
- WON: the quote is ACCEPTED, and an installation job is created.
- INSTALLED: the installation job is COMPLETED.
- DISMANTLED: the dismantling job is COMPLETED.

Some project transitions happen automatically as a side effect of job and quote events, inside the same transaction. A manager can also move the status by hand when the transition table allows it.

---

# 11. Job, Visit and Assignment Lifecycles

### Job

```text
DRAFT
  │  (at least one visit with ≥1 assigned worker)
  ▼
SCHEDULED
  │  (first assignment starts work — synced from the app)
  ▼
IN_PROGRESS
  │
  ├──── NO_ACCESS   (reported by crew/manager; can be rescheduled → SCHEDULED)
  ├──── CANCELLED
  ▼
COMPLETED         (automatically when no PLANNED visits remain, or set by a manager)
```

### Visit

`PLANNED → DONE` when every non-cancelled assignment on the visit is SUBMITTED. A visit can also become `CANCELLED`.

### Assignment (server side)

```text
ASSIGNED → IN_PROGRESS → SUBMITTED
    └──────────┴──────► CANCELLED (by manager)
```

### Worker app task status (client side)

The worker app shows a richer status. Most of it is **derived on the device**, not stored on the server:

| App status | Meaning / source |
|---|---|
| `upcoming` | ASSIGNED, scheduled for a future day |
| `today` | ASSIGNED, scheduled for today |
| `inProgress` | an open WORK time entry exists locally |
| `onBreak` | an open BREAK time entry exists locally |
| `waitingForSubmission` | the completion is saved locally and queued in the outbox |
| `synchronizationFailed` | the outbox gave up after retries, or the server rejected it (shows the reason) |
| `completed` | the server confirmed SUBMITTED |

Server-side completion rules:

- At least `min_completion_photos` photos.
- The **crew lead** on INSTALLATION / DISMANTLING jobs must record materials.
- The **crew lead** on INSPECTION jobs must fill the checklist.
- A START location check is required (GPS-verified or manager-overridden).

All transitions are defined in **one transition table per entity**: `(from, to, allowed_roles, guard)`. The backend enforces it, and it has unit tests. The app keeps its own copy of the task state machine for offline use, but the server's decision is final.

---

# 12. Public Website Integration (`nest_web`)

The public website already exists. It needs **no UI changes** to start feeding the platform. It sends leads to the NEST backend instead of a third-party CRM.

### Current state (in `nest_web`)

- `src/components/contact-form.tsx` posts to `/api/contact`.
- `src/app/api/contact/route.ts` validates the body and calls `submitContact()`.
- `src/lib/contact.ts` is the provider seam. In production mode it POSTs the payload to `CONTACT_API_URL`.
- Payload: `name, company, phone, email, service, projectType, message`.
- `README.md` / `AGENTS.md` still describe a Planfix webhook and should be updated to point at the NEST API.

### Integration

```text
Browser ──► nest_web /api/contact (server) ──► FastAPI POST /api/v1/public/assessment-requests
                                    header: X-Service-Key: <CONTACT_API_KEY>
```

- Set `NEXT_PUBLIC_FORM_MODE=production`, `CONTACT_API_URL=https://api.<domain>/api/v1/public/assessment-requests` and `CONTACT_API_KEY`.
- In `submitContact()`, send `CONTACT_API_KEY` as a header and add `locale` and `source: "website"` to the payload.
- FastAPI accepts the existing field names unchanged and maps them to `submitted_*` columns. `service` is matched to `services.slug`.
- The browser never sees the API key or the API host.

### Spam and abuse

- Cloudflare Turnstile on the form, verified in the `nest_web` route.
- Honeypot field.
- Rate limit per IP, in both `nest_web` and FastAPI.
- Managers can mark a request as `SPAM`.

### Later additions to the form

Optional site address with a map pin, preferred date, and photos. Consider making **phone** required.

---

# 13. Manager Web Application

A dedicated Next.js app (`apps/manager-web`), built for desktop.

**As built (Phase 3, first slice, 2026-10-18)**: login, dashboard (today's crews with per-worker status, jobs without a crew), jobs (list, create, detail with visits, crew editor with lead + pay per worker, double-booking shown with a link to the conflicting job, cancel visit/job), projects, sites (OpenStreetMap + Leaflet pin and geofence circle; click to move the pin), companies, workers (create, deactivate, reset password).
- Interface languages: **hy, ru, en** (`src/lib/i18n/{hy,ru,en}.ts`, typed so every language has every key; follows the manager's `locale`, switchable in the sidebar, remembered in localStorage). API error codes map to localized messages.
- The signed-in pages are client components that call the API directly with the session cookies (`src/lib/api/client.ts`: CSRF header, one shared refresh on 401, then login). No client cache library: `useApi()` is a small hook.
- Typed client from the committed contract: `npm run gen:api` reads `apps/api/openapi.json`.
- Times are shown in Asia/Yerevan as `18.10.2026 09:00`; visit times typed by a manager are sent with `+04:00`. Money is shown from the API's decimal strings (`20 000 ֏`).
- Map tiles come from tile.openstreetmap.org (fine for a handful of managers; switch to a tile provider or self-hosted tiles if usage grows).
- **Timesheets (2026-10-18)**: list (`/timesheets`; filters for date range, worker and "waiting for approval / flagged / approved / all", kept in the URL), and a detail page (`/timesheets/{assignment_id}`). See "Timesheets" below.
- **Planning timeline (2026-10-19)**: `/planning`, by project and by worker (§14a).
- **Worker time off (2026-10-20)**:
  - add and delete absences on the worker's Info page; each one warns how many booked tasks fall inside it
  - the crew editor marks workers on leave and shows an amber warning (it doesn't block)
  - absences show as striped blocks on the planning timeline's worker rows
- Next: push + reminders.

## Main navigation

```text
Dashboard
Requests
Projects
Planning         (timeline / Gantt, §14a)
Jobs
Timesheets
Quotes
Sites & Companies
Workers
Catalog          (ADMIN)
Reports          (links to Metabase)
Settings         (ADMIN: geofence default, photo minimum, start window)
```

## Dashboard

```text
New requests
Today's visits (by crew), with per-worker state: not started / working / on break / submitted
Unstaffed visits
Timesheets flagged for review
Quotes awaiting answer / expiring soon
Sites with materials installed (count)
Workers off today
```

Worker states are only as fresh as the last sync from each phone. The dashboard shows each worker's "last synced" time.

## Timesheets

For each worker and day, the manager sees:

- every time entry, with work and break totals
- GPS checks on a map (site pin, geofence circle, check points with accuracy)
- photos and the comment
- flags: `OUTSIDE_GEOFENCE`, `MOCK_LOCATION`, `LOW_ACCURACY`, `CLOCK_SKEW`, `TOTALS_MISMATCH`, `LATE_SYNC`

Actions: **approve**, **adjust** (with a reason; the change is audited), or **override the location** (with a reason). Approving a task makes its `pay_amount` count as earned in the worker app. Approved time and pay can be exported to CSV for payroll.

As built (2026-10-18, `app/modules/timesheets`):
- One row = one `visit_assignment` that is `IN_PROGRESS` or `SUBMITTED`, filtered by the start of the visit. Work and break totals are always **recomputed from `time_entries`** (an open entry counts until now), never taken from the app.
- **Approve**: only `SUBMITTED` tasks (otherwise `409 NOT_SUBMITTED`); it is idempotent. It sets `reviewed_by`/`reviewed_at` and audits `timesheet.approved`. In the list, approval is one click only for tasks without flags; flagged tasks are approved from the detail page.
- Approval **locks** the timesheet: after it, adjust, location override and crew pay changes return `409 ASSIGNMENT_REVIEWED`.
- **Adjust** changes one time entry's start and end. It needs a reason, may not overlap another entry (`409 TIME_ENTRY_OVERLAP`, from the exclusion constraint), recomputes `assignment_completions.work_seconds/break_seconds`, and audits `timesheet.adjusted` with before, after and reason.
- **Override location** records the reason on the check (`override_reason`, `overridden_by`). It removes `OUTSIDE_GEOFENCE` once no outside, non-manual check is left without a reason, and audits `location_check.overridden`.
- **CSV** (`export.csv`) lists approved tasks only. It is UTF-8 with a BOM (Excel shows Armenian and Russian names), with columns `date, employee_code, worker, job, role, work_hours, break_hours, pay_amount, currency, approved_at, approved_by` and dates in Yerevan. The web app downloads it with the session cookies (`downloadFile` in `client.ts`).
- Photos on the detail page use short-lived presigned GET URLs (`Storage.presign_get`).
- The map reuses the site map and adds green (on site or accepted) and red (outside) dots for the checks.

## 13a. Info views (worker and company statistics)

As built (2026-10-19, `app/modules/insights`, read-only, MANAGER/ADMIN).

These pages are linked from the **Info** button on each row of Workers and Companies. They take a window of Yerevan dates (`from`/`to`, inclusive). The default window is the last 12 months including the current one. Each page has a month-by-month table, a **Raw data** table and **Export CSV** (UTF-8 with BOM).

**Worker** (`/workers/{id}`):
- Tasks assigned, submitted, approved and cancelled.
- Approved pay.
- Averages:
  - pay per month and tasks per month, counted only over the months since the worker's first task in the window
  - pay per approved task
  - work and break time per submitted task
- Total work time, approval rate, flag rate, and the first and last task.
- Raw data: every task in any status, with the timesheet row fields and an **Explore** link to the timesheet.

**Company** (`/companies/{id}`):
- Projects (by status), sites, and jobs by type.
- Visits done and tasks submitted.
- Worker hours, and the average per visit (over visits with submitted work).
- **Crew pay**: the pay of submitted tasks, i.e. NEST's labour cost.
- Materials installed, retrieved, and damaged or lost.
- The first and last visit.
- Raw data: one row per job, with visits, dates, hours and crew pay.
- Revenue per company comes with quotes (Phase 5).

Everything is computed from the operational tables per request, which is fine at this size. Cross-cutting reports stay in Metabase (§27).

```text
GET /insights/workers/{id}?from=&to=          totals, averages, months
GET /insights/workers/{id}/tasks?from=&to=    raw tasks (TimesheetRowOut, all statuses)
GET /insights/workers/{id}/tasks.csv
GET /insights/companies/{id}?from=&to=
GET /insights/companies/{id}/jobs?from=&to=   raw jobs
GET /insights/companies/{id}/jobs.csv
```

In the timesheet list, the job title is no longer a link. Each row has an **Explore** button (under **Approve** when that is shown) that opens the timesheet.

---

# 14. Scheduling

The manager must be able to:

- create one or more visits for a job (date, start, end)
- assign a crew (one LEAD + members) to each visit; each member gets their own task in the app, with its own fixed `pay_amount` (§8)
- copy a crew/time across consecutive days (multi-day installations)
- reschedule or cancel visits (the affected workers get a push)
- see worker availability (existing assignments + time off)

Calendar views (built as the two modes of the planning timeline, §14a):

```text
Day      (by worker, resource timeline)
Week     (by worker)
Month    (by project)
```

Example:

```text
             Mon            Tue            Wed
Arman (L)    INST #12       INST #12       INSP #15
             08:00–17:00    08:00–17:00    10:00–11:00
David        INST #12       INST #12       -
Karen        SURV #14       INST #12       DISM #9
             10:00–11:30    08:00–17:00    09:00–16:00
```

### v1 rules

- No overlapping assignments per worker (DB exclusion constraint, §8).
- Warning (not a block) if the visit falls in `worker_time_off` or outside default working hours.
- A worker must have the required skill for the job type (warning).

Travel time, automatic scheduling and route optimization come later.

---

# 14a. Planning Timeline (Gantt chart)

Status: **v1 built (2026-10-19)**: read-only, both modes, all three zooms ("As built" at the end of this section). v1.1 (dragging a visit) is next when needed. It replaces the separate "Calendar" screen: the views in §14 become two modes of one timeline screen (`/planning`).

### Why

NEST's work is time-shaped. A project's net or dust screen stays on site for weeks or months, between installation and dismantling, and inspections happen while it is up. The managers need to answer these at a glance:
- what is installed where, and until when
- which dismantlings are coming up or overdue
- which visits still have no crew
- who is busy on which days

A list of jobs can't show this.

### Mode 1: by project (the Gantt)

```text
                        Oct 13   Oct 20   Oct 27   Nov 3 … Dec 15
P-2026-0003 Davtashen   [■■ INST]━━━━━━━━━━━━━━ on site ━━━━━━━━━━━━[DISM]
  Install Safety Net    ■■                                    (2 visits)
  Monthly inspection             ▲          ▲          ▲
  Dismantling                                                    □ (no crew)
P-2026-0005 Komitas          [SURV]  ┄┄┄┄ expected ┄┄┄┄
```

- One **row per project** with status WON, INSTALLED or DISMANTLED, plus QUOTED projects that have an expected install date. The row expands into one sub-row per job.
- **Project bar**:
  - planned: `expected_install_date` → `expected_dismantle_date`, dashed
  - actual "on site" period: first DONE installation visit → last DONE dismantling visit (or today if not dismantled yet), solid
- **Visit bars** on the job rows, coloured by job type. A visit without a crew is outlined only, a cancelled visit is not shown, and a DONE visit is dimmed.
- **Markers**:
  - a "today" line
  - **overdue dismantling**: the project is INSTALLED and `expected_dismantle_date` < today, shown in red
  - the dismantle date approaching within 7 days, shown in amber
- **Zoom**: 2 weeks (day columns), 3 months (week columns, the default), 1 year (month columns). Scroll left and right; "Today" button.
- Hovering a bar shows the time, the crew and the status. Clicking a bar opens the job page (§13).

### Mode 2: by worker (resource timeline)

- One row per active worker; the bars are that worker's assignments (`GET /schedule`), coloured by job type. Days without work are empty.
- Time off (`worker_time_off`) is shown as striped grey blocks with the reason (built 2026-10-20).
- This is the §14 Day/Week view. It answers "who is free on Thursday" before the manager opens the crew editor.

### v1 scope (deliberately small)

- Read-only, plus click-through to the job. Visits are still created and changed on the job page, where the double-booking checks and their messages already exist.
- **Not in v1**: dependencies and arrows between jobs (NEST's order is fixed by the lifecycles, §10–§11), critical path, percent complete, baselines, PDF export.
- **v1.1**: drag a visit bar to another day. This calls the existing `PATCH /visits/{id}`, keeps the same time of day, and shows `WORKER_ALREADY_BOOKED` inline and snaps back on 409. The crew is notified as with any other reschedule.

### Backend

- `GET /api/v1/planning/projects?from=&to=` (MANAGER/ADMIN, read-only). It returns the projects that overlap the window, each with:
  - its jobs
  - non-cancelled visits, each with crew count and names
  - planned dates and the derived actual on-site period
- It loads everything in one round of queries (no N+1) and lives in its own read-only module, `app/modules/planning`.
- Mode 2 reuses `GET /schedule?from=&to=&worker_id=`.
- No schema change: everything comes from `projects`, `jobs`, `job_visits` and `visit_assignments`.

### Frontend

- Our own component (`src/components/timeline.tsx`): CSS grid for the date axis and absolutely positioned bars (left and width computed from Yerevan dates), sticky row labels, and hy/ru/en labels from the existing i18n.
- **No Gantt library.** We have at most ~50 rows and need Yerevan dates, our three languages and our styles. Libraries add weight and licensing questions (dhtmlx-gantt is GPL/commercial) and are hard to restyle. If v1.1 drag-and-drop turns out hard, pointer events on the bar are enough; no drag library is needed.

### Tests

- API: the window filter (a visit straddling the edge is included), the derived on-site period, overdue detection, and authorization (a worker gets 403).
- Web: typecheck, lint and build, and a manual check in the browser with the demo seed (the seed gets a long-running INSTALLED project with monthly inspections and an expected dismantle date).

### As built (2026-10-19)

- `GET /planning/projects?from=&to=`: Yerevan dates, both inclusive. The default window is a week back to 12 weeks ahead; at most 400 days, otherwise 422.
- A project is shown when any of these holds:
  - it has a non-cancelled visit in the window
  - its planned period overlaps the window
  - its on-site period overlaps the window
- The on-site period starts at the first DONE installation visit. It ends at the last DONE dismantling visit, and only once the project is DISMANTLED or CLOSED; until then it runs to now.
- `dismantle_soon` covers today and the next 7 days. `unstaffed_visits` counts PLANNED visits in the window that have no crew.
- Rows are sorted by their earliest date.
- The demo seed sets planned dates on every project and adds past DONE installations (Building D 50 days ago, Building E 60 days ago) plus a past inspection:
  - Building D's dismantling is overdue
  - Building C's is due within a week
  - Building E comes down today
- Web (`/planning`, `src/components/timeline.tsx`):
  - mode, zoom and start date are kept in the URL; ← / → move half a window; "Today" resets
  - project rows collapse
  - in the 2-week zoom, a visit shows its crew size and weekends are shaded
  - visits on the worker rows are dimmed once submitted
  - colours per job type are CSS tokens (`--jt-*`, with light and dark values)
- The app shell's content column is now `minmax(0, 1fr)`, so the wide timeline scrolls inside its card instead of stretching the page.

---

# 15. Quotes

```text
Quote v1  DRAFT ──► SENT ──► ACCEPTED ──► project WON, installation job created
                      │
                      ├──► REJECTED / EXPIRED ──► project LOST (or new version)
                      └──► revision ──► Quote v2 DRAFT (v1 SUPERSEDED)
```

- Lines come from `catalog_items` (with default prices) or free text.
- Survey measurements (e.g. m² of façade) are copied into the quote lines.
- A background task renders the PDF from an HTML template (WeasyPrint) in the quote's locale (hy/ru/en). The PDF is stored in object storage.
- The manager sends the quote manually for v1. The system records `sent_at`.
- A nightly task marks quotes past `valid_until` as EXPIRED.

---

# 16. Materials on Site

The crew lead records materials in the worker app, as part of completing the task:

```text
INSTALLATION  → INSTALLED   (e.g. 420 m² safety net, 60 anchors)
INSPECTION    → DAMAGED / ADJUSTMENT
DISMANTLING   → RETRIEVED   (app shows the expected list from the ledger)
              → LOST / DAMAGED for the difference
```

The manager sees per site: what is currently installed, and what was retrieved, damaged or lost.

---

# 17. NEST Worker App (Flutter)

The full build spec is in **`docs/WORKER_APP_SPEC.md`**. This section only summarizes it.

## Architecture

```text
presentation (widgets, Riverpod notifiers)
        │
        ▼
domain (entities, state machine, duration & geofence logic, repository interfaces)
        │
        ▼
data (Mock* and Api* repositories, DTOs, local DB, outbox)
        │
        ▼
NEST API (/api/v1/worker/*)
```

- Feature-based folders: `auth`, `tasks`, `work`, `completion`, `history`, `profile`, `notifications`.
- **Local-first:**
  - Tasks are cached in a local SQLite database (drift).
  - Work/break sessions, location checks, photos and completions are written locally first.
  - An **outbox** syncs them to the API with client UUIDs, so retries never create duplicates.
- Timers are calculated from stored timestamps; no counter is used.
- Starts with mock repositories. Api repositories replace them without any UI changes.

## Main flow

```text
Login → Tasks → Task details → Verify location (GPS within radius)
  → Start working → Work timer ⇄ Break timer (any number of cycles)
  → Finish task → [Materials (lead)] → Photos (≥1) → Comment → Confirm → Submit
  → waitingForSubmission → (sync) → completed → History
```

---

# 18. Worker API (`/api/v1/worker/*`)

Every endpoint is scoped to the authenticated worker. The writes are **idempotent PUTs keyed by client UUIDs**, so the outbox can safely replay them.

```http
GET  /api/v1/me
GET  /api/v1/worker/config                       # geofence default, accuracy limit, min photos, start window, telegram_bot_username
GET  /api/v1/worker/tasks?from=&to=              # assignments + visit + job + site (lat/lng, radius) + crew
GET  /api/v1/worker/tasks/{assignment_id}
GET  /api/v1/worker/tasks/{assignment_id}/expected-materials   # dismantling list
GET  /api/v1/worker/catalog                      # trackable materials, names in the user's locale (hi/id → en)

PUT  /api/v1/worker/location-checks/{uuid}
PUT  /api/v1/worker/time-entries/{uuid}          # create, then update with ended_at
PUT  /api/v1/worker/material-movements/{uuid}
PUT  /api/v1/worker/checklists/{uuid}

POST /api/v1/worker/files/{uuid}/presign         # → presigned PUT URL
POST /api/v1/worker/files/{uuid}/confirm

PUT  /api/v1/worker/tasks/{assignment_id}/completion/{uuid}
GET  /api/v1/worker/history?cursor=
GET  /api/v1/worker/earnings?month=YYYY-MM       # → { month, approved_tasks, approved_amount, currency }

GET  /api/v1/worker/notifications?cursor=
POST /api/v1/worker/notifications/{id}/read
PUT  /api/v1/worker/devices/{fcm_token}          # register push token
```

Rules:

- A worker can never reach another worker's assignments; the API returns `404`.
- Every PUT can be replayed. If it arrives again with the same body, the server returns `200` with the stored record. If it arrives with a different body for an already-finalized record, the server returns `409`.
- Requests include `X-Device-Time`. The server stores `client_clock_offset_s` and flags large differences.
**As built (Phase 2b, 2026-10-12)** — `app/modules/{worker_api,timetracking,materials,files,notifications}`:

- Task ids are assignment ids (integers). `GET /worker/tasks` returns tasks whose scheduled start is in `[from, to]` (at most ~2 months), **including cancelled ones**, so the app can show "cancelled by your manager". Each task has site pin, radius (null → config default), project name, customer, site contact and crew.
- Writes, their replay rules and stable error codes:

  | Endpoint | Same body again | Rejections |
  |---|---|---|
  | `PUT location-checks/{uuid}` | 200 | `LOCATION_CHECK_FINALIZED` (changed body) |
  | `PUT time-entries/{uuid}` | 200 | only `ended_at` may be added to an open entry, else `TIME_ENTRY_FINALIZED`; `TIME_ENTRY_OVERLAP` (`no_time_overlap`) |
  | `PUT material-movements/{uuid}` | 200 | `NOT_CREW_LEAD` (403), `MATERIAL_FINALIZED` |
  | `POST files/{uuid}/presign` | fresh URL, same key; `already_uploaded` once confirmed | `FILE_TOO_LARGE` (422) |
  | `POST files/{uuid}/confirm` | 200 | `FILE_NOT_UPLOADED` (object not in storage yet) |
  | `PUT tasks/{id}/completion/{uuid}` | 200 | `TASK_ALREADY_SUBMITTED` (other uuid), `START_CHECK_MISSING`, `PHOTOS_NOT_UPLOADED` (+`photo_ids`), `NOT_ENOUGH_PHOTOS`, `MATERIALS_REQUIRED` |

  Any new write on a cancelled task → `409 TASK_CANCELLED`; on a submitted one → `409 TASK_ALREADY_SUBMITTED`. Replays of already stored records still return 200.
- The server recomputes the GPS distance from the site pin. `OUTSIDE_GEOFENCE` (any purpose except MANUAL), `LOW_ACCURACY` and `MOCK_LOCATION` are added to `visit_assignments.review_flags`; `CLOCK_SKEW` when `X-Device-Time` differs by more than `clock_skew_flag_seconds`; `LATE_SYNC` when a time entry arrives > 24 h after it ended; `TOTALS_MISMATCH` when reported totals differ from the recomputed ones by > 60 s. None of these reject the data.
- The first WORK entry moves the assignment ASSIGNED → IN_PROGRESS and the job SCHEDULED → IN_PROGRESS. Completion closes open entries at `completed_at`, recomputes totals, then: visit DONE when all active assignments are SUBMITTED → job COMPLETED when no PLANNED visit remains → project INSTALLED / DISMANTLED for installation / dismantling jobs (only if the project is at the step before).
- In-app notifications are created in the same transaction for TASK_ASSIGNED (added to a crew), TASK_CHANGED (visit moved), TASK_CANCELLED (removed, visit or job cancelled) and SUBMISSION_ACCEPTED, in the recipient's locale. FCM delivery is Phase 3.
- `PUT /worker/devices/{fcm_token}` and the inspection checklist (`PUT /worker/checklists/{uuid}`) are not built yet (Phase 3 / Phase 5).
- `earnings` counts the worker's own approved assignments (`reviewed_at` set) whose visit date falls in the given Yerevan month, and sums their `pay_amount` (assignments without one count as 0). `approved_amount` is a decimal string such as `"80000.00"`, never a float.
- The server does **not reject** late or offline data because of its timestamps. It stores the data and flags it for manager review. Hard rejections are limited to authorization, impossible states (e.g. completing a cancelled task) and overlapping time entries.

---

# 19. Time Tracking and GPS Verification

### GPS check (client)

1. Request permission and check that location services are on.
2. Get a high-accuracy fix. If `accuracy_m` is worse than `max_location_accuracy_m`, show "GPS signal too weak, try again outdoors".
3. Compute the Haversine distance to the site pin.
4. The check is verified if `distance ≤ radius` (the radius comes from the task, or `/worker/config`).
5. Save the `location_check` locally (lat, lng, accuracy, isMocked, timestamp, distance, verified) and add it to the outbox.

A verified START check is required to start the work timer. Location is also captured, without blocking, on RESUME and COMPLETION.

### GPS check (server)

- Recompute the distance from the site pin stored on the server, and apply the server's radius.
- Flags: `OUTSIDE_GEOFENCE`, `MOCK_LOCATION`, `LOW_ACCURACY`.
- A manager can override a check with a reason, for example when the site pin was wrong.

**GPS verification is not tamper-proof.** It is evidence for the manager to review. It is not a security guarantee.

### Timer

- Work and break sessions are `time_entries` with `started_at` / `ended_at` device timestamps. The app shows `now − started_at` for the open entry.
- The session state is persisted locally before the UI updates, so it survives the app being killed or the phone rebooting.
- Totals = the sum over closed entries plus the open entry. Several work/break cycles per task are supported.
- The server checks for overlaps (constraint) and clock skew (offset flag), and recomputes the totals.

---

# 20. API Structure

Versioned REST under `/api/v1/`. Operational endpoints that are not part of the business API (currently only `GET /health`) live outside the version prefix.

```text
/api/v1/auth
/api/v1/me
/api/v1/public/assessment-requests      (service key only)
/api/v1/assessment-requests
/api/v1/companies   /contacts   /sites
/api/v1/projects
/api/v1/quotes
/api/v1/catalog
/api/v1/jobs        /visits
/api/v1/timesheets
/api/v1/workers
/api/v1/materials
/api/v1/files
/api/v1/settings
/api/v1/integrations/telegram/webhook   (Telegram bot, secret header)
/api/v1/worker/...                      (worker-scoped, §18)
```

## Example endpoints (manager)

### Authentication

```text
POST   /auth/login
POST   /auth/refresh
POST   /auth/logout
POST   /auth/change-password
GET    /me
```

### Assessment requests

```text
POST   /public/assessment-requests
GET    /assessment-requests
GET    /assessment-requests/{id}
PATCH  /assessment-requests/{id}
POST   /assessment-requests/{id}/convert
POST   /assessment-requests/{id}/reject
```

### Projects & quotes

```text
POST   /projects
GET    /projects
GET    /projects/{id}
PATCH  /projects/{id}
POST   /projects/{id}/quotes
PATCH  /quotes/{id}
POST   /quotes/{id}/send
POST   /quotes/{id}/accept
POST   /quotes/{id}/reject
POST   /quotes/{id}/revise
GET    /quotes/{id}/pdf
```

### Jobs & scheduling

`PUT /visits/{id}/crew` takes the **complete** crew `{members: [{worker_id, role, pay_amount}]}` with exactly one LEAD. Workers left out are cancelled (a SUBMITTED one can't be removed → `409 ASSIGNMENT_ALREADY_SUBMITTED`). A crew appearing or disappearing moves the job DRAFT ⇄ SCHEDULED, and a scheduled SURVEY job moves the project to SURVEY. `DELETE /visits/{id}` cancels; nothing is hard-deleted. Visit times must include a timezone.

```text
POST   /jobs
GET    /jobs
GET    /jobs/{id}
PATCH  /jobs/{id}
POST   /jobs/{id}/cancel
POST   /jobs/{id}/visits
PATCH  /visits/{id}
DELETE /visits/{id}
PUT    /visits/{id}/crew
GET    /schedule?from=&to=&worker_id=
GET    /planning/projects?from=&to=      planning timeline (§14a)
```

### Push devices (worker app)

```text
PUT    /worker/devices/{fcm_token}         {platform, app_version}; idempotent, 204
DELETE /worker/devices/{fcm_token}         own token only, 204
```

### Time off

```text
GET    /workers/{id}/time-off
POST   /workers/{id}/time-off              {first_day, last_day, reason, note}; 409 TIME_OFF_OVERLAP
GET    /workers/time-off?from=&to=         every worker's absences overlapping the dates (timeline, crew editor)
DELETE /workers/time-off/{id}
```

### Timesheets

```text
GET    /timesheets?from=&to=&worker_id=&flagged=&reviewed=
GET    /timesheets/assignments/{id}
POST   /timesheets/assignments/{id}/approve
POST   /timesheets/assignments/{id}/adjust
POST   /location-checks/{id}/override
GET    /timesheets/export.csv?from=&to=
```

### Workers

As built (Phase 3): list/search (`?q=&active=`), create (with a first password; `must_change_password`), edit, deactivate (`is_active=false` revokes all sessions) and reset password (temporary password, must change; sessions revoked). All audited. Time off comes next. `GET /services` lists the offered services for project forms.

```text
GET    /workers
GET    /workers/{id}
POST   /workers
PATCH  /workers/{id}
POST   /workers/{id}/reset-password
POST   /workers/{id}/time-off
```

### Materials

```text
GET    /sites/{id}/materials           (current on-site balance)
GET    /sites/{id}/materials/movements
POST   /materials/movements            (manager adjustments)
```

---

# 21. API Layering

```text
Router  (HTTP, auth dependency, schema in/out)
  │
  ▼
Service (business rules, transitions, transaction boundary, audit, enqueue tasks)
  │
  ▼
SQLAlchemy session
  │
  ▼
PostgreSQL
```

Example:

```text
PUT /worker/tasks/{id}/completion/{uuid}
   │
   ▼
worker_api/router.py
   │
   ▼
timetracking/service.py: submit_completion()
   ├── authorize: assignment belongs to current worker, not CANCELLED
   ├── idempotency: same uuid already stored → return it
   ├── guards: START check exists, photos ≥ min, lead materials/checklist present
   ├── close any open time entry at completed_at
   ├── recompute totals, set review_flags
   ├── assignment → SUBMITTED; visit → DONE if all submitted; job/project side effects
   ├── audit log
   └── enqueue "notify manager" if flagged (same transaction)
```

---

# 22. Database Access

```text
FastAPI → SQLAlchemy 2.x (async) → asyncpg → PostgreSQL
```

- Alembic manages migrations. The production schema is never changed by hand.
- Use a naming convention for constraints so Alembic autogenerate produces stable names.
- Required extension: `btree_gist`.

---

# 23. Offline Support and Sync (worker app)

Offline support is **v1**, because connectivity on construction sites is poor.

```text
User action ──► local DB (drift) transaction:
                  1. update local state (session / photo / completion)
                  2. append outbox item {uuid, endpoint, body, attempt, last_error}
            ──► UI updates from the local DB

SyncService (on connectivity change, app resume, periodic while foregrounded,
             and WorkManager background job on Android):
  for item in outbox (FIFO, per-task ordering preserved):
      send idempotent PUT/POST
      2xx      → mark done
      409/422  → mark failed with server message → task shows synchronizationFailed
      network/5xx → exponential backoff, retry
```

- Photos upload in three steps: presign → PUT to storage → confirm. Each step can resume. Images are compressed on the device first (~1600 px JPEG).
- The task list is refreshed from the server whenever the app is online. Local unsynced changes always win in the UI until the server confirms them.
- A manager change that conflicts with local work (e.g. the task was cancelled after the worker started) comes back as `409`. The worker sees a clear message, and the local data is kept for the manager.

---

# 24. File and Photo Storage

PostgreSQL stores **metadata only**. The file bytes go to S3-compatible object storage. Locally this is **RustFS** (docker compose `storage`, port 9000): MinIO's Docker images stopped being published in 2026. The code only uses the S3 API (`app/modules/files/storage.py`), so any S3 provider works.

Uploads use **presigned URLs**, so large files never pass through the API:

```text
Worker app                 FastAPI                  Object storage
    │  presign(uuid,task)    │                            │
    ├───────────────────────►│ check access, size, mime   │
    │◄───────────────────────┤ presigned PUT URL + key    │
    │  PUT file ─────────────┼───────────────────────────►│
    │  confirm(uuid) ───────►│ HEAD object, mark UPLOADED │
```

- Downloads use short-lived presigned GET URLs.
- Presigned URLs are signed for a host name, so the API signs with `S3_PUBLIC_ENDPOINT_URL` (the host phones can reach; `http://10.0.2.2:9000` for the Android emulator) and checks uploads with `S3_ENDPOINT_URL`.
- Object keys: `assignments/{assignment_id}/{file_uuid}.jpg`. Max size `MAX_UPLOAD_BYTES` (15 MB); images only (`image/jpeg|png|heic|webp`).
- The storage provider can be changed without changing the database model.

---

# 25. Maps and Addresses

Sites store `address`, `latitude`, `longitude`, `location_confirmed` and `geofence_radius_m`.

Geocoding of Armenian addresses is unreliable. A manager **places or confirms the pin on a map**, and the pin is the authoritative location. The GPS geofence depends on this pin, so a wrong pin produces false "outside work area" results. When a worker reports a wrong pin, the manager overrides the check and fixes the pin.

Example:

```text
address:   12 Abovyan Street, Yerevan
latitude:  40.1812
longitude: 44.5146
radius:    150 m
```

The pin is used for:

- map previews
- GPS verification
- "Navigate" deep links (Google Maps, Yandex Navigator)
- later: distance and travel-time planning

---

# 26. Notifications

Notifications are created by the backend: the business change inserts a `notifications` row and enqueues a delivery task, in the same transaction.

**Workers:**
- FCM push to every registered device (APNs on iOS, via FCM). Firebase is only the delivery transport: notification content, recipients and read state live in PostgreSQL, and no other Firebase service is used.
- The in-app notifications screen reads `/worker/notifications`.

**Managers:**
- In-app notification list in the manager app.
- Optional Telegram bot for urgent alerts.

```text
Manager staffs a visit
        │
        ▼
FastAPI (transaction: assignment + notification row + task)
        │
        ▼
Task worker ──► FCM ──► worker's phone
```

Events:

```text
To workers:   task assigned · task changed · task cancelled · reminder (evening before / morning of)
              · submission accepted
To managers:  new website request · task submitted · flagged timesheet · NO_ACCESS reported
              · quote expiring
```

Notification text uses the recipient's locale (hy/ru/en/hi/id).

### As built (2026-10-20)

- **The row is the job.** A business change inserts the `notifications` row as `PENDING` in its own transaction. Nothing else is enqueued, so a push can't be lost between commit and enqueue.
- **The push worker** (`python -m app.cli push-worker`, `app/modules/push`) is a separate process from the same codebase:
  - every 5 s it claims due rows with `FOR UPDATE SKIP LOCKED` (so several workers are safe) and sends to all of the user's devices
  - any success → `SENT`
  - UNREGISTERED tokens are deleted
  - transient errors (network, 429, 5xx) retry with backoff (60 s, 2 min, 4 min…) and become `FAILED` after 5 attempts
  - no device → `SKIPPED`
  - older than 12 h → `SKIPPED`, because a stale buzz is worse than none
- **Reminders**: once a minute the worker adds `TASK_REMINDER` rows, idempotently by `dedupe_key` = assignment + kind + start time, so a rescheduled visit is reminded again:
  - `tomorrow`: from 19:00 Yerevan, for tasks starting tomorrow that were assigned before 19:00
  - `soon`: 1 hour before the start
  - both only for tasks still `ASSIGNED` on a `PLANNED` visit
  - the text is localized, e.g. "Reminder · Install Safety Net · tomorrow at 09:00, Building A"
- **Transport** (`app/modules/push/sender.py`, behind a `PushSender` interface):
  - `PUSH_PROVIDER=log` (development) only logs
  - `PUSH_PROVIDER=fcm` uses FCM HTTP v1 with the service-account JSON (`FCM_CREDENTIALS_FILE`, a secret file, never committed)
  - the OAuth token is an RS256 JWT exchanged at Google's token endpoint (PyJWT + httpx, no Google SDK) and cached for about 1 h
  - the message carries the title/body plus data `{notification_id, type, assignment_id}`
- **Worker app**: `FcmPushService` (only `firebase_core` + `firebase_messaging`):
  - Firebase is configured from `android/app/google-services.json` (one file for both flavors' apps, git-ignored), read by the Google services Gradle plugin. The plugin is applied only when the file exists, so builds without it (CI, a fresh clone) still work, and push just stays off. No Analytics or other Firebase SDKs are added
  - after sign-in it asks for notification permission, registers the token, and re-registers when the token rotates
  - tapping a push refreshes the tasks, waits until sign-in is restored (on a cold start), then opens the task; a push arriving while the app is open refreshes the bell and the task list
  - logout deletes the token on the phone
  - it uses the registration-token API; firebase_messaging 17 deprecates it in favour of FID "direct send", and switching is a later change on both the server and the app
- **Managers**: no push in v1 (their notifications are in-app).

### Setup (to do once, by the owner)

1. Create a Firebase project (console.firebase.google.com). Use only Cloud Messaging; don't enable Analytics.
2. Add two Android apps: `am.nest.worker` (prod) and `am.nest.worker.dev` (dev). Download `google-services.json` after adding the second app, so it lists both, and put it at `apps/worker-mobile/android/app/google-services.json` (git-ignored). Ignore the console's "add firebase-analytics" step.
3. Project settings → Service accounts → generate a private key. Save the file outside the repo, or as `service-account-fcm.json`, which `.gitignore` keeps out of Git.
4. Set `PUSH_PROVIDER=fcm` and `FCM_CREDENTIALS_FILE=<path>` for the API host, and run the push worker next to the API (on the production compose, a second service with the same image).

Done for development on 2026-10-21 with Firebase project `nest-test-1adbc`. Verified on the emulator: the token is registered; a TASK_ASSIGNED push arrives in Armenian with the app in the background and after its process was killed; tapping it opens the new task. A production project and keys are still to be made.

---

# 26a. Crew Chat with Translation (Telegram bot)

Decided 2026-10-12; changed the same day to **Telegram only**. This is v1, built in **Phase 3b** (§41). Crews include foreign workers (Hindi, Indonesian), so every message reaches each reader in their own language. Every worker installs Telegram. The NEST apps have **no chat screen**; they only link the account and open the bot.

### How it works: the bot relays messages

Normal Telegram groups can't be used: every message would appear once per language. Instead, each person chats **privately with the NEST bot**, and the bot relays messages:

```text
Ravi (hi) ──► NEST bot ──► API: store message, detect language, translate
                              ├──► Arman (hy):  "[J-12 Davtashen · Building A] Ravi (worker): …" in Armenian
                              ├──► Budi (id):   same, in Indonesian
                              └──► managers:    same, each in their locale
```

- **One thread per job.** Members are every worker with a non-cancelled assignment on any visit of the job, plus all MANAGER/ADMIN users with a linked Telegram. Membership is computed when a message is sent, not stored, so a worker who is unassigned stops receiving messages.
- **Which job a message belongs to:**
  1. A **reply** to a relayed message goes to that message's job (`telegram_message_links`).
  2. Otherwise it goes to the sender's **current job**. The current job is set by the "Crew chat" button in the app (deep link `t.me/<bot>?start=job_<id>`), or by `/job`, which shows inline buttons. If the worker has exactly one job today, that job is used automatically.
  3. If the job is still unclear, the bot asks with inline buttons and does not send until a job is chosen.
- **Content:** text is translated. Photos and voice notes are relayed as they are (`copyMessage`), with a translated caption. Photos are also stored as job `files` later if needed (not v1).
- Messages are not edited or deleted through the bot in v1. An admin can hide a message (`hidden_at`, audited); hidden messages are not relayed.

### Translation

- The API detects the source language and translates into every **other** locale used by the recipients. Each translation is stored once per language (`chat_message_translations`).
- Provider: **Google Cloud Translation** (supports hy/ru/en/hi/id), behind a `Translator` interface in `app/modules/chat/translation.py`. Setting `GOOGLE_TRANSLATE_API_KEY`. This is a Google Cloud API, not a Firebase service. Machine translation of chat is the only exception to "no AI features" (§43).
- If translation fails, the original is relayed with a "(not translated)" note. Delivery is never blocked by translation.

### Linking Telegram (workers and managers)

- The worker app (Profile → **Connect Telegram**) and the manager web app call `POST /api/v1/me/telegram-link` → `{ url, expires_at }`, a `t.me/<bot>?start=link_<one-time code>` link valid for 15 minutes. Opening it in Telegram and pressing Start stores `users.telegram_chat_id`.
- `GET /api/v1/me` returns `telegram_linked: bool`. The app shows "Connect Telegram" until it is linked, then "Open crew chat".
- Unlinking: `/stop` in the bot, or `DELETE /api/v1/me/telegram-link`. Deactivating a user unlinks them too.

### Processing

- Webhook: `POST /api/v1/integrations/telegram/webhook`, verified with Telegram's `X-Telegram-Bot-Api-Secret-Token` header (`TELEGRAM_WEBHOOK_SECRET`). The handler stores the update and the message in one transaction (the stored row is the job for the background worker, §37) and returns `200` immediately. Updates are deduplicated by `update_id`, because Telegram retries.
- Task: translate → send to each recipient (respecting Telegram's rate limits; retried on `429` with `retry_after`) → store `telegram_message_links`.
- The same bot sends the manager alerts from §26. Worker task pushes stay on FCM.

### Data model

```text
chat_threads              id, job_id (unique), created_at, updated_at
chat_messages             id uuid, thread_id, sender_user_id, kind (TEXT | PHOTO | VOICE),
                          body text nullable (≤ 4000), source_lang nullable,
                          telegram_chat_id, telegram_message_id, hidden_at, created_at
chat_message_translations message_id, lang, body, provider, created_at   PK (message_id, lang)
telegram_updates          update_id (PK), received_at        (dedup of webhook retries)
telegram_link_codes       code (unique), user_id, expires_at, used_at
telegram_chat_contexts    user_id (PK), current_thread_id, updated_at
telegram_message_links    telegram_chat_id, telegram_message_id, chat_message_id
                          PK (telegram_chat_id, telegram_message_id)
```

### Later (only if needed)

A read-only chat history per job in the manager web app; an in-app chat screen. Both read the same tables.

---

# 27. Reporting and Analytics

### v1: Metabase on PostgreSQL

```text
PostgreSQL ──(read-only role, `reporting` schema views)──► Metabase
```

- Create SQL views in a `reporting` schema (e.g. `reporting.jobs_flat`, `reporting.timesheets`, `reporting.quote_funnel`, `reporting.site_materials`).
- Metabase connects with a role that can only `SELECT` from `reporting`.

### Later: warehouse

BigQuery (with a nightly ELT) is worth adding only if one of these happens: data from other sources has to be combined, the data volume outgrows Postgres reporting, or there is a dedicated analyst. The `reporting` views translate directly into warehouse models:

```text
fact_jobs · fact_time_entries · fact_quotes · fact_material_movements
dim_date · dim_worker · dim_company · dim_site · dim_service
```

---

# 28. Metrics

### Sales

- Requests per week, by source and service
- Request → quote → won conversion
- Average quote value; win rate
- Time from request to survey, and from survey to quote

### Operations

- Jobs per type per week
- Installation duration (calendar days, crew work-hours)
- NO_ACCESS / cancellation rate
- Unstaffed visits

### Workers

- Work hours and break hours per worker per period
- On-time start rate (first verified START vs scheduled start)
- Flag rate (outside geofence, mock location, clock skew)

### Materials

- m² installed / retrieved per period
- Damage and loss rate per item
- Currently installed materials across all sites

### Geographic

- Projects by district/city

---

# 29. Security

## Backend

- HTTPS only (Caddy)
- Argon2id password hashing
- Short-lived access tokens + rotating refresh tokens
- Role-based and object-level authorization (§30)
- Pydantic input validation
- SQLAlchemy parameterized queries
- Rate limiting (login, public intake)
- CORS limited to the manager app origin (the mobile app doesn't need CORS)
- Security headers
- Service key for the website → API intake
- Audit logs

## Mobile app

- No secrets in the app binary. The only configuration is the API base URL per flavor (dev/prod), set with `--dart-define`.
- Tokens are stored in secure storage (Android Keystore / iOS Keychain).
- HTTPS only. Certificate pinning is optional later.
- GPS data and device timestamps are treated as **untrusted input**, which the server validates and flags.

## Database

PostgreSQL is never exposed to the internet.

```text
Internet ──► Caddy ──► API ──► PostgreSQL (private network)
                               ▲
                Metabase ──────┘ (read-only role)
```

## Secrets

Never commit:

```text
DATABASE_URL
SECRET_KEY / JWT_SECRET
CONTACT_API_KEY (service key)
FCM service account JSON
TELEGRAM_BOT_TOKEN
TELEGRAM_WEBHOOK_SECRET
GOOGLE_TRANSLATE_API_KEY
S3 credentials
TURNSTILE_SECRET
Android signing keystore + passwords
```

Use environment variables on the server, and GitHub Actions secrets for CI (including APK/AAB signing).

---

# 30. Authorization

All authorization happens on the backend.

```text
MANAGER  GET /jobs                 → allowed
WORKER   GET /jobs                 → 403
WORKER   GET /worker/tasks         → allowed (own assignments only)
WORKER   GET /quotes/...           → 403
```

Object-level authorization is enforced in the query itself:

```text
Worker A: GET /worker/tasks/500
→ SELECT ... FROM visit_assignments a WHERE a.id = 500 AND a.worker_id = :worker_a
→ no row → 404
```

---

# 31. Audit Logging

Important actions are recorded in the same transaction as the change.

```text
Manager converted REQ-2026-0042 to project #31
Manager sent quote Q-2026-0017 v2
Manager assigned Arman (lead), David to visit #210
Worker Arman started task #812 (GPS verified, 32 m)
Worker Arman submitted task #812 (7h15m work, 35m break, 4 photos)
Manager adjusted task #812 time (+15 min, reason: forgot to stop break)
Manager overrode location check on task #812 (reason: pin was wrong)
```

```text
audit_logs
----------
id
user_id
action
entity_type
entity_id
metadata  jsonb   (before/after of changed fields)
ip
created_at
```

---

# 32. Error Handling

Every error response has the same structure:

```json
{
  "error": {
    "code": "WORKER_ALREADY_BOOKED",
    "message": "Arman is already assigned to visit #205 at this time.",
    "details": { "conflicting_visit_id": 205 }
  }
}
```

HTTP status codes:

```text
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
409 Conflict              (invalid transition, double booking, cancelled task, overlapping time)
422 Validation Error
429 Too Many Requests
500 Internal Server Error
```

Error `code`s are stable, and the worker app maps them to localized messages. Internal stack traces are never shown to users. Errors are logged with a request ID, which the error response also includes.

---

# 33. Testing

## Backend (most of the testing effort goes here)

- pytest + HTTPX
- A real PostgreSQL test database (Docker), not SQLite, because the exclusion constraints and ranges need Postgres.

Test:

```text
Authentication and token rotation/reuse detection
Role and object-level authorization (worker isolation)
Every lifecycle transition table (allowed + forbidden)
Double-booking constraint → 409; overlapping time entries → 409
Idempotent replays of every /worker PUT (same body → 200, different → 409)
Server-side geofence recomputation and flags
Completion guards (photos, lead materials, START check)
Totals recomputation and mismatch flag
Quote versioning and totals; materials ledger balance
Public intake with/without service key
```

## Worker app

- Unit tests:
  - distance/radius verification
  - work and break duration across multiple cycles, including the app being restarted mid-session
  - the task state machine
  - completion validation (photo requirement, lead materials)
  - outbox retry/failure handling
- Widget tests for the key screens.
- Integration test of the full mock workflow (login → submit → history).

## Manager web app

- Playwright for the key flows only: request → convert → quote → accept → schedule crew → review timesheet.

---

# 34. Local Development

```text
PostgreSQL 17    localhost:5433   docker compose (host port; 5432 may be taken by a native install)
FastAPI          localhost:8000   local Python venv (Swagger at /docs)
Manager web app  localhost:3001   npm run dev
S3 storage       localhost:9000   docker compose `storage` (RustFS); `python -m app.cli init-storage` creates the bucket
Metabase         localhost:3030   added to docker compose when reporting is built (optional profile)
```

Development decisions (accepted 2026-10-07):

- Docker Compose runs **PostgreSQL and the S3 storage** (storage added 2026-10-12 with file uploads, as planned). The API runs directly from the local Python virtual environment (`apps/api/.venv`); an API container is added with the production deployment work.
- PostgreSQL version: **17**.
- The manager web app has **no Tailwind** for now; a styling approach is chosen when manager UI work starts.

- **Worker app**: `flutter run --flavor dev` runs against mock repositories (`USE_MOCKS` defaults to `true`). Against the local API: `flutter run --flavor dev --dart-define=USE_MOCKS=false --dart-define=API_BASE_URL=http://10.0.2.2:8000` (Android emulator → host).
- **Public website**: runs from its own repo (`F:\nest_web`, `npm run dev` → `localhost:3000`). Point `CONTACT_API_URL` at `http://localhost:8000/api/v1/public/assessment-requests`.
- **Seed data**: `python -m app.cli seed-demo [--reset]` (refused in production) creates the mock world for real: a manager and six workers (hy, ru, hi, id; password `nest1234`), five sites in Yerevan with pins, today's installation (Building A 09:00–13:30) and dismantling (Building E 14:00–18:00, with 300 m² net + 40 anchors on site), upcoming tasks, and two approved past tasks for history and earnings. Test it in the emulator with `adb emu geo fix 44.4930 40.2262` (Building A).
- **Live check of the app's HTTP client** (no emulator): `LIVE_API_URL=http://127.0.0.1:8000 flutter test test/live` runs the whole worker flow through `HttpNestApi` against a seeded API started with `S3_PUBLIC_ENDPOINT_URL=http://127.0.0.1:9000`.

---

# 35. Environments

```text
development   (local)
production
```

Add `staging` when there is a second person, or when risky migrations need a rehearsal. Until then, test migrations against a restored copy of the latest production backup before deploying.

Each environment has its own database, secrets, storage bucket and Firebase project (used for FCM only). The worker app has `dev` and `prod` build flavors. The production database is never used during local development.

---

# 36. Deployment and Backups

## v1 production

```text
                 Internet
                     │
                     ▼
               Caddy (HTTPS)
          ┌──────────┼──────────────┐
          ▼          ▼              ▼
   manager-web   FastAPI API     Metabase
   (Next.js)     + task worker   (restricted access)
                     │
                     ▼
                PostgreSQL ──► nightly backup ──► object storage
```

- One VM (e.g. Hetzner) running Docker Compose. The public website can stay on its current host (e.g. Vercel).
- **Backend/web CI**: run tests → build images → push to a registry → SSH deploy. Migrations run as a one-off step before the new API starts.
- **Worker app CI**: `flutter analyze` + `flutter test` → build a signed AAB/APK.
  - Distribution: direct APK for the first workers; Google Play internal testing track after that.
  - iOS: TestFlight when needed.
- **API compatibility**: workers won't all update the app immediately. Keep `/api/v1` backward compatible, and add a `min_supported_app_version` field to `/worker/config` so the app can ask for an update when it's too old.

## Backups

- Nightly `pg_dump` (custom format), encrypted, uploaded to object storage in a different provider or region. Keep 7 daily, 4 weekly and 6 monthly copies.
- Object storage: enable versioning or a lifecycle policy.
- **Do a test restore every month.** A backup that has never been restored is not a backup.

## Monitoring

- Uptime check on `/health`.
- Error tracking (e.g. Sentry) for the API, the manager app and the Flutter app.

---

# 37. Background Tasks

Background work is stored in **PostgreSQL** and run by a **separate worker process** from the same codebase. There is no Redis and no queue library.

The job is a row written in the same transaction as the business change: for push, the `notifications` row itself (§26 "As built"). Workers claim rows with `FOR UPDATE SKIP LOCKED`.

Decided 2026-10-20: procrastinate was planned, but with our asyncpg driver it can't enqueue inside the business transaction (it needs psycopg and its own connection). New kinds of background work follow the same pattern: a table, or a status column, plus a loop in the worker process.

Tasks:

- FCM push / Telegram alerts
- Task reminders (scheduled)
- Quote PDF rendering
- Quote expiry (nightly)
- Clean up files stuck in PENDING (uploads that were never confirmed)

Tasks are enqueued **inside the same transaction** as the business change.

---

# 38. Performance

At this scale, performance means doing the basics correctly:

- Indexes
- Pagination on all list endpoints
- Avoid N+1 queries (`selectinload`)
- Connection pooling

Important indexes:

```text
assessment_requests (status, created_at)
projects (status), projects (site_id)
jobs (project_id), jobs (status)
job_visits USING gist (period), job_visits (job_id)
visit_assignments (worker_id, status), gist (worker_id, period)
time_entries (assignment_id), gist (worker_id, tstzrange(...))
location_checks (assignment_id)
quotes (project_id, version)
site_material_movements (site_id, catalog_item_id)
files (owner_type, owner_id)
notifications (user_id, read_at)
```

---

# 39. Concurrency

- **Double-booking**: the `no_worker_overlap` exclusion constraint guarantees that only one of two simultaneous conflicting assignments succeeds. The other gets `409 WORKER_ALREADY_BOOKED`.
- **Time entries**: the `no_time_overlap` constraint prevents overlapping sessions, even if a phone replays data.
- **Offline replays**: client UUIDs plus idempotent PUTs mean duplicates are impossible.
- **Status transitions**: use `SELECT … FOR UPDATE` on the row, so two people can't apply conflicting transitions at once.
- **Manager vs worker** (e.g. a cancel while the worker is working): the server rejects worker writes to a CANCELLED assignment with `409`, and the app shows this clearly. The worker's local data is still uploaded as a note or flagged entry, so no hours are lost.
- **Sent quotes** are immutable.

The database and backend are the final authority.

---

# 40. API Contract

The OpenAPI schema generated by FastAPI is the official API contract.

```text
FastAPI ──► openapi.json ──┬──► openapi-typescript ──► manager-web typed client
                           └──► Flutter data/dto (hand-written json_serializable DTOs,
                                 contract test compares them to openapi.json in CI)
```

Domain models in the Flutter app are kept separate from DTOs. Mappers sit between them.

As built (2026-10-14): the contract is committed as `apps/api/openapi.json` (`python -m app.cli export-openapi`). `tests/test_openapi.py` fails when it is stale, and the worker app's `test/core/api/contract_test.dart` fails when a DTO's fields differ from its schema. Both run in CI.

---

# 41. Recommended Development Order

As a solo developer, alternate between the app and the backend so that each piece is tested against something real early.

## Phase 1 — Worker app on mocks + backend foundation

```text
Flutter: full mock workflow per docs/WORKER_APP_SPEC.md (login → … → history), tests
Backend: Docker Compose, PostgreSQL, FastAPI skeleton, Alembic, users/auth, audit, error format, CI
```

Status (2026-10-08): built. Users/workers/refresh tokens/audit logs (migration `0002`), auth endpoints (§7 "As built"), and GitHub Actions CI for all three apps (`.github/workflows/ci.yml`). Added to the worker app at the same time: the monthly earnings header (mock data until `/worker/earnings` exists in Phase 2) and the round flip timer.

## Phase 2 — Scheduling core + worker API

Status: **2a done (2026-10-12)**: companies, contacts, sites, settings, services, projects, jobs, visits, crew assignment with pay, transition tables (`app/core/transitions.py` + one table per lifecycle, tested edge by edge), manager endpoints, migration `0004`. **2b done (2026-10-12)**: the `/worker/*` API (§18 "As built"), photo storage, notifications, migration `0005`. **2c done (2026-10-14)**: the worker app's `HttpNestApi` (`USE_MOCKS=false`), token refresh, contract test (§40). **2d (2026-10-18)**: seed script (§34); live `HttpNestApi` test passes; on-device run on the emulator against the real API passed end to end (login → tasks → GPS → work/break → materials → camera photo → submit; server recomputed totals, no flags). **Remaining for Phase 2: the field test with 1–2 workers on real phones** (needs the API reachable from the phones: deploy, or LAN IP + `S3_PUBLIC_ENDPOINT_URL`).

```text
Companies, contacts, sites (pin + radius), projects, jobs, visits, crew assignment, constraints
/worker/* API: tasks, location checks, time entries, files, completion (idempotent)
Flutter: Api* repositories + outbox/SyncService; switch off mocks
Seed script; first real field test with 1–2 workers
```

## Phase 3 — Manager web app

Status: **first slice done (2026-10-18)**: cookie auth + CSRF, worker management API, manager screens for jobs/visits/crews, projects, sites (map), companies, workers, dashboard (§13 "As built"). **Timesheets done (2026-10-18)**: review, approve, adjust, location override and CSV, both API and web (§13 "Timesheets"). **Info views (2026-10-19)**: worker and company statistics (§13a). **Planning timeline v1 done (2026-10-19)** (§14a). **Worker time off done (2026-10-20)** (§8 `worker_time_off`, §13). **Push + reminders built (2026-10-20)** (§26 "As built"); pushes are only logged until the Firebase project exists (§26 "Setup"). Phase 3 is done apart from that setup.

```text
Login, dashboard, jobs/visits, crews, workers + time off
Timesheets review (map, flags, approve/adjust, CSV export)
Planning timeline (Gantt by project + resource view by worker, §14a; replaces "calendar")
FCM push + reminders
```

## Phase 3b — Crew chat with translation (§26a)

```text
Telegram bot (webhook, relay, job context, inline buttons); chat tables; translation task
Telegram linking: POST/DELETE /me/telegram-link, telegram_linked in /me
Flutter: Profile → Connect Telegram; "Crew chat" button on task details / work screen (deep link)
Manager web: Connect Telegram in profile
```

## Phase 4 — Intake

```text
Public intake endpoint (service key); connect nest_web /api/contact
Requests list / convert
Manager alerts on new requests
```

## Phase 5 — Quotes and materials

```text
Catalog, quotes (versions, PDF, send/accept/reject)
Materials step in worker app (lead), site balance, dismantling list
Inspection checklist
```

## Phase 6 — Reporting

```text
reporting schema views; Metabase dashboards (funnel, hours, materials)
```

## Phase 7 — Later, only when needed

```text
Client portal; invoices and payments; warehouse stock
Travel time / route planning; live location; BigQuery
```

---

# 42. MVP Scope

### Website

- Existing site, with its form connected to the API

### Manager web app

- Login
- Requests: list, detail, convert, reject
- Companies, contacts, sites (map pin, geofence radius)
- Projects; jobs with visits; crew assignment; planning timeline (Gantt, §14a)
- Worker management + time off + password reset
- Timesheets review
- Connect Telegram (crew chat runs in the NEST Telegram bot, §26a)
- Quotes with PDF
- Materials on site

### Worker app (Flutter, Android first)

- Login (phone + password), session kept in secure storage
- Tasks (today / upcoming), task details with map and navigate link
- GPS verification against the site geofence
- Work / break timers (timestamp-based, multiple cycles)
- Finish: materials (lead), photos (≥1), comment, confirm, submit
- Offline-first with outbox sync and clear sync states
- History, profile (language hy/ru/en/hi/id, permissions, logout)
- Push + in-app notifications
- Crew chat per job in the NEST Telegram bot with automatic translation; Connect Telegram + "Crew chat" button (§26a)

### Backend

- FastAPI + PostgreSQL
- Auth, RBAC, object-level authorization
- REST API + OpenAPI contract
- Idempotent worker sync API, server-side GPS/time validation and flags
- Audit logging, Postgres task queue, backups

### Reporting

- Metabase on `reporting` views (can ship just after the MVP)

---

# 43. Things We Should NOT Build Initially

- Integrations with third-party task/CRM systems (Planfix etc.)
- Firebase services other than FCM push (no Firebase Auth, Firestore, Realtime Database, Storage, App Distribution); also no Supabase
- BigQuery / ETL pipeline
- Microservices
- Kubernetes
- Kafka or event streaming
- Redis / Celery
- Load balancer / multiple API instances
- Continuous real-time GPS tracking
- Automatic scheduling / route optimization
- AI features (exception: machine translation of crew chat, §26a)
- Client portal
- Invoicing / payments
- Warehouse inventory

Start with a modular monolith:

```text
                          FastAPI
                             │
   ┌──────┬───────┬──────────┼──────────┬───────────┬──────────┬────────┐
   │      │       │          │          │           │          │        │
  Auth  Intake  Projects   Quotes      Jobs   TimeTracking  Materials Notify
   │      │       │          │          │           │          │        │
   └──────┴───────┴──────────┼──────────┴───────────┴──────────┴────────┘
                             │
                        PostgreSQL
```

---

# 44. Guiding Principles

1. **PostgreSQL is the source of truth.** No external task system holds master data.
2. **FastAPI owns business logic.**
3. **Only the backend writes to PostgreSQL.** Reporting reads through a read-only role.
4. **Managers use a web app; workers use the Flutter app.**
5. **The worker app is offline-first.** A worker's actions are never lost because of the network.
6. **Time is stored as timestamps, never as counters.**
7. **GPS and device time are evidence, not proof.** The server validates them, flags anomalies, and a manager decides.
8. **Model the business: sites, projects, crews, assignments, quotes, materials. Don't model the screens.**
9. **The database enforces the invariants it can** (exclusion constraints, FKs, checks, idempotency keys).
10. **Start as a modular monolith; add complexity only when the business requires it.**
11. **All authorization decisions happen on the backend.**
12. **Every important state change is auditable.**
13. **Backups are tested by restoring them.**

---

# 45. Target Request Flow

```text
CLIENT
  │ submits form on nest_web
  ▼
NEST_WEB /api/contact (server)
  │ POST /public/assessment-requests  (service key)
  ▼
FASTAPI ──► PostgreSQL: request NEW ──► manager alert
  │
  ▼
MANAGER reviews → CONVERT
  │ company + contact + site (pin, radius) + project LEAD
  ▼
SURVEY job → visit → assignment → worker app: verify GPS → timer → photos → submit
  │ project SURVEY
  ▼
QUOTE v1 → PDF → SENT                      project QUOTED
  │
  ├── rejected/expired ──► project LOST
  ▼
ACCEPTED ──► project WON ──► INSTALLATION job
  │
  ▼
Visits Mon–Wed, crew assigned (no double-booking) ──► FCM push to each crew member
  │
  ▼
EACH WORKER (Flutter, offline-capable):
  verify GPS → work ⇄ break → finish → [lead: materials INSTALLED] → photos → submit
  │ outbox syncs → server validates GPS/time → flags → assignment SUBMITTED
  ▼
MANAGER reviews timesheets → approve        project INSTALLED
  │
  ▼
INSPECTION jobs (lead: checklist, DAMAGED/ADJUSTMENT)
  │
  ▼
DISMANTLING job: expected list from ledger → RETRIEVED / LOST
  │ project DISMANTLED → CLOSED
  ▼
METABASE: funnel, work hours, materials, losses
```

The MVP implements this operational flow first. Analytics beyond Metabase and the advanced automation come afterward.
