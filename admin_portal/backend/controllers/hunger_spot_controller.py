from backend.firebase import firebase_firestore
from backend.schemas.hunger_spot_schema import HungerSpotCreate
from typing import List, Optional


# Create a new hunger spot
def create_hunger_spot(spot: HungerSpotCreate):
    """
    Adds a hunger spot to the 'hunger_spots' collection.
    """
    firebase_firestore.collection("hunger_spots").add(spot.dict())


# Get all hunger spots
def get_all_hunger_spots() -> List[dict]:
    """
    Fetches all hunger spot documents from Firestore.
    """
    docs = firebase_firestore.collection("hunger_spots").stream()
    return [{**doc.to_dict(), "id": doc.id} for doc in docs]
