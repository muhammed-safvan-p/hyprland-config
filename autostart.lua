-- autostart.lua
hl.on("hyprland.start", function ()
    hl.exec_cmd("waybar")
    hl.exec_cmd("wallpapercli start")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("workfolio")
end)
