import firebase_admin
from firebase_admin import credentials, firestore, auth

cred = credentials.Certificate("backend/cfg45-555a6-firebase-adminsdk-fbsvc-1145f61d33.json")

if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)


# Firestore client
firebase_db = firestore.client()

# Firebase auth and db available for use
firebase_auth = auth
firebase_firestore = firebase_db