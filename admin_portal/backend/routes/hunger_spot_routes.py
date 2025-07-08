from fastapi import APIRouter, HTTPException
from typing import List
from backend.schemas.hunger_spot_schema import HungerSpotCreate, HungerSpotOut
from backend.controllers import hunger_spot_controller

router = APIRouter(prefix="/hunger-spots", tags=["Hunger Spots"])


# POST /hunger-spots/ → Create a hunger spot
@router.post("/", response_model=dict)
def create_hunger_spot(spot: HungerSpotCreate):
    hunger_spot_controller.create_hunger_spot(spot)
    return {"message": "Hunger spot created successfully"}


# GET /hunger-spots/ → Get all hunger spots
@router.get("/", response_model=List[HungerSpotOut])
def get_all_hunger_spots():
    return hunger_spot_controller.get_all_hunger_spots()
