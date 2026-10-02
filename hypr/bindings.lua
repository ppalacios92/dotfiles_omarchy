-- Preserve the application override that differs from Omarchy defaults.
-- Omarchy Quattro assigns SUPER+SHIFT+W to Omawrite; this workstation used it
-- for Typora, so explicitly replace the default binding.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })
