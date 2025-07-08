import type * as React from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { cn } from "@/lib/utils"

interface RecentActivityProps extends React.ComponentProps<typeof Card> {}

export function RecentActivity({ className, ...props }: RecentActivityProps) {
  const activities = [
    {
      id: 1,
      type: "donation",
      description: "New food donation from 'Green Grocers'",
      time: "2 hours ago",
      icon: "📦",
    },
    {
      id: 2,
      type: "volunteer",
      description: "Volunteer 'Alice Johnson' completed training",
      time: "5 hours ago",
      icon: "👩‍🏫",
    },
    {
      id: 3,
      type: "request",
      description: "Food request #1234 accepted by 'John Doe'",
      time: "1 day ago",
      icon: "✅",
    },
    {
      id: 4,
      type: "vehicle",
      description: "Vehicle 'Truck 001' returned to base",
      time: "2 days ago",
      icon: "🚚",
    },
    {
      id: 5,
      type: "admin",
      description: "Admin 'Jane Smith' updated user roles",
      time: "3 days ago",
      icon: "⚙️",
    },
    {
      id: 6,
      type: "donation",
      description: "Food donation from 'City Bakery' redistributed",
      time: "4 days ago",
      icon: "♻️",
    },
    {
      id: 7,
      type: "volunteer",
      description: "New volunteer 'Bob Williams' joined",
      time: "5 days ago",
      icon: "🙋‍♂️",
    },
    {
      id: 8,
      type: "request",
      description: "Food request #1235 pending approval",
      time: "6 days ago",
      icon: "⏳",
    },
  ]

  return (
    <Card className={cn("flex flex-col", className)} {...props}>
      <CardHeader>
        <CardTitle>Recent Activity</CardTitle>
        <CardDescription>Latest updates from the dashboard.</CardDescription>
      </CardHeader>
      <CardContent className="flex-1">
        <ScrollArea className="h-[300px] pr-4">
          <div className="space-y-4">
            {activities.map((activity) => (
              <div key={activity.id} className="flex items-center gap-4">
                <Avatar className="hidden h-9 w-9 sm:flex">
                  <AvatarFallback>{activity.icon}</AvatarFallback>
                </Avatar>
                <div className="grid gap-1">
                  <p className="text-sm font-medium leading-none">{activity.description}</p>
                  <p className="text-sm text-muted-foreground">{activity.time}</p>
                </div>
              </div>
            ))}
          </div>
        </ScrollArea>
      </CardContent>
    </Card>
  )
}
