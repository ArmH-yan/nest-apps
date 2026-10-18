# NEST Manager (apps/manager-web)

Next.js + TypeScript manager/admin app for the NEST operations platform.
See `../../ARCHITECTURE.md` (§13 Manager web app) and `../../CLAUDE.md`.

```bash
npm install
cp .env.example .env.local
npm run dev          # http://localhost:3001
npm run lint
npm run typecheck
npm run build
npm run gen:api      # regenerate src/lib/api/schema.d.ts from ../api/openapi.json (the committed contract)
```

API types are generated from FastAPI's OpenAPI schema — never hand-written.

Sign in with a manager account (demo data: `python -m app.cli seed-demo --reset` in apps/api,
then `+37491000001` / `nest1234`). The API must allow this origin: `CORS_ORIGINS=http://localhost:3001`.
