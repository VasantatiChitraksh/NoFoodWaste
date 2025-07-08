from backend.firebase import firebase_db
from typing import List
from backend.schemas.user_schema import UserCreate


def create_user(user: UserCreate):
    firebase_db.collection("users").add(user.dict())


def get_all_users_by_role(role: str) -> List[dict]:
    users_ref = firebase_db.collection("users").where("role", "==", role).stream()
    return [{**doc.to_dict(), "id": doc.id} for doc in users_ref]
