# nest-apps

NEST operations platform: FastAPI backend, Next.js manager app, and the Flutter worker app (not scaffolded yet).

- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md)
- Worker app spec: [docs/WORKER_APP_SPEC.md](docs/WORKER_APP_SPEC.md)
- Setup and commands: [CLAUDE.md § Commands](CLAUDE.md#commands)

Quick start (Docker Desktop running):

```bash
cp .env.example .env
docker compose up -d db                                   # PostgreSQL on localhost:5433
cd apps/api && python -m venv .venv && .venv/Scripts/python -m pip install -e ".[dev]"
.venv/Scripts/alembic upgrade head
.venv/Scripts/uvicorn app.main:app --reload --port 8000   # http://localhost:8000/health
cd ../manager-web && npm install && npm run dev           # http://localhost:3001
```
