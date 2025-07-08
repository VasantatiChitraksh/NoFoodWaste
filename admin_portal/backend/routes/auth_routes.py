# backend/routes/auth_routes.py

from fastapi import APIRouter, HTTPException
from typing import List
from backend.controllers import auth_controller
from backend.schemas.user_schema import UserCreate

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/users")
def create_user_endpoint(user: UserCreate):
    try:
        auth_controller.create_user(user)
        return {"message": "User created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/users/{role}", response_model=List[dict])
def get_users_by_role(role: str):
    try:
        return auth_controller.get_all_users_by_role(role)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
