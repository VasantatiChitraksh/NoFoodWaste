"use client"
import { LayoutDashboard, Users, UserCog, Bell, ClipboardList, Map, Leaf, UserPlus } from "lucide-react"

import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarRail,
} from "@/components/ui/sidebar"

interface DashboardSidebarProps {
  activeSection: string
  setActiveSection: (section: string) => void
}

export function DashboardSidebar({ activeSection, setActiveSection }: DashboardSidebarProps) {
  const navItems = [
    {
      title: "Dashboard",
      icon: LayoutDashboard,
      section: "dashboard",
    },
    {
      title: "Volunteer Management",
      icon: Users,
      section: "volunteer-management",
    },
    {
      title: "Volunteer Onboarding",
      icon: UserPlus,
      section: "volunteer-onboarding",
    },
    {
      title: "Admin List",
      icon: UserCog,
      section: "admin-list",
    },
    {
      title: "Notifications",
      icon: Bell,
      section: "notifications",
    },
    {
      title: "Requests",
      icon: ClipboardList,
      section: "requests",
    },
    {
      title: "Hunger Hotspot Map",
      icon: Map,
      section: "hunger-hotspot-map",
    },
  ]

  return (
    <Sidebar>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton size="lg" asChild>
              <a href="#" onClick={() => setActiveSection("dashboard")}>
                <div className="flex aspect-square size-8 items-center justify-center rounded-lg bg-green-600 text-white">
                  <Leaf className="size-4" />
                </div>
                <div className="flex flex-col gap-0.5 leading-none">
                  <span className="font-semibold">No Food Waste</span>
                  <span className="text-xs text-muted-foreground">Admin Dashboard</span>
                </div>
              </a>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarMenu>
            {navItems.map((item, idx) => (
              <SidebarMenuItem key={item.section} className={idx !== 0 ? "mt-2" : ""}>
                <SidebarMenuButton
                  asChild
                  isActive={activeSection === item.section}
                  onClick={() => setActiveSection(item.section)}
                >
                  <a href="#">
                    <item.icon />
                    <span>{item.title}</span>
                  </a>
                </SidebarMenuButton>
              </SidebarMenuItem>
            ))}
          </SidebarMenu>
        </SidebarGroup>
      </SidebarContent>
      <SidebarRail />
    </Sidebar>
  )
}
