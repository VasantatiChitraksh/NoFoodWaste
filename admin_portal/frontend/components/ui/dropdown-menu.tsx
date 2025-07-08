import * as React from "react"
import {
  DropdownMenu as RadixDropdownMenu,
  DropdownMenuContent as RadixDropdownMenuContent,
  DropdownMenuItem as RadixDropdownMenuItem,
  DropdownMenuTrigger as RadixDropdownMenuTrigger,
} from "@radix-ui/react-dropdown-menu"
import { cn } from "@/lib/utils"

const DropdownMenu = RadixDropdownMenu
const DropdownMenuTrigger = RadixDropdownMenuTrigger
const DropdownMenuContent = RadixDropdownMenuContent

interface DropMenuItemProps extends React.ComponentProps<typeof RadixDropdownMenuItem> {}

const DropMenuItem = React.forwardRef<HTMLButtonElement, DropMenuItemProps>(({ className, ...props }, ref) => (
  <RadixDropdownMenuItem
    className={cn(
      "flex items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-none focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
      className,
    )}
    {...props}
    ref={ref}
  />
))
DropMenuItem.displayName = "DropMenuItem"

export { DropdownMenu, DropdownMenuTrigger, DropdownMenuContent, DropMenuItem }
