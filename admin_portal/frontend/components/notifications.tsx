"use client"

import * as React from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Check, BellRing, Package, Users, ClipboardList } from "lucide-react"
import { cn } from "@/lib/utils"

interface Notification {
  id: string
  message: string
  category: "Donation" | "Volunteer" | "Request" | "System"
  timestamp: string
  read: boolean
}

const initialNotifications: Notification[] = [
  {
    id: "n001",
    message: "New large donation received from 'Fresh Foods Inc.'",
    category: "Donation",
    timestamp: "2 minutes ago",
    read: false,
  },
  {
    id: "n002",
    message: "Volunteer 'Sarah Lee' has completed her onboarding.",
    category: "Volunteer",
    timestamp: "15 minutes ago",
    read: false,
  },
  {
    id: "n003",
    message: "Food request #2023-005 is awaiting approval.",
    category: "Request",
    timestamp: "30 minutes ago",
    read: false,
  },
  {
    id: "n004",
    message: "System update: Dashboard performance improved.",
    category: "System",
    timestamp: "1 hour ago",
    read: true,
  },
  {
    id: "n005",
    message: "Urgent: Perishable donation from 'Bakery Delights' needs pickup.",
    category: "Donation",
    timestamp: "2 hours ago",
    read: false,
  },
  {
    id: "n006",
    message: "Volunteer 'David Kim' is available for new assignments.",
    category: "Volunteer",
    timestamp: "4 hours ago",
    read: true,
  },
  {
    id: "n007",
    message: "Request #2023-004 has been successfully fulfilled.",
    category: "Request",
    timestamp: "1 day ago",
    read: true,
  },
]

export function Notifications() {
  const [notifications, setNotifications] = React.useState<Notification[]>(initialNotifications)
  const [filterCategory, setFilterCategory] = React.useState<string>("all")

  const markAsRead = (id: string) => {
    setNotifications((prev) => prev.map((n) => (n.id === id ? { ...n, read: true } : n)))
  }

  const filteredNotifications = notifications.filter((notification) => {
    const matchesCategory = filterCategory === "all" || notification.category === filterCategory
    return matchesCategory
  })

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case "Donation":
        return <Package className="size-4" />
      case "Volunteer":
        return <Users className="size-4" />
      case "Request":
        return <ClipboardList className="size-4" />
      case "System":
        return <BellRing className="size-4" />
      default:
        return null
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Notifications</CardTitle>
        <CardDescription>Real-time alerts and updates.</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="flex flex-wrap gap-2 mb-4">
          <Button
            variant={filterCategory === "all" ? "default" : "outline"}
            onClick={() => setFilterCategory("all")}
            size="sm"
          >
            All
          </Button>
          <Button
            variant={filterCategory === "Donation" ? "default" : "outline"}
            onClick={() => setFilterCategory("Donation")}
            size="sm"
          >
            Donations
          </Button>
          <Button
            variant={filterCategory === "Volunteer" ? "default" : "outline"}
            onClick={() => setFilterCategory("Volunteer")}
            size="sm"
          >
            Volunteers
          </Button>
          <Button
            variant={filterCategory === "Request" ? "default" : "outline"}
            onClick={() => setFilterCategory("Request")}
            size="sm"
          >
            Requests
          </Button>
          <Button
            variant={filterCategory === "System" ? "default" : "outline"}
            onClick={() => setFilterCategory("System")}
            size="sm"
          >
            System
          </Button>
        </div>
        <ScrollArea className="h-[400px] pr-4">
          <div className="space-y-4">
            {filteredNotifications.length === 0 ? (
              <div className="text-center text-muted-foreground py-8">No notifications found.</div>
            ) : (
              filteredNotifications.map((notification) => (
                <div
                  key={notification.id}
                  className={cn(
                    "flex items-start gap-4 p-3 rounded-md",
                    !notification.read
                      ? "bg-blue-50/50 dark:bg-blue-950/20 border border-blue-100 dark:border-blue-900"
                      : "bg-muted/20",
                  )}
                >
                  <div className="flex-shrink-0 mt-1 text-muted-foreground">
                    {getCategoryIcon(notification.category)}
                  </div>
                  <div className="flex-1 grid gap-1">
                    <p className={cn("text-sm", !notification.read && "font-medium")}>{notification.message}</p>
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                      <Badge variant="outline" className="px-2 py-0.5">
                        {notification.category}
                      </Badge>
                      <span>{notification.timestamp}</span>
                    </div>
                  </div>
                  {!notification.read && (
                    <Button
                      variant="ghost"
                      size="icon"
                      className="flex-shrink-0 h-7 w-7"
                      onClick={() => markAsRead(notification.id)}
                      title="Mark as Read"
                    >
                      <Check className="h-4 w-4" />
                      <span className="sr-only">Mark as Read</span>
                    </Button>
                  )}
                </div>
              ))
            )}
          </div>
        </ScrollArea>
      </CardContent>
    </Card>
  )
}
