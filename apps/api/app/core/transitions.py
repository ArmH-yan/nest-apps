"""Lifecycle transition tables (CLAUDE.md: one table per lifecycle, with unit tests).

Each lifecycle is a single `TransitionTable` of `(from, to, allowed_roles, guard)`.
Services call `table.check(...)` before changing a status. `SYSTEM` stands for
automatic side effects (e.g. a job becoming SCHEDULED when a crew is assigned).
"""

from collections.abc import Callable, Iterable
from dataclasses import dataclass, field
from enum import StrEnum
from http import HTTPStatus
from typing import Any

from app.core.errors import AppError
from app.modules.users.models import UserRole

SYSTEM = "SYSTEM"

Actor = UserRole | str  # a UserRole or SYSTEM
# Returns None when allowed, otherwise an error code (e.g. "JOB_HAS_NO_CREW").
Guard = Callable[[Any], str | None]


@dataclass(frozen=True)
class Transition[S: StrEnum]:
    source: S
    target: S
    actors: frozenset[Actor]
    guard: Guard | None = None


def allow[S: StrEnum](
    source: S, target: S, *actors: Actor, guard: Guard | None = None
) -> Transition[S]:
    return Transition(source, target, frozenset(actors), guard)


MANAGERS: tuple[Actor, ...] = (UserRole.MANAGER, UserRole.ADMIN)


@dataclass
class TransitionTable[S: StrEnum]:
    name: str
    transitions: Iterable[Transition[S]]
    _index: dict[tuple[S, S], Transition[S]] = field(init=False)

    def __post_init__(self) -> None:
        self._index = {(t.source, t.target): t for t in self.transitions}

    def can(self, source: S, target: S, actor: Actor, context: Any = None) -> bool:
        try:
            self.check(source, target, actor, context)
        except AppError:
            return False
        return True

    def check(self, source: S, target: S, actor: Actor, context: Any = None) -> None:
        """Raises 409 INVALID_TRANSITION, 403 FORBIDDEN or 409 <guard code>."""
        transition = self._index.get((source, target))
        if transition is None:
            raise AppError(
                "INVALID_TRANSITION",
                f"A {self.name} cannot go from {source.value} to {target.value}.",
                status_code=HTTPStatus.CONFLICT,
                details={"entity": self.name, "from": source.value, "to": target.value},
            )
        if actor not in transition.actors:
            raise AppError(
                "FORBIDDEN",
                f"You cannot move a {self.name} to {target.value}.",
                status_code=HTTPStatus.FORBIDDEN,
            )
        if transition.guard is not None and (code := transition.guard(context)) is not None:
            raise AppError(
                code,
                f"The {self.name} cannot go to {target.value} yet.",
                status_code=HTTPStatus.CONFLICT,
                details={"entity": self.name, "from": source.value, "to": target.value},
            )
