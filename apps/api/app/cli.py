"""Admin command line (run from apps/api with the venv).

    python -m app.cli create-user --phone +37491000001 --first-name Arman \
        --last-name Harutyunyan --role ADMIN [--email a@nest.am]
    python -m app.cli create-user --phone +37491000007 --first-name Arman \
        --last-name Harutyunyan --role WORKER --employee-code NEST-007

The password is asked for interactively and never passed as an argument, so
it does not end up in shell history. Until the manager app exists (Phase 3),
this is how accounts are created. There is no self-registration (§7).

    python -m app.cli init-storage     # once per environment: creates the S3 bucket
    python -m app.cli export-openapi   # after API changes: updates apps/api/openapi.json
    python -m app.cli seed-demo [--reset]   # demo data (development only)
"""

import argparse
import asyncio
import getpass
import json
import sys
from pathlib import Path

from app.core.config import get_settings
from app.core.errors import AppError
from app.db.session import get_engine, get_sessionmaker
from app.modules.files.storage import S3Storage
from app.modules.users.models import UserLocale, UserRole
from app.modules.users.service import create_user

# The API contract (ARCHITECTURE §40), committed so the worker app's contract test
# and reviewers can see API changes. tests/test_openapi.py fails when it is stale.
OPENAPI_PATH = Path(__file__).resolve().parents[1] / "openapi.json"


def openapi_json() -> str:
    from app.main import create_app

    spec = create_app().openapi()
    return json.dumps(spec, indent=2, ensure_ascii=False, sort_keys=True) + "\n"


def _read_password() -> str:
    password = getpass.getpass("Password (min 8 characters): ")
    if len(password) < 8:
        sys.exit("Password is too short.")
    if getpass.getpass("Repeat password: ") != password:
        sys.exit("Passwords do not match.")
    return password


async def _create_user(args: argparse.Namespace, password: str) -> None:
    role = UserRole(args.role)
    try:
        async with get_sessionmaker()() as session:
            user = await create_user(
                session,
                phone=args.phone,
                password=password,
                first_name=args.first_name,
                last_name=args.last_name,
                role=role,
                email=args.email,
                locale=UserLocale(args.locale),
                # workers must replace the password their manager gave them (§7)
                must_change_password=role is UserRole.WORKER,
                employee_code=args.employee_code,
            )
            print(f"Created {user.role.value} #{user.id} {user.full_name} ({user.phone})")
    except AppError as exc:
        sys.exit(f"{exc.code}: {exc.message}")
    finally:
        await get_engine().dispose()


async def _seed(*, reset: bool) -> None:
    from app.seed import SeedRefused, seed_demo

    try:
        async with get_sessionmaker()() as session:
            for line in await seed_demo(session, reset=reset):
                print(line)
    except SeedRefused as exc:
        sys.exit(str(exc))
    finally:
        await get_engine().dispose()


def main() -> None:
    parser = argparse.ArgumentParser(prog="python -m app.cli")
    commands = parser.add_subparsers(dest="command", required=True)

    create = commands.add_parser("create-user", help="create an admin, manager or worker")
    create.add_argument("--phone", required=True)
    create.add_argument("--first-name", required=True)
    create.add_argument("--last-name", required=True)
    create.add_argument("--role", required=True, choices=[r.value for r in UserRole])
    create.add_argument("--email")
    create.add_argument(
        "--locale", default=UserLocale.HY.value, choices=[x.value for x in UserLocale]
    )
    create.add_argument("--employee-code", help="required for WORKER")

    commands.add_parser("init-storage", help="create the file storage bucket (S3_BUCKET)")
    seed = commands.add_parser("seed-demo", help="demo data for development (never production)")
    seed.add_argument("--reset", action="store_true", help="wipe ALL data first")
    commands.add_parser(
        "export-openapi", help=f"write the API contract to {OPENAPI_PATH.name} (§40)"
    )

    args = parser.parse_args()
    if args.command == "create-user":
        asyncio.run(_create_user(args, _read_password()))
    elif args.command == "init-storage":
        S3Storage().ensure_bucket()
        print(f"Bucket {get_settings().s3_bucket} is ready.")
    elif args.command == "seed-demo":
        asyncio.run(_seed(reset=args.reset))
    elif args.command == "export-openapi":
        OPENAPI_PATH.write_text(openapi_json(), encoding="utf-8")
        print(f"Wrote {OPENAPI_PATH}")


if __name__ == "__main__":
    main()
