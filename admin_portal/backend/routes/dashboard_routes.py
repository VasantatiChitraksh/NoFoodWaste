from fastapi import APIRouter, HTTPException
from backend.controllers.dashboard_controller import (
    get_dashboard_stats,
    get_recent_activities,
    get_volunteer_application_trends,
    get_monthly_requests_data,
    get_monthly_meals_data,
    get_top_donors_data,
    get_all_charts_data,
    get_volunteer_leaderboard,
    debug_volunteer_data
)

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])

@router.get("/stats")
async def dashboard_stats():
    """Get overall dashboard statistics"""
    return await get_dashboard_stats()

@router.get("/recent-activities")
async def recent_activities():
    """Get recent activities for the dashboard"""
    return await get_recent_activities()

@router.get("/volunteer-trends")
async def volunteer_application_trends():
    """Get volunteer application trends data for charts"""
    return await get_volunteer_application_trends()

@router.get("/health")
async def dashboard_health():
    """Simple health check for dashboard services"""
    return {"status": "healthy", "message": "Dashboard API is running"}

@router.get("/charts-data")
async def all_charts_data():
    """Get all chart data (monthly requests, meals, and top donors)"""
    return await get_all_charts_data()

@router.get("/monthly-requests")
async def monthly_requests():
    """Get month-wise sum of accepted donation requests"""
    return await get_monthly_requests_data()

@router.get("/monthly-meals")
async def monthly_meals():
    """Get month-wise sum of meals from accepted donation requests"""
    return await get_monthly_meals_data()

@router.get("/top-donors")
async def top_donors():
    """Get top donors by total meals donated"""
    return await get_top_donors_data()

@router.get("/volunteer-leaderboard")
async def volunteer_leaderboard():
    """Get top volunteers by points from users collection"""
    return await get_volunteer_leaderboard()

@router.get("/debug-volunteers")
async def debug_volunteers():
    """Debug endpoint to check volunteer data structure"""
    return await debug_volunteer_data()
