-- Personal input overrides for Omarchy Quattro.
hl.config({
  input = {
    kb_layout = "us",
    kb_options = "compose:caps",
    repeat_rate = 40,
    repeat_delay = 600,
    numlock_by_default = true,
    touchpad = {
      scroll_factor = 0.4,
    },
  },
})

-- Per-application touchpad speed retained from the Omarchy 3 setup.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
