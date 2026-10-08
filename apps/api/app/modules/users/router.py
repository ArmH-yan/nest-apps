from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.modules.auth.dependencies import PasswordChangeAuth
from app.modules.users.schemas import MeResponse
from app.modules.users.service import get_worker_for_user

router = APIRouter(tags=["users"])


@router.get("/me")
async def me(
    auth: PasswordChangeAuth, session: Annotated[AsyncSession, Depends(get_session)]
) -> MeResponse:
    """The signed-in user. Works while a password change is pending, so clients
    can show the change-password screen."""
    worker = await get_worker_for_user(session, auth.user.id)
    return MeResponse.build(auth.user, worker)
