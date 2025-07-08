"use client"

import * as React from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Input } from "@/components/ui/input"
import { DropdownMenu, DropdownMenuTrigger, DropdownMenuContent, DropMenuItem } from "@/components/ui/dropdown-menu"
import { Button } from "@/components/ui/button"
import { MoreHorizontal } from "lucide-react"
import { adminApi } from "@/lib/api"

interface Admin {
  id: string
  name: string
  email: string
  lastActivity: string
}

export function AdminList() {
  const [admins, setAdmins] = React.useState<Admin[]>([])
  const [searchTerm, setSearchTerm] = React.useState("")
  const [loading, setLoading] = React.useState(true)
  const [showAdd, setShowAdd] = React.useState(false)
  const [newAdmin, setNewAdmin] = React.useState({ name: "", email: "" })
  const [adding, setAdding] = React.useState(false)

  React.useEffect(() => {
    const fetchAdmins = async () => {
      setLoading(true)
      try {
        const adminsData = await adminApi.getAdmins()
        setAdmins(adminsData)
      } catch (error) {
        console.error("Error fetching admins:", error)
      }
      setLoading(false)
    }
    fetchAdmins()
  }, [adding])

  const filteredAdmins = admins.filter((admin) => {
    const matchesSearch =
      admin.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      admin.email.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesSearch
  })

  const handleAddAdmin = async () => {
    if (!newAdmin.name || !newAdmin.email) return
    setAdding(true)
    try {
      await adminApi.addAdmin({
        name: newAdmin.name,
        email: newAdmin.email,
      })
      setNewAdmin({ name: "", email: "" })
      setShowAdd(false)
      // Trigger re-fetch by changing the adding state
    } catch (error) {
      console.error("Failed to add admin:", error)
      alert("Failed to add admin")
    }
    setAdding(false)
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Admin List</CardTitle>
        <CardDescription>View and manage dashboard administrators.</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="flex flex-col md:flex-row gap-4 mb-4 items-center">
          <Input
            placeholder="Search admins..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="max-w-sm"
          />
          <Button
            className="md:ml-auto w-full md:w-auto"
            onClick={() => setShowAdd(true)}
          >
            + Add Admin
          </Button>
        </div>
        {showAdd && (
          <div className="mb-4 flex flex-col md:flex-row gap-2 items-center bg-gray-50 p-4 rounded">
            <Input
              placeholder="Name"
              value={newAdmin.name}
              onChange={e => setNewAdmin({ ...newAdmin, name: e.target.value })}
              className="max-w-xs"
              disabled={adding}
            />
            <Input
              placeholder="Email"
              value={newAdmin.email}
              onChange={e => setNewAdmin({ ...newAdmin, email: e.target.value })}
              className="max-w-xs"
              disabled={adding}
            />
            <Button onClick={handleAddAdmin} disabled={adding || !newAdmin.name || !newAdmin.email}>
              {adding ? "Adding..." : "Save"}
            </Button>
            <Button variant="outline" onClick={() => setShowAdd(false)} disabled={adding}>
              Cancel
            </Button>
          </div>
        )}
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Email</TableHead>
                <TableHead>Last Activity</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={4} className="text-center">
                    Loading...
                  </TableCell>
                </TableRow>
              ) : filteredAdmins.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={4} className="text-center">
                    No admins found.
                  </TableCell>
                </TableRow>
              ) : (
                filteredAdmins.map((admin) => (
                  <TableRow key={admin.id}>
                    <TableCell className="font-medium">{admin.name}</TableCell>
                    <TableCell>{admin.email}</TableCell>
                    <TableCell>{admin.lastActivity}</TableCell>
                    <TableCell className="text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" className="h-8 w-8 p-0">
                            <span className="sr-only">Open menu</span>
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropMenuItem onClick={() => console.log(`Edit ${admin.name}`)}>Edit Admin</DropMenuItem>
                          <DropMenuItem onClick={() => console.log(`View logs for ${admin.name}`)}>
                            View Activity Logs
                          </DropMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  )
}
