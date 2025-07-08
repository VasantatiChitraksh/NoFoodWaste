"use client"

import * as React from "react"
import { Separator } from "@/components/ui/separator"
import { SidebarInset, SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar"
import { DashboardSidebar } from "@/components/dashboard-sidebar"
import { DashboardContent } from "@/components/dashboard-content"
import { VolunteerManagement } from "@/components/volunteer-management"
import { VolunteerOnboarding } from "@/components/volunteer-onboarding"
import { AdminList } from "@/components/admin-list"
import { Notifications } from "@/components/notifications"
import { RequestsTable } from "@/components/requests-table"
import { HungerHotspotMap } from "@/components/hunger-hotspot-map"
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb"

export default function DashboardPage() {
  const [activeSection, setActiveSection] = React.useState("dashboard")

  const renderContent = () => {
    switch (activeSection) {
      case "dashboard":
        return <DashboardContent />
      case "volunteer-management":
        return <VolunteerManagement />
      case "volunteer-onboarding":
        return <VolunteerOnboarding />
      case "admin-list":
        return <AdminList />
      case "notifications":
        return <Notifications />
      case "requests":
        return <RequestsTable />
      case "hunger-hotspot-map":
        return <HungerHotspotMap />
      default:
        return <DashboardContent />
    }
  }

  const getBreadcrumbTitle = (section: string) => {
    switch (section) {
      case "dashboard":
        return "Dashboard"
      case "volunteer-management":
        return "Volunteer Management"
      case "volunteer-onboarding":
        return "Volunteer Onboarding"
      case "admin-list":
        return "Admin List"
      case "notifications":
        return "Notifications"
      case "requests":
        return "Requests"
      case "hunger-hotspot-map":
        return "Hunger Hotspot Map"
      default:
        return "Dashboard"
    }
  }

  return (
    <SidebarProvider>
      <DashboardSidebar activeSection={activeSection} setActiveSection={setActiveSection} />
      <SidebarInset>
        <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
          <SidebarTrigger className="-ml-1" />
          <Separator orientation="vertical" className="mr-2 h-4" />
          <Breadcrumb>
            <BreadcrumbList>
              <BreadcrumbItem>
                <BreadcrumbLink href="#">No Food Waste</BreadcrumbLink>
              </BreadcrumbItem>
              <BreadcrumbSeparator />
              <BreadcrumbItem>
                <BreadcrumbPage>{getBreadcrumbTitle(activeSection)}</BreadcrumbPage>
              </BreadcrumbItem>
            </BreadcrumbList>
          </Breadcrumb>
        </header>
        <div className="flex flex-1 flex-col gap-4 p-4">{renderContent()}</div>
      </SidebarInset>
    </SidebarProvider>
  )
}
