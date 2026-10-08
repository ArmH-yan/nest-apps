"""Admin command line (run from apps/api with the venv).

    python -m app.cli create-user --phone +37491000001 --first-name Arman \
        --last-name Harutyunyan --role ADMIN [--email a@nest.am]
    python -m app.cli create-user --phone +37491000007 --first-name Arman \
        --last-name Harutyunyan --role WORKER --employee-code NEST-007

The password is asked for interactively and never passed as an argument, so
it does not end up in shell history. Until the manager app exists (Phase 3),
this is how accounts are created. There is no self-registration (§7).
"""

import argparse
import asyncio
import getpass
import sys

from app.core.errors import AppError
from app.db.session import get_engine, get_sessionmaker
from app.modules.users.models import UserLocale, UserRole
from app.modules.users.service import create_user


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

    args = parser.parse_args()
    if args.command == "create-user":
        asyncio.run(_create_user(args, _read_password()))


if __name__ == "__main__":
    main()
