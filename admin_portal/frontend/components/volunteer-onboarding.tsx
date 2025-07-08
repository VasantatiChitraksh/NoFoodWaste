"use client"

import * as React from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { DropdownMenu, DropdownMenuTrigger, DropdownMenuContent, DropMenuItem } from "@/components/ui/dropdown-menu"
import { MoreHorizontal, Upload, UserPlus, Mail, CheckCircle } from "lucide-react"
import { adminApi } from "@/lib/api"

interface VolunteerApplication {
  id: string
  name: string
  email: string
  phone: string
  address: string
  status: "applied" | "training" | "accepted"
  time_imported?: string
}

export function VolunteerOnboarding() {
  const [applications, setApplications] = React.useState<VolunteerApplication[]>([])
  const [searchTerm, setSearchTerm] = React.useState("")
  const [loading, setLoading] = React.useState(true)
  const [actionLoading, setActionLoading] = React.useState<string | null>(null)
  const [showImport, setShowImport] = React.useState(false)
  const [selectedFile, setSelectedFile] = React.useState<File | null>(null)
  const [importing, setImporting] = React.useState(false)

  React.useEffect(() => {
    fetchApplications()
  }, [])

  const fetchApplications = async () => {
    setLoading(true)
    try {
      const data = await adminApi.getVolunteerApplications()
      // Handle both array response and object with applications property
      if (Array.isArray(data)) {
        setApplications(data)
      } else if (data && (data as any).applications) {
        setApplications((data as any).applications)
      } else {
        setApplications([])
      }
    } catch (error) {
      console.error("Error fetching applications:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleSendTrainingInvite = async (applicationId: string) => {
    setActionLoading(applicationId)
    try {
      await adminApi.sendTrainingInvite(applicationId)
      // Refresh applications to update status
      await fetchApplications()
      alert("Training invite sent successfully!")
    } catch (error) {
      console.error("Error sending training invite:", error)
      alert("Failed to send training invite")
    } finally {
      setActionLoading(null)
    }
  }

  const handleAcceptVolunteer = async (applicationId: string) => {
    setActionLoading(applicationId)
    try {
      await adminApi.acceptVolunteer(applicationId)
      // Refresh applications to update status
      await fetchApplications()
      alert("Volunteer accepted successfully!")
    } catch (error) {
      console.error("Error accepting volunteer:", error)
      alert("Failed to accept volunteer")
    } finally {
      setActionLoading(null)
    }
  }
  const handleFileImport = async () => {
    if (!selectedFile) return

    setImporting(true)
    try {
      const result = await adminApi.importVolunteers(selectedFile)
      alert((result as any).message || "Volunteers imported successfully!")
      setSelectedFile(null)
      setShowImport(false)
      await fetchApplications()
    } catch (error) {
      console.error("Error importing volunteers:", error)
      alert("Failed to import volunteers")
    } finally {
      setImporting(false)
    }
  }

  const filteredApplications = applications.filter((app) => {
    const matchesSearch =
      app.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      app.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      app.phone.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesSearch
  })

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "applied":
        return <Badge>Applied</Badge>
      case "training":
        return <Badge>Training</Badge>
      case "accepted":
        return <Badge>Accepted</Badge>
      default:
        return <Badge>{status}</Badge>
    }
  }

  const getActionButton = (application: VolunteerApplication) => {
    const isLoading = actionLoading === application.id

    if (application.status === "applied") {
      return (
        <Button
          onClick={() => handleSendTrainingInvite(application.id)}
          disabled={isLoading}
          className="gap-1"
        >
          {isLoading ? (
            "Sending..."
          ) : (
            <>
              <Mail className="h-3 w-3" />
              Send Invite
            </>
          )}
        </Button>
      )
    }

    if (application.status === "training") {
      return (
        <Button
          onClick={() => handleAcceptVolunteer(application.id)}
          disabled={isLoading}
          className="gap-1"
        >
          {isLoading ? (
            "Accepting..."
          ) : (
            <>
              <CheckCircle className="h-3 w-3" />
              Accept
            </>
          )}
        </Button>
      )
    }

    return <Badge>Completed</Badge>
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Volunteer Onboarding</h1>
          <p className="text-muted-foreground">Manage volunteer applications and training process</p>
        </div>
        <Button
          onClick={() => setShowImport(true)}
          className="gap-2"
        >
          <Upload className="h-4 w-4" />
          Import Volunteers
        </Button>
      </div>

      {/* Import Modal */}
      {showImport && (
        <Card className="border-dashed">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Upload className="h-5 w-5" />
              Import Volunteers from Excel
            </CardTitle>
            <CardDescription>
              Upload an Excel file with volunteer applications (columns: name, email, phone, address)
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center gap-4">
              <input
                type="file"
                accept=".xlsx,.xls"
                onChange={(e) => setSelectedFile(e.target.files?.[0] || null)}
                className="flex-1"
              />
            </div>
            <div className="flex gap-2">
              <Button
                onClick={handleFileImport}
                disabled={!selectedFile || importing}
              >
                {importing ? "Importing..." : "Import"}
              </Button>
              <Button
                onClick={() => {
                  setShowImport(false)
                  setSelectedFile(null)
                }}
              >
                Cancel
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <UserPlus className="h-5 w-5" />
            Volunteer Applications
          </CardTitle>
          <CardDescription>
            Review and manage volunteer applications through the onboarding process
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex flex-col gap-4">
            <Input
              placeholder="Search applications by name, email, or phone..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="max-w-sm"
            />

            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Email</TableHead>
                    <TableHead>Phone</TableHead>
                    <TableHead>Address</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={6} className="text-center">
                        Loading applications...
                      </TableCell>
                    </TableRow>
                  ) : filteredApplications.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6} className="text-center">
                        No volunteer applications found.
                      </TableCell>
                    </TableRow>
                  ) : (
                    filteredApplications.map((application) => (
                      <TableRow key={application.id}>
                        <TableCell className="font-medium">{application.name}</TableCell>
                        <TableCell>{application.email}</TableCell>
                        <TableCell>{application.phone}</TableCell>
                        <TableCell className="max-w-xs truncate">{application.address}</TableCell>
                        <TableCell>{getStatusBadge(application.status)}</TableCell>
                        <TableCell className="text-right">
                          {getActionButton(application)}
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
