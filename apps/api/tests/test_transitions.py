"""Every lifecycle transition table: allowed edges pass, everything else is rejected
(CLAUDE.md: one transition table per lifecycle, with unit tests)."""

from enum import StrEnum
from itertools import product
from typing import Any

import pytest

from app.core.errors import AppError
from app.core.transitions import SYSTEM, Actor, TransitionTable
from app.modules.projects.models import ProjectStatus as P
from app.modules.projects.transitions import PROJECT_TRANSITIONS
from app.modules.scheduling.models import AssignmentStatus as A
from app.modules.scheduling.models import JobStatus as J
from app.modules.scheduling.models import VisitStatus as V
from app.modules.scheduling.transitions import (
    ASSIGNMENT_TRANSITIONS,
    JOB_TRANSITIONS,
    VISIT_TRANSITIONS,
)
from app.modules.users.models import UserRole

M, ADMIN, W = UserRole.MANAGER, UserRole.ADMIN, UserRole.WORKER

# The expected tables, written out independently of the implementation.
EXPECTED: dict[
    str, tuple[TransitionTable[Any], type[StrEnum], set[tuple[StrEnum, StrEnum, Actor]]]
] = {
    "job": (
        JOB_TRANSITIONS,
        J,
        {
            (J.DRAFT, J.SCHEDULED, SYSTEM),
            (J.SCHEDULED, J.DRAFT, SYSTEM),
            (J.SCHEDULED, J.IN_PROGRESS, SYSTEM),
            (J.IN_PROGRESS, J.COMPLETED, SYSTEM),
            (J.IN_PROGRESS, J.COMPLETED, M),
            (J.IN_PROGRESS, J.COMPLETED, ADMIN),
            *((s, J.NO_ACCESS, r) for s in (J.SCHEDULED, J.IN_PROGRESS) for r in (M, ADMIN)),
            (J.NO_ACCESS, J.SCHEDULED, M),
            (J.NO_ACCESS, J.SCHEDULED, ADMIN),
            *(
                (s, J.CANCELLED, r)
                for s in (J.DRAFT, J.SCHEDULED, J.IN_PROGRESS, J.NO_ACCESS)
                for r in (M, ADMIN)
            ),
        },
    ),
    "visit": (
        VISIT_TRANSITIONS,
        V,
        {
            (V.PLANNED, V.DONE, SYSTEM),
            (V.PLANNED, V.CANCELLED, SYSTEM),
            (V.PLANNED, V.CANCELLED, M),
            (V.PLANNED, V.CANCELLED, ADMIN),
        },
    ),
    "assignment": (
        ASSIGNMENT_TRANSITIONS,
        A,
        {
            (A.ASSIGNED, A.IN_PROGRESS, W),
            (A.IN_PROGRESS, A.SUBMITTED, W),
            *((s, A.CANCELLED, r) for s in (A.ASSIGNED, A.IN_PROGRESS) for r in (SYSTEM, M, ADMIN)),
            (A.CANCELLED, A.ASSIGNED, M),
            (A.CANCELLED, A.ASSIGNED, ADMIN),
        },
    ),
    "project": (
        PROJECT_TRANSITIONS,
        P,
        {
            *(
                (s, t, r)
                for s, t in [
                    (P.LEAD, P.SURVEY),
                    (P.LEAD, P.QUOTED),
                    (P.SURVEY, P.QUOTED),
                    (P.QUOTED, P.WON),
                    (P.QUOTED, P.LOST),
                    (P.WON, P.INSTALLED),
                    (P.INSTALLED, P.DISMANTLED),
                    (P.DISMANTLED, P.CLOSED),
                ]
                for r in (SYSTEM, M, ADMIN)
            ),
            *(
                (s, t, r)
                for s, t in [
                    (P.LEAD, P.LOST),
                    (P.SURVEY, P.LOST),
                    (P.LOST, P.LEAD),
                    (P.INSTALLED, P.CLOSED),
                ]
                for r in (M, ADMIN)
            ),
        },
    ),
}

ACTORS: list[Actor] = [SYSTEM, M, ADMIN, W]


@pytest.mark.parametrize("name", EXPECTED)
def test_transition_table_is_exactly_as_specified(name: str) -> None:
    table, states, allowed = EXPECTED[name]
    for source, target, actor in product(states, states, ACTORS):
        expected = (source, target, actor) in allowed
        assert table.can(source, target, actor) is expected, (name, source, target, actor)


def test_rejections_use_stable_codes() -> None:
    with pytest.raises(AppError) as invalid:
        JOB_TRANSITIONS.check(J.COMPLETED, J.DRAFT, M)
    assert invalid.value.code == "INVALID_TRANSITION"
    assert invalid.value.status_code == 409

    with pytest.raises(AppError) as forbidden:
        ASSIGNMENT_TRANSITIONS.check(A.ASSIGNED, A.IN_PROGRESS, M)
    assert forbidden.value.code == "FORBIDDEN"
    assert forbidden.value.status_code == 403
