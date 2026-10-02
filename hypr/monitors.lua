-- Omarchy Quattro monitor configuration.
-- Inspect live outputs and supported modes with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Safe fallback for an unknown or temporarily connected output.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Keep the laptop at the origin and the external display to its right.
hl.monitor({ output = "eDP-1", mode = "1920x1080@60.015", position = "0x0", scale = 1 })
-- Select the connected display's preferred resolution and refresh rate.
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "1920x0", scale = 1 })
