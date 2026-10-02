-- Mount Esmeralda once per Hyprland session. The mountpoint guard makes a
-- compositor restart harmless when SSHFS is already mounted.
o.exec_on_start([[
  sh -lc 'sleep 5; mountpoint -q /mnt/esmeralda-mnt || exec sshfs esmeralda:/mnt /mnt/esmeralda-mnt -o port=6023,reconnect,ServerAliveInterval=15'
]])

-- CERNBox requires XWayland on this workstation.
o.launch_on_start("env QT_QPA_PLATFORM=xcb cernbox")
