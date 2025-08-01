from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.routes import admin_routes, auth_routes, hunger_spot_routes, dashboard_routes

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_routes.router)
app.include_router(hunger_spot_routes.router)
app.include_router(admin_routes.router)
app.include_router(dashboard_routes.router)

@app.get("/")
def root():
    return {"message": "Admin Portal Backend Running"}
