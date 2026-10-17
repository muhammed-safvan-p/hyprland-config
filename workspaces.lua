-- Workspace rules and monitor assignments
local programs = require("programs")

-- ── Monitor A (eDP-1): Workspaces 1-10 ─────────────────────────
for i = 1, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = "eDP-1",
        default   = (i == 1),
    })
end

-- ── Monitor B (HDMI-A-1): Workspaces 11-20 ─────────────────────
for i = 11, 20 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = "HDMI-A-1",
        default   = (i == 11),
    })
end

-- (Single-window and fullscreen layout rules are managed in window_rules.lua)

-- ── Special Scratchpad Workspaces ──────────────────────────────
hl.workspace_rule({
    workspace        = "special:dev_scratch",
    on_created_empty = programs.terminal,
})

hl.workspace_rule({
    workspace        = "special:magic",
    on_created_empty = programs.terminal,
})
