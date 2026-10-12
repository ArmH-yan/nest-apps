"""Project lifecycle (ARCHITECTURE §10).

LEAD → SURVEY → QUOTED ─┬─► LOST
                        ▼
                       WON → INSTALLED → DISMANTLED → CLOSED

SYSTEM transitions are side effects of jobs (Phase 2) and quotes (Phase 5).
Managers may also move a project by hand along the same edges, and may mark
it LOST or CLOSED early.
"""

from app.core.transitions import MANAGERS, SYSTEM, TransitionTable, allow
from app.modules.projects.models import ProjectStatus as P

PROJECT_TRANSITIONS = TransitionTable[P](
    "project",
    [
        allow(P.LEAD, P.SURVEY, SYSTEM, *MANAGERS),
        allow(P.LEAD, P.QUOTED, SYSTEM, *MANAGERS),  # quoted without a survey
        allow(P.SURVEY, P.QUOTED, SYSTEM, *MANAGERS),
        allow(P.QUOTED, P.WON, SYSTEM, *MANAGERS),
        allow(P.QUOTED, P.LOST, SYSTEM, *MANAGERS),
        allow(P.LEAD, P.LOST, *MANAGERS),
        allow(P.SURVEY, P.LOST, *MANAGERS),
        allow(P.LOST, P.LEAD, *MANAGERS),  # the client came back
        allow(P.WON, P.INSTALLED, SYSTEM, *MANAGERS),
        allow(P.INSTALLED, P.DISMANTLED, SYSTEM, *MANAGERS),
        allow(P.DISMANTLED, P.CLOSED, SYSTEM, *MANAGERS),
        allow(P.INSTALLED, P.CLOSED, *MANAGERS),  # nets left with the client
    ],
)
