"""Assessment request lifecycle (ARCHITECTURE §9).

NEW ──► IN_REVIEW ──► CONVERTED   (creates/links company, contact, site, project)
 │          │
 └──────────┴──► REJECTED | SPAM   (both can be reopened to IN_REVIEW)

A request is an intake record: it is never scheduled or completed itself.
Only managers move it; conversion is final.
"""

from app.core.transitions import MANAGERS, TransitionTable, allow
from app.modules.requests.models import RequestStatus as R

REQUEST_TRANSITIONS = TransitionTable[R](
    "assessment request",
    [
        allow(R.NEW, R.IN_REVIEW, *MANAGERS),
        allow(R.NEW, R.CONVERTED, *MANAGERS),
        allow(R.IN_REVIEW, R.CONVERTED, *MANAGERS),
        allow(R.NEW, R.REJECTED, *MANAGERS),
        allow(R.IN_REVIEW, R.REJECTED, *MANAGERS),
        allow(R.NEW, R.SPAM, *MANAGERS),
        allow(R.IN_REVIEW, R.SPAM, *MANAGERS),
        allow(R.REJECTED, R.IN_REVIEW, *MANAGERS),  # rejected by mistake
        allow(R.SPAM, R.IN_REVIEW, *MANAGERS),
    ],
)
