"use client"

import * as React from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Check, X, MapPin, Filter } from "lucide-react"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

interface Request {
  id: string
  donor: string
  recipient: string
  status: "Pending" | "Accepted" | "Rejected" | "Fulfilled"
  priority: "High" | "Medium" | "Low"
  foodType: string
  location: string
  timestamp: string
}

const initialRequests: Request[] = [
  {
    id: "req001",
    donor: "Green Grocers",
    recipient: "Community Shelter",
    status: "Pending",
    priority: "High",
    foodType: "Fresh Produce",
    location: "123 Main St, City",
    timestamp: "2023-10-26 10:00",
  },
  {
    id: "req002",
    donor: "City Bakery",
    recipient: "Soup Kitchen",
    status: "Accepted",
    priority: "Medium",
    foodType: "Baked Goods",
    location: "456 Oak Ave, Town",
    timestamp: "2023-10-25 14:30",
  },
  {
    id: "req003",
    donor: "Farm Fresh",
    recipient: "Family Support Center",
    status: "Pending",
    priority: "High",
    foodType: "Dairy & Eggs",
    location: "789 Pine Ln, Village",
    timestamp: "2023-10-26 09:15",
  },
  {
    id: "req004",
    donor: "Local Cafe",
    recipient: "Homeless Outreach",
    status: "Fulfilled",
    priority: "Low",
    foodType: "Prepared Meals",
    location: "101 Elm St, City",
    timestamp: "2023-10-24 11:00",
  },
  {
    id: "req005",
    donor: "SuperMart",
    recipient: "Food Bank",
    status: "Rejected",
    priority: "Medium",
    foodType: "Canned Goods",
    location: "202 Birch Rd, Town",
    timestamp: "2023-10-23 16:45",
  },
]

export function RequestsTable() {
  const [requests, setRequests] = React.useState<Request[]>(initialRequests)
  const [searchTerm, setSearchTerm] = React.useState("")
  const [filterStatus, setFilterStatus] = React.useState<string>("all")
  const [filterPriority, setFilterPriority] = React.useState<string>("all")

  const filteredRequests = requests.filter((request) => {
    const matchesSearch =
      request.donor.toLowerCase().includes(searchTerm.toLowerCase()) ||
      request.recipient.toLowerCase().includes(searchTerm.toLowerCase()) ||
      request.foodType.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = filterStatus === "all" || request.status === filterStatus
    const matchesPriority = filterPriority === "all" || request.priority === filterPriority
    return matchesSearch && matchesStatus && matchesPriority
  })

  const handleStatusChange = (id: string, newStatus: "Accepted" | "Rejected") => {
    setRequests((prev) => prev.map((req) => (req.id === id ? { ...req, status: newStatus } : req)))
  }

  const getPriorityBadgeVariant = (priority: string) => {
    switch (priority) {
      case "High":
        return "destructive"
      case "Medium":
        return "default"
      case "Low":
        return "secondary"
      default:
        return "outline"
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Requests</CardTitle>
        <CardDescription>Manage food donation and redistribution requests.</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="flex flex-col md:flex-row gap-4 mb-4">
          <Input
            placeholder="Search requests..."
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
              <SelectItem value="Pending">Pending</SelectItem>
              <SelectItem value="Accepted">Accepted</SelectItem>
              <SelectItem value="Rejected">Rejected</SelectItem>
              <SelectItem value="Fulfilled">Fulfilled</SelectItem>
            </SelectContent>
          </Select>
          <Select value={filterPriority} onValueChange={setFilterPriority}>
            <SelectTrigger className="w-[180px]">
              <Filter className="mr-2 h-4 w-4" />
              <SelectValue placeholder="Filter by Priority" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Priorities</SelectItem>
              <SelectItem value="High">High</SelectItem>
              <SelectItem value="Medium">Medium</SelectItem>
              <SelectItem value="Low">Low</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>ID</TableHead>
                <TableHead>Donor</TableHead>
                <TableHead>Recipient</TableHead>
                <TableHead>Food Type</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Location</TableHead>
                <TableHead>Timestamp</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredRequests.map((request) => (
                <TableRow key={request.id}>
                  <TableCell className="font-medium">{request.id}</TableCell>
                  <TableCell>{request.donor}</TableCell>
                  <TableCell>{request.recipient}</TableCell>
                  <TableCell>{request.foodType}</TableCell>
                  <TableCell>
                    <Badge
                      variant={
                        request.status === "Pending"
                          ? "outline"
                          : request.status === "Accepted" || request.status === "Fulfilled"
                            ? "default"
                            : "destructive"
                      }
                    >
                      {request.status}
                    </Badge>
                  </TableCell>
                  <TableCell className="flex items-center gap-1">
                    <MapPin className="size-4 text-muted-foreground" />
                    {request.location}
                  </TableCell>
                  <TableCell className="text-sm text-muted-foreground">{request.timestamp}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  )
}
