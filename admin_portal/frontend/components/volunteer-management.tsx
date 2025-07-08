"use client"

import * as React from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Button } from "@/components/ui/button"
import { DropdownMenu, DropdownMenuContent, DropMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { MoreHorizontal, Filter } from "lucide-react"

interface Volunteer {
  id: string
  name: string
  status: "Active" | "Inactive" | "On Leave"
  assignedTasks: number
  lastActivity: string
}

const initialVolunteers: Volunteer[] = [
  {
    id: "v001",
    name: "Alice Johnson",
    status: "Active",
    assignedTasks: 5,
    lastActivity: "2 days ago",
  },
  {
    id: "v002",
    name: "Bob Williams",
    status: "Active",
    assignedTasks: 3,
    lastActivity: "1 day ago",
  },
  {
    id: "v003",
    name: "Charlie Brown",
    status: "On Leave",
    assignedTasks: 0,
    lastActivity: "1 week ago",
  },
  {
    id: "v004",
    name: "Diana Prince",
    status: "Inactive",
    assignedTasks: 0,
    lastActivity: "3 weeks ago",
  },
  {
    id: "v005",
    name: "Eve Adams",
    status: "Active",
    assignedTasks: 7,
    lastActivity: "5 hours ago",
  },
]

export function VolunteerManagement() {
  const [volunteers, setVolunteers] = React.useState<Volunteer[]>(initialVolunteers)
  const [searchTerm, setSearchTerm] = React.useState("")
  const [filterStatus, setFilterStatus] = React.useState<string>("all")

  const filteredVolunteers = volunteers.filter((volunteer) => {
    const matchesSearch = volunteer.name.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = filterStatus === "all" || volunteer.status === filterStatus
    return matchesSearch && matchesStatus
  })

  const handleAssignTask = (volunteerId: string, task: string) => {
    setVolunteers((prev) => prev.map((v) => (v.id === volunteerId ? { ...v, assignedTasks: v.assignedTasks + 1 } : v)))
    console.log(`Assigned ${task} to ${volunteerId}`)
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Volunteer Management</CardTitle>
        <CardDescription>Manage volunteers, track training, and assign tasks.</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="flex flex-col md:flex-row gap-4 mb-4">
          <Input
            placeholder="Search volunteers..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="max-w-sm"
          />
          <Select value={filterStatus} onValueChange={setFilterStatus}>
            <SelectTrigger className="w-[180px]">
              <Filter className="mr-2 h-4 w-4" />
              <SelectValue placeholder="Filter by Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Statuses</SelectItem>
              <SelectItem value="Active">Active</SelectItem>
              <SelectItem value="Inactive">Inactive</SelectItem>
              <SelectItem value="On Leave">On Leave</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Assigned Tasks</TableHead>
                <TableHead>Last Activity</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredVolunteers.map((volunteer) => (
                <TableRow key={volunteer.id}>
                  <TableCell className="font-medium">{volunteer.name}</TableCell>
                  <TableCell>
                    <Badge
                      variant={
                        volunteer.status === "Active"
                          ? "default"
                          : volunteer.status === "On Leave"
                            ? "secondary"
                            : "destructive"
                      }
                    >
                      {volunteer.status}
                    </Badge>
                  </TableCell>
                  <TableCell>{volunteer.assignedTasks}</TableCell>
                  <TableCell>{volunteer.lastActivity}</TableCell>
                  <TableCell className="text-right">
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" className="h-8 w-8 p-0">
                          <span className="sr-only">Open menu</span>
                          <MoreHorizontal className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropMenuItem onClick={() => console.log(`View ${volunteer.name}`)}>View Details</DropMenuItem>
                        <DropMenuItem onClick={() => console.log(`Edit ${volunteer.name}`)}>Edit</DropMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  )
}
