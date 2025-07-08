from pydantic import BaseModel, EmailStr
from typing import Optional, Literal


# Shared base for all user types
class UserBase(BaseModel):
    name: str
    email: EmailStr
    role: Literal["admin", "volunteer"]  # restrict to valid roles


# Schema for creating any user (admin or volunteer)
class UserCreate(UserBase):
    pass


# Schema for returning a user with ID
class UserOut(UserBase):
    id: str


# Optional update schema
class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    role: Optional[Literal["admin", "volunteer"]] = None
