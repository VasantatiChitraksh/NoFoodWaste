from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# Schema for creating a hunger point
class HungerSpotCreate(BaseModel):
    name: str  # e.g., "Main Street Community Center"
    location: str  # could be address or coordinates
    validity: str  # e.g., "2 hours", or ISO datetime if preferred


# Schema for returning a hunger spot with document ID
class HungerSpotOut(HungerSpotCreate):
    id: str