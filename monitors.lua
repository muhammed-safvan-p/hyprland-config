-- Monitor setup
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "0x0",
    scale    = "1.25",
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "preferred",
    position = "auto-right",
    scale    = "1.25",
})

-- Fallback for unspecified monitors
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1",
})
