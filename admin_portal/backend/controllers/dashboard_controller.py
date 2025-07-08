from fastapi import HTTPException
from backend.firebase import firebase_firestore
from datetime import datetime, timedelta

async def get_dashboard_stats():
    """Get overall dashboard statistics"""
    try:
        # Count volunteers
        volunteers_ref = firebase_firestore.collection("users").where("role", "==", "volunteer")
        volunteers = list(volunteers_ref.stream())
        total_volunteers = len(volunteers)
        
        # Get all donation requests for calculations
        all_requests_ref = firebase_firestore.collection("donation_requests")
        all_requests = list(all_requests_ref.stream())
        total_requests = len(all_requests)
        
        # Count accepted requests and sum meals
        accepted_requests = 0
        total_meals = 0
        
        for doc in all_requests:
            data = doc.to_dict()
            if data.get("accept") == True:
                accepted_requests += 1
            
            meals = data.get("meals", 0)
            if isinstance(meals, (int, float)):
                total_meals += meals
        
        # Calculate redistribution rate
        redistribution_rate = round((accepted_requests / total_requests) * 100, 2) if total_requests > 0 else 0
        
        # Count volunteer applications
        applications_ref = firebase_firestore.collection("volunteer_applications")
        applications = list(applications_ref.stream())
        total_applications = len(applications)
        
        # Count pending applications
        pending_apps = [app for app in applications if app.to_dict().get("status") == "applied"]
        pending_applications = len(pending_apps)
        
        # Count total admins
        admins_ref = firebase_firestore.collection("users").where("role", "==", "admin")
        admins = list(admins_ref.stream())
        total_admins = len(admins)
        
        stats = {
            "total_volunteers": total_volunteers,
            "accepted_requests": accepted_requests,
            "total_meals": total_meals,
            "redistribution_rate": redistribution_rate,
            "total_requests": total_requests,
            "total_applications": total_applications,
            "pending_applications": pending_applications,
            "total_admins": total_admins
        }
        
        return stats
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch dashboard stats: {str(e)}")

async def get_recent_activities():
    """Get recent activities for the dashboard"""
    try:
        # Placeholder for recent activities
        activities = [
            {
                "id": "1",
                "type": "volunteer_application",
                "description": "New volunteer application received",
                "timestamp": datetime.now().isoformat(),
                "user": "John Doe"
            },
            {
                "id": "2", 
                "type": "admin_added",
                "description": "New admin account created",
                "timestamp": (datetime.now() - timedelta(hours=2)).isoformat(),
                "user": "Jane Smith"
            }
        ]
        
        return activities
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch recent activities: {str(e)}")

async def get_volunteer_application_trends():
    """Get volunteer application trends data"""
    try:
        # Placeholder for trends data
        trends = {
            "labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
            "data": [12, 19, 3, 5, 2, 3, 7]
        }
        
        return trends
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch application trends: {str(e)}")

async def get_monthly_requests_data():
    """Get month-wise sum of accepted donation requests for last 6 months"""
    try:
        # Get all accepted donation requests
        requests_ref = firebase_firestore.collection("donation_requests").where("accept", "==", True)
        requests = requests_ref.stream()
        
        # Get last 6 months
        from datetime import datetime, timedelta
        import calendar
        
        today = datetime.now()
        last_6_months = []
        for i in range(6):
            month_date = today - timedelta(days=30*i)
            month_name = calendar.month_abbr[month_date.month]
            last_6_months.append((month_name, month_date.month, month_date.year))
        
        last_6_months.reverse()  # Chronological order
        
        # Dictionary to store monthly data
        monthly_data = {month[0]: 0 for month in last_6_months}
        
        for doc in requests:
            data = doc.to_dict()
            cooked_time = data.get("cookedTime")
            
            if cooked_time:
                # Extract month from timestamp
                month = cooked_time.strftime("%b")  # Jan, Feb, etc.
                request_year = cooked_time.year
                request_month = cooked_time.month
                
                # Check if this request is from the last 6 months
                for month_name, m, y in last_6_months:
                    if month_name == month and request_year == y and request_month == m:
                        monthly_data[month] += 1
                        break
        
        # Convert to chart format
        chart_data = [{"month": month, "requests": monthly_data[month]} for month, _, _ in last_6_months]
        
        return chart_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch monthly requests data: {str(e)}")

async def get_monthly_meals_data():
    """Get month-wise sum of meals from accepted donation requests for last 6 months"""
    try:
        # Get all accepted donation requests
        requests_ref = firebase_firestore.collection("donation_requests").where("accept", "==", True)
        requests = requests_ref.stream()
        
        # Get last 6 months
        from datetime import datetime, timedelta
        import calendar
        
        today = datetime.now()
        last_6_months = []
        for i in range(6):
            month_date = today - timedelta(days=30*i)
            month_name = calendar.month_abbr[month_date.month]
            last_6_months.append((month_name, month_date.month, month_date.year))
        
        last_6_months.reverse()  # Chronological order
        
        # Dictionary to store monthly meals data
        monthly_meals = {month[0]: 0 for month in last_6_months}
        
        for doc in requests:
            data = doc.to_dict()
            cooked_time = data.get("cookedTime")
            meals = data.get("meals", 0)
            
            if cooked_time and isinstance(meals, (int, float)):
                # Extract month from timestamp
                month = cooked_time.strftime("%b")  # Jan, Feb, etc.
                request_year = cooked_time.year
                request_month = cooked_time.month
                
                # Check if this request is from the last 6 months
                for month_name, m, y in last_6_months:
                    if month_name == month and request_year == y and request_month == m:
                        monthly_meals[month] += meals
                        break
        
        # Convert to chart format
        chart_data = [{"month": month, "meals": monthly_meals[month]} for month, _, _ in last_6_months]
        
        return chart_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch monthly meals data: {str(e)}")

async def get_top_donors_data():
    """Get top donors by total meals from users collection"""
    try:
        # Get all users with role "donor"
        donors_ref = firebase_firestore.collection("users").where("role", "==", "donor")
        donors = list(donors_ref.stream())
        
        # Extract donor data with meals
        donor_data = []
        
        for donor_doc in donors:
            data = donor_doc.to_dict()
            name = data.get("name", "Unknown Donor")
            meals = data.get("meals", 0)
            
            # Only include donors who have meals
            if isinstance(meals, (int, float)):
                donor_data.append({
                    "donor": name,
                    "donations": meals
                })
        
        # Sort by meals (donations) in descending order and get top 8
        sorted_donors = sorted(donor_data, key=lambda x: x["donations"], reverse=True)[:8]
        
        return sorted_donors
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch top donors data: {str(e)}")

async def get_volunteer_leaderboard():
    """Get top volunteers by points from users collection"""
    try:
        # Get all users with role "volunteer"
        volunteers_ref = firebase_firestore.collection("users").where("role", "==", "volunteer")
        volunteers = list(volunteers_ref.stream())
        
        # Extract volunteer data with points
        volunteer_data = []
        
        for volunteer_doc in volunteers:
            data = volunteer_doc.to_dict()
            name = data.get("name", "Unknown Volunteer")
            points = data.get("volunteers", 0)  # Using "volunteers" field as points
            
            # Include all volunteers, even those with 0 points
            if isinstance(points, (int, float)):
                volunteer_data.append({
                    "name": name,
                    "points": points
                })
            else:
                # If volunteers field is not a number, default to 0 points
                volunteer_data.append({
                    "name": name,
                    "points": 0
                })
        
        # Sort by points in descending order and get top 9
        sorted_volunteers = sorted(volunteer_data, key=lambda x: x["points"], reverse=True)[:9]
        
        # Add icons based on ranking
        icons = ["🏅", "🥈", "🥉", "👍", "👏", "🌟", "💪", "🎉", "🤝"]
        
        leaderboard = []
        for i, volunteer in enumerate(sorted_volunteers):
            leaderboard.append({
                "id": i + 1,
                "name": volunteer["name"],
                "points": volunteer["points"],
                "icon": icons[i] if i < len(icons) else "⭐"
            })
        
        return leaderboard
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch volunteer leaderboard: {str(e)}")

async def get_all_charts_data():
    """Get all chart data in one response"""
    try:
        monthly_requests = await get_monthly_requests_data()
        monthly_meals = await get_monthly_meals_data()
        top_donors = await get_top_donors_data()
        
        return {
            "monthly_requests": monthly_requests,
            "monthly_meals": monthly_meals,
            "top_donors": top_donors
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch charts data: {str(e)}")

async def debug_volunteer_data():
    """Debug function to check volunteer data structure"""
    try:
        # Get all users with role "volunteer"
        volunteers_ref = firebase_firestore.collection("users").where("role", "==", "volunteer")
        volunteers = list(volunteers_ref.stream())
        
        debug_data = []
        for volunteer_doc in volunteers:
            data = volunteer_doc.to_dict()
            debug_data.append({
                "id": volunteer_doc.id,
                "name": data.get("name", "Unknown"),
                "role": data.get("role", "Unknown"),
                "volunteers_field": data.get("volunteers", "Not found"),
                "all_fields": list(data.keys())
            })
        
        return {
            "total_volunteers_found": len(volunteers),
            "volunteer_details": debug_data
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to debug volunteer data: {str(e)}")
