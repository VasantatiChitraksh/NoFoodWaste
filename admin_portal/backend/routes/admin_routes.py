from fastapi import APIRouter, File, UploadFile, HTTPException
from backend.controllers.admin_controller import import_volunteers_from_file, get_all_volunteer_applications, send_training_invite_email, accept_volunteer_application, add_admin_account, get_all_admins
from backend.firebase import firebase_firestore
from backend.utils.email_sender import send_email
from pydantic import BaseModel, EmailStr

router = APIRouter(prefix="/admin", tags=["Admin"])

@router.post("/import-volunteers")
async def import_volunteers(
    file: UploadFile = File(...)
):
    result = await import_volunteers_from_file(file)
    return result

@router.get("/volunteer-applications")
async def list_volunteer_applications():

    return await get_all_volunteer_applications()

@router.post("/send-training-invite/{application_id}")
async def send_training_invite(application_id: str):
    # Send the email only
    # email_result = await send_training_invite_email(application_id)

    # ✅ Update status to "training" after successful email
    doc_ref = firebase_firestore.collection("volunteer_applications").document(application_id)
    doc = doc_ref.get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Application not found")

    try:
        doc_ref.update({"status": "training"})
        return {
            "message": "Training invite sent successfully",
            "status": "Application marked as 'training'"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Email sent but failed to update status: {str(e)}")
    

@router.post("/accept-volunteer/{application_id}")
async def accept_volunteer(application_id: str):
    return await accept_volunteer_application(application_id)

class NewAdminRequest(BaseModel):
    name: str
    email: EmailStr


@router.post("/add-admin")
async def add_admin(request: NewAdminRequest):
    return await add_admin_account(request.name, request.email)

@router.get("/get-admins")
async def list_admins():

    return await get_all_admins()
