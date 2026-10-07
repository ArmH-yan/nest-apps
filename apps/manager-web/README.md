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
npm run gen:api      # regenerate src/lib/api/schema.d.ts from the running API (localhost:8000)
```

API types are generated from FastAPI's OpenAPI schema — never hand-written.
