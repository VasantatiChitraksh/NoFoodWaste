"use client"

import * as React from "react"
import { Bar, BarChart, CartesianGrid, Line, LineChart, XAxis, YAxis } from "recharts"
import { type ChartConfig, ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart"
import { Card, CardContent } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

interface ChartData {
  monthly_requests: Array<{ month: string; requests: number }>
  monthly_meals: Array<{ month: string; meals: number }>
  top_donors: Array<{ donor: string; donations: number }>
}

const chartConfig = {
  requests: {
    label: "Accepted Requests",
    color: "hsl(var(--chart-1))",
  },
  meals: {
    label: "Meals Redistributed",
    color: "hsl(var(--chart-2))",
  },
  donations: {
    label: "Donations (meals)",
    color: "hsl(var(--chart-3))",
  },
} satisfies ChartConfig

export function Charts() {
  const [chartData, setChartData] = React.useState<ChartData | null>(null)
  const [loading, setLoading] = React.useState(true)

  React.useEffect(() => {
    const fetchChartsData = async () => {
      try {
        const response = await fetch(`${API_BASE_URL}/dashboard/charts-data`)
        if (response.ok) {
          const data = await response.json()
          setChartData(data)
        }
      } catch (error) {
        console.error("Failed to fetch charts data:", error)
      } finally {
        setLoading(false)
      }
    }

    fetchChartsData()
  }, [])

  if (loading) {
    return (
      <div className="flex items-center justify-center h-[250px]">
        <p>Loading charts...</p>
      </div>
    )
  }
  return (
    <Tabs defaultValue="requests" className="w-full">
      <TabsList className="grid w-full grid-cols-3">
        <TabsTrigger value="requests">Accepted Requests</TabsTrigger>
        <TabsTrigger value="trends">Redistribution Trends</TabsTrigger>
        <TabsTrigger value="donors">Top Donors</TabsTrigger>
      </TabsList>
      <TabsContent value="requests">
        <Card>
          <CardContent className="flex aspect-video items-center justify-center p-6">
            <ChartContainer config={chartConfig} className="h-[250px] w-full">
              <BarChart accessibilityLayer data={chartData?.monthly_requests || []}>
                <CartesianGrid vertical={false} />
                <XAxis
                  dataKey="month"
                  tickLine={false}
                  tickMargin={10}
                  axisLine={false}
                  tickFormatter={(value) => value.slice(0, 3)}
                />
                <YAxis />
                <ChartTooltip content={<ChartTooltipContent />} />
                <Bar dataKey="requests" fill="var(--color-requests)" radius={8} />
              </BarChart>
            </ChartContainer>
          </CardContent>
        </Card>
      </TabsContent>
      <TabsContent value="trends">
        <Card>
          <CardContent className="flex aspect-video items-center justify-center p-6">
            <ChartContainer config={chartConfig} className="h-[250px] w-full">
              <LineChart accessibilityLayer data={chartData?.monthly_meals || []}>
                <CartesianGrid vertical={false} />
                <XAxis
                  dataKey="month"
                  tickLine={false}
                  tickMargin={10}
                  axisLine={false}
                  tickFormatter={(value) => value.slice(0, 3)}
                />
                <YAxis />
                <ChartTooltip content={<ChartTooltipContent />} />
                <Line dataKey="meals" type="monotone" stroke="var(--color-meals)" strokeWidth={2} dot={false} />
              </LineChart>
            </ChartContainer>
          </CardContent>
        </Card>
      </TabsContent>
      <TabsContent value="donors">
        <Card>
          <CardContent className="flex aspect-video items-center justify-center p-6">
            <ChartContainer config={chartConfig} className="h-[250px] w-full">
              <BarChart accessibilityLayer data={chartData?.top_donors || []} layout="vertical">
                <CartesianGrid horizontal={false} />
                <YAxis dataKey="donor" type="category" tickLine={false} tickMargin={10} axisLine={false} />
                <XAxis type="number" dataKey="donations" />
                <ChartTooltip content={<ChartTooltipContent />} />
                <Bar dataKey="donations" fill="var(--color-donations)" radius={8} />
              </BarChart>
            </ChartContainer>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>
  )
}
