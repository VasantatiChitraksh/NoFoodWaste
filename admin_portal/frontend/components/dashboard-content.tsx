"use client"

import * as React from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Users, Package, Truck, ClipboardList } from "lucide-react"
import { OverviewCard } from "@/components/overview-card"
import { VolunteerLeaderboard } from "@/components/volunteer-leaderboard"
import { Charts } from "@/components/charts"

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

interface DashboardStats {
  total_volunteers: number
  accepted_requests: number
  total_meals: number
  redistribution_rate: number
  total_requests: number
}

export function DashboardContent() {
  const [stats, setStats] = React.useState<DashboardStats | null>(null)
  const [loading, setLoading] = React.useState(true)

  React.useEffect(() => {
    const fetchDashboardStats = async () => {
      try {
        const response = await fetch(`${API_BASE_URL}/dashboard/stats`)
        if (response.ok) {
          const data = await response.json()
          setStats(data)
        }
      } catch (error) {
        console.error("Failed to fetch dashboard stats:", error)
      } finally {
        setLoading(false)
      }
    }

    fetchDashboardStats()
  }, [])

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <OverviewCard
        title="Total Meals"
        value={loading ? "Loading..." : `${stats?.total_meals?.toLocaleString() || 0} meals`}
        description="Total meals from all donations"
        icon={<Package className="size-4 text-muted-foreground" />}
      />
      <OverviewCard
        title="Active Volunteers"
        value={loading ? "Loading..." : `${stats?.total_volunteers?.toLocaleString() || 0}`}
        description="Registered volunteers"
        icon={<Users className="size-4 text-muted-foreground" />}
      />
      <OverviewCard
        title="Requests Fulfilled"
        value={loading ? "Loading..." : `${stats?.accepted_requests?.toLocaleString() || 0}`}
        description="Donation requests accepted"
        icon={<ClipboardList className="size-4 text-muted-foreground" />}
      />
      <OverviewCard
        title="Redistribution Success Rate"
        value={loading ? "Loading..." : `${stats?.redistribution_rate || 0}%`}
        description={stats ? `${stats.accepted_requests}/${stats.total_requests} requests accepted` : ""}
        icon={<Truck className="size-4 text-muted-foreground" />}
      />

      <div className="col-span-full grid gap-4 lg:grid-cols-7">
        <Card className="col-span-4">
          <CardHeader>
            <CardTitle>Redistribution Trends</CardTitle>
            <CardDescription>Overview of food redistribution over time.</CardDescription>
          </CardHeader>
          <CardContent className="pl-2">
            <Charts />
          </CardContent>
        </Card>
        <VolunteerLeaderboard className="col-span-3" />
      </div>
    </div>
  )
}
