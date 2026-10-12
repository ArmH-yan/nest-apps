"""Job, visit and assignment lifecycles (ARCHITECTURE §11). SYSTEM = automatic side
effect inside the same transaction as the change that caused it."""

from app.core.transitions import MANAGERS, SYSTEM, TransitionTable, allow
from app.modules.scheduling.models import AssignmentStatus as A
from app.modules.scheduling.models import JobStatus as J
from app.modules.scheduling.models import VisitStatus as V
from app.modules.users.models import UserRole

JOB_TRANSITIONS = TransitionTable[J](
    "job",
    [
        # a visit got its first crew member / lost its last one
        allow(J.DRAFT, J.SCHEDULED, SYSTEM),
        allow(J.SCHEDULED, J.DRAFT, SYSTEM),
        # the first assignment started work (synced from the app)
        allow(J.SCHEDULED, J.IN_PROGRESS, SYSTEM),
        # no PLANNED visits remain, or a manager closes it
        allow(J.IN_PROGRESS, J.COMPLETED, SYSTEM, *MANAGERS),
        allow(J.SCHEDULED, J.NO_ACCESS, *MANAGERS),
        allow(J.IN_PROGRESS, J.NO_ACCESS, *MANAGERS),
        allow(J.NO_ACCESS, J.SCHEDULED, *MANAGERS),  # rescheduled
        *(
            allow(s, J.CANCELLED, *MANAGERS)
            for s in (J.DRAFT, J.SCHEDULED, J.IN_PROGRESS, J.NO_ACCESS)
        ),
    ],
)

VISIT_TRANSITIONS = TransitionTable[V](
    "visit",
    [
        allow(V.PLANNED, V.DONE, SYSTEM),  # every active assignment SUBMITTED
        allow(V.PLANNED, V.CANCELLED, SYSTEM, *MANAGERS),
    ],
)

ASSIGNMENT_TRANSITIONS = TransitionTable[A](
    "assignment",
    [
        allow(A.ASSIGNED, A.IN_PROGRESS, UserRole.WORKER),  # first time entry
        allow(A.IN_PROGRESS, A.SUBMITTED, UserRole.WORKER),  # completion
        allow(A.ASSIGNED, A.CANCELLED, SYSTEM, *MANAGERS),
        allow(A.IN_PROGRESS, A.CANCELLED, SYSTEM, *MANAGERS),
        allow(A.CANCELLED, A.ASSIGNED, *MANAGERS),  # worker put back on the crew
    ],
)
