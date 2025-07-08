"use client"

import * as React from "react"
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { cn } from "@/lib/utils"

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

interface Volunteer {
  id: number
  name: string
  points: number
  icon: string
}

interface LeaderboardProps {
  className?: string
}

export function VolunteerLeaderboard({ className }: LeaderboardProps) {
  const [volunteers, setVolunteers] = React.useState<Volunteer[]>([])
  const [loading, setLoading] = React.useState(true)

  React.useEffect(() => {
    const fetchVolunteerLeaderboard = async () => {
      try {
        const response = await fetch(`${API_BASE_URL}/dashboard/volunteer-leaderboard`)
        if (response.ok) {
          const data = await response.json()
          setVolunteers(data)
        }
      } catch (error) {
        console.error("Failed to fetch volunteer leaderboard:", error)
      } finally {
        setLoading(false)
      }
    }

    fetchVolunteerLeaderboard()
  }, [])

  return (
    <Card className={cn("flex flex-col", className)}>
      <CardHeader>
        <CardTitle>🏆 Volunteer Leaderboard</CardTitle>
      </CardHeader>
      <CardContent>
        {loading ? (
          <div className="flex items-center justify-center py-8">
            <p className="text-muted-foreground">Loading leaderboard...</p>
          </div>
        ) : volunteers.length === 0 ? (
          <div className="flex items-center justify-center py-8">
            <p className="text-muted-foreground">No volunteers found.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {volunteers.map((volunteer, index) => (
              <div key={volunteer.id} className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Avatar className="h-8 w-8">
                    <AvatarFallback>{volunteer.icon}</AvatarFallback>
                  </Avatar>
                  <span className="font-medium">{volunteer.name}</span>
                </div>
                <span className="text-sm text-muted-foreground">{volunteer.points} pts</span>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}