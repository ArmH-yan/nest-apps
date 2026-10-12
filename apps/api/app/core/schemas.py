"""Shared Pydantic field types."""

from typing import Annotated

from pydantic import Field

# Light check only; deliverability is not validated (no extra dependency).
Email = Annotated[str, Field(max_length=254, pattern=r"^[^@\s]+@[^@\s]+\.[^@\s]+$")]
