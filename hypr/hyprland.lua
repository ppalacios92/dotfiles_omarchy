-- Omarchy Quattro / Hyprland 0.55+ entry point.
-- Packaged defaults remain under /usr/share/omarchy and are never edited here.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Load Omarchy defaults first, then the personal overrides tracked by this repo.
require("default.hypr.omarchy")
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Keep Omarchy's dynamic toggles (gaps, opacity, aspect ratio, and similar).
require("default.hypr.toggles")
