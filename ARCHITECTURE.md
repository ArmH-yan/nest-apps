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
| Background tasks | Postgres-backed queue (e.g. `procrastinate`) | Push, reminders, PDF generation |
| File storage | S3-compatible (Cloudflare R2 / Hetzner Object Storage; MinIO locally) | Photos, quote PDFs |
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
- Phase 1 uses Bearer tokens only. The manager app's HttpOnly-cookie + CSRF variant is added with the manager login (Phase 3), as is removing FCM device tokens on logout.
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
locale           hy | ru | en
telegram_chat_id nullable (managers, optional)
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
```

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
period           tstzrange
reason           VACATION | SICK | OTHER
note
created_by
```

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
latitude
longitude
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
reference
site_id
company_id
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

When this constraint is violated, the API returns `409 WORKER_ALREADY_BOOKED`.

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
server_verified     boolean
```

### assignment_completions

```text
id               uuid (client-generated)
assignment_id    unique
completed_at     device timestamp
completion_location_check_id
reported_work_seconds
reported_break_seconds
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

## Main navigation

```text
Dashboard
Requests
Projects
Calendar
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

---

# 14. Scheduling

The manager must be able to:

- create one or more visits for a job (date, start, end)
- assign a crew (one LEAD + members) to each visit; each member gets their own task in the app, with its own fixed `pay_amount` (§8)
- copy a crew/time across consecutive days (multi-day installations)
- reschedule or cancel visits (the affected workers get a push)
- see worker availability (existing assignments + time off)

Calendar views:

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
GET  /api/v1/worker/config                       # geofence default, accuracy limit, min photos, start window
GET  /api/v1/worker/tasks?from=&to=              # assignments + visit + job + site (lat/lng, radius) + crew
GET  /api/v1/worker/tasks/{assignment_id}
GET  /api/v1/worker/tasks/{assignment_id}/expected-materials   # dismantling list

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
```

### Timesheets

```text
GET    /timesheets?from=&to=&worker_id=&flagged=
GET    /timesheets/assignments/{id}
POST   /timesheets/assignments/{id}/approve
POST   /timesheets/assignments/{id}/adjust
POST   /location-checks/{id}/override
GET    /timesheets/export.csv?from=&to=
```

### Workers

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

PostgreSQL stores **metadata only**. The file bytes go to S3-compatible object storage (MinIO locally).

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

Notification text uses the recipient's locale (hy/ru/en).

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
MinIO            localhost:9000   added to docker compose when file uploads are built
Metabase         localhost:3030   added to docker compose when reporting is built (optional profile)
```

Development decisions (accepted 2026-10-07):

- Docker Compose runs **only PostgreSQL** for now. The API runs directly from the local Python virtual environment (`apps/api/.venv`); an API container is added with the production deployment work.
- PostgreSQL version: **17**.
- The manager web app has **no Tailwind** for now; a styling approach is chosen when manager UI work starts.

- **Worker app**: `flutter run --flavor dev` runs against mock repositories (`USE_MOCKS` defaults to `true`). Against the local API: `flutter run --flavor dev --dart-define=USE_MOCKS=false --dart-define=API_BASE_URL=http://10.0.2.2:8000` (Android emulator → host).
- **Public website**: runs from its own repo (`F:\nest_web`, `npm run dev` → `localhost:3000`). Point `CONTACT_API_URL` at `http://localhost:8000/api/v1/public/assessment-requests`.
- **Seed data**: a script creates a few sites in Yerevan with pins, workers, and today's visits, so the app's GPS flow can be tested with emulator mock locations.

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

Use a **Postgres-backed task queue** (e.g. `procrastinate`) running as a separate process from the same codebase. This avoids Redis.

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

```text
Companies, contacts, sites (pin + radius), projects, jobs, visits, crew assignment, constraints
/worker/* API: tasks, location checks, time entries, files, completion (idempotent)
Flutter: Api* repositories + outbox/SyncService; switch off mocks
Seed script; first real field test with 1–2 workers
```

## Phase 3 — Manager web app

```text
Login, dashboard, calendar, jobs/visits, crews, workers + time off
Timesheets review (map, flags, approve/adjust, CSV export)
FCM push + reminders
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
- Projects; jobs with visits; crew assignment; calendar
- Worker management + time off + password reset
- Timesheets review
- Quotes with PDF
- Materials on site

### Worker app (Flutter, Android first)

- Login (phone + password), session kept in secure storage
- Tasks (today / upcoming), task details with map and navigate link
- GPS verification against the site geofence
- Work / break timers (timestamp-based, multiple cycles)
- Finish: materials (lead), photos (≥1), comment, confirm, submit
- Offline-first with outbox sync and clear sync states
- History, profile (language hy/ru/en, permissions, logout)
- Push + in-app notifications

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
- AI features
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
