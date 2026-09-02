-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Laptop
hl.monitor({ output = "eDP-2",    mode = "2560x1600@240", position = "0x440",     scale = 1.6 })
-- Desk monitor
hl.monitor({ output = "DP-1",     mode = "3840x2160@60",  position = "1600x0",     scale = 1.5 })
-- TV
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60",  position = "-1920x360",  scale = 2 })
