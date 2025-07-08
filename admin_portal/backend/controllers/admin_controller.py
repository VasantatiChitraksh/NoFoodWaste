import io
import string
import random
import pandas as pd
from fastapi import UploadFile, HTTPException
from fastapi.responses import JSONResponse
from backend.firebase import firebase_firestore, firebase_auth
from backend.utils.email_sender import send_email
import firebase_admin.auth as auth

def generate_random_password(length=10):
    chars = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(random.choices(chars, k=length))

async def import_volunteers_from_file(file: UploadFile):
    if not file.filename.endswith(('.xls', '.xlsx')):
        raise HTTPException(status_code=400, detail="Invalid file type")

    try:
        contents = await file.read()
        df = pd.read_excel(io.BytesIO(contents))

        required_columns = {"name", "email", "phone", "address"}
        if not required_columns.issubset(df.columns):
            return JSONResponse(
                status_code=400,
                content={"message": f"Missing required columns: {required_columns - set(df.columns)}"}
            )

        applications = df.to_dict(orient="records")
        collection_ref = firebase_firestore.collection("volunteer_applications")
        success_count = 0

        for entry in applications:
            doc_data = {
                "name": entry["name"],
                "email": entry["email"],
                "phone": str(entry["phone"]),
                "address": entry["address"],
                "status": "applied"
            }
            collection_ref.add(doc_data)
            success_count += 1

        return {"message": f"{success_count} applications imported successfully."}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process file: {str(e)}")


async def get_all_volunteer_applications():
    if True:
        docs = firebase_firestore.collection("volunteer_applications").order_by("time_imported", direction="DESCENDING").stream()

        results = []
        for doc in docs:
            data = doc.to_dict()
            results.append({
                "id": doc.id,
                "name": data.get("name"),
                "email": data.get("email"),
                "phone": data.get("phone"),
                "address": data.get("address"),
                "status": data.get("status", "applied"),
                "time_imported": data.get("time_imported")  # will be Firestore timestamp
            })

        return {"applications": results}
    try:
        pass
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching applications: {str(e)}")

async def send_training_invite_email(application_id: str):
    doc_ref = firebase_firestore.collection("volunteer_applications").document(application_id)
    doc = doc_ref.get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Application not found")

    data = doc.to_dict()
    email = data.get("email")
    name = data.get("name")

    if not email:
        raise HTTPException(status_code=400, detail="Email is missing in application data")

    # TODO: Customize this email body or template
    subject = "Volunteer Training Invitation"
    message = f"""
    Dear {name},

    You have been invited to attend a mandatory training session as part of the volunteer onboarding process.

    Please confirm your availability by replying to this email or attending on the scheduled date.

    Regards,
    No Food Waste Team
    """

    try:
        await send_email(to=email, subject=subject, body=message)
        doc_ref.update({"status": "training"})
        return {"message": f"Training invite sent to {email}."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send email: {str(e)}")


async def accept_volunteer_application(application_id: str):
    doc_ref = firebase_firestore.collection("volunteer_applications").document(application_id)
    doc = doc_ref.get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Application not found")

    data = doc.to_dict()
    name = data.get("name")
    email = data.get("email")

    if not name or not email:
        raise HTTPException(status_code=400, detail="Application missing name or email")

    # Step 1: Generate password
    password = generate_random_password()

    # Step 2: Send acceptance email (before creating account)
    subject = "Volunteer Application Accepted!"
    message = f"""
    Dear {name},

    🎉 Congratulations! You have successfully completed the volunteer training process and are now an official volunteer with No Food Waste.

    Your account has been created.

    👉 Login Email: {email}
    🔐 Temporary Password: {password}

    Please log in and change your password as soon as possible.

    Regards,  
    No Food Waste Team
    """

    try:
        pass #await send_email(to=email, subject=subject, body=message)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send acceptance email: {str(e)}")

    # Step 3: Create Firebase Auth user and Firestore entry
    try:
        try:
            user_record = firebase_auth.get_user_by_email(email)
            raise HTTPException(status_code=409, detail="Volunteer already exists.")
        except auth.UserNotFoundError:
            firebase_auth.create_user(email=email, password=password)

        firebase_firestore.collection("users").add({
            "name": name,
            "email": email,
            "role": "volunteer"
        })

        doc_ref.update({"status": "accepted"})

        return {"message": f"Volunteer accepted and account created for {email}"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create Firebase user or store in Firestore: {str(e)}")
    

async def add_admin_account(name: str, email: str):
    try:
        # 1. Generate password
        password = generate_random_password()

        # 2. Create Firebase Auth user
        try:
            user_record = firebase_auth.get_user_by_email(email)
            raise HTTPException(status_code=409, detail="Admin email already registered.")
        except auth.UserNotFoundError:
            user_record = firebase_auth.create_user(email=email, password=password)

        # 3. Add to Firestore
        user_doc = {
            "name": name,
            "email": email,
            "role": "admin"
        }
        firebase_firestore.collection("users").add(user_doc)

        # 4. Send Email with password
        subject = "Your Admin Account Has Been Created"
        body = f"""
        Hello {name},

        You have been added as an admin to the No Food Waste platform.

        Login Email: {email}
        Temporary Password: {password}

        Please log in and change your password.

        Regards,  
        No Food Waste Team
        """
        # await send_email(to=email, subject=subject, body=body)

        return {"message": f"Admin account created and credentials sent to {email}"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create admin: {str(e)}")
    

async def get_all_admins():
    try:
        query = firebase_firestore.collection("users").where("role", "==", "admin")
        docs = query.stream()

        admins = []
        for doc in docs:
            data = doc.to_dict()
            admins.append({
                "id": doc.id,
                "name": data.get("name"),
                "email": data.get("email"),
                "role": data.get("role"),
                "lastActivity": "Recently"  # Adding default lastActivity
            })

        return admins  # Return array directly, not wrapped in object

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch admins: {str(e)}")