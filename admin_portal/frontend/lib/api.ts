const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

// Generic API function
async function apiRequest<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const url = `${API_BASE_URL}${endpoint}`
  
  const config: RequestInit = {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    ...options,
  }

  try {
    const response = await fetch(url, config)
    
    if (!response.ok) {
      throw new Error(`API Error: ${response.status} ${response.statusText}`)
    }
    
    return await response.json()
  } catch (error) {
    console.error('API Request failed:', error)
    throw error
  }
}

// Admin API functions
export const adminApi = {
  // Get all admins
  getAdmins: () => apiRequest<any[]>('/admin/get-admins'),
  
  // Add new admin
  addAdmin: (adminData: { name: string; email: string }) =>
    apiRequest('/admin/add-admin', {
      method: 'POST',
      body: JSON.stringify(adminData),
    }),
  
  // Get volunteer applications
  getVolunteerApplications: () =>
    apiRequest<any[]>('/admin/volunteer-applications'),
  
  // Send training invite
  sendTrainingInvite: (applicationId: string) =>
    apiRequest(`/admin/send-training-invite/${applicationId}`, {
      method: 'POST',
    }),
  
  // Accept volunteer
  acceptVolunteer: (applicationId: string) =>
    apiRequest(`/admin/accept-volunteer/${applicationId}`, {
      method: 'POST',
    }),
  
  // Import volunteers from file
  importVolunteers: (file: File) => {
    const formData = new FormData()
    formData.append('file', file)
    
    return apiRequest('/admin/import-volunteers', {
      method: 'POST',
      headers: {}, // Remove Content-Type to let browser set it for FormData
      body: formData,
    })
  },
}

// Dashboard API functions
export const dashboardApi = {
  // Get dashboard statistics
  getStats: () => apiRequest<any>('/dashboard/stats'),
  
  // Get all chart data
  getChartsData: () => apiRequest<any>('/dashboard/charts-data'),
  
  // Get individual chart data
  getMonthlyRequests: () => apiRequest<any[]>('/dashboard/monthly-requests'),
  getMonthlyMeals: () => apiRequest<any[]>('/dashboard/monthly-meals'),
  getTopDonors: () => apiRequest<any[]>('/dashboard/top-donors'),
  
  // Get volunteer leaderboard
  getVolunteerLeaderboard: () => apiRequest<any[]>('/dashboard/volunteer-leaderboard'),
  
  // Get recent activities
  getRecentActivities: () => apiRequest<any[]>('/dashboard/recent-activities'),
  
  // Get volunteer trends
  getVolunteerTrends: () => apiRequest<any>('/dashboard/volunteer-trends'),
}

export default apiRequest
