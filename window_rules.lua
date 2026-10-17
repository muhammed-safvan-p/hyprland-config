-- Window and workspace rules
local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- =============================================================================
-- SINGLE-WINDOW LAYOUT STYLES (Choose ONE option below by commenting/uncommenting)
-- =============================================================================

-- ── OPTION 1: Seamless Edge-to-Edge (Smart Gaps & Smart Borders) [ACTIVE] ───
-- Maximizes screen estate: 0 gaps, 0 borders, 0 rounding when alone.
-- hl.workspace_rule({
--     workspace = "w[tv1]",
--     gaps_out  = 0,
--     gaps_in   = 0,
-- })
-- hl.window_rule({
--     name = "single-window-option-1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- ── OPTION 2: Borderless Floating Canvas (Rounded Squircle & Shadows) ────────
-- Clean floating look: retains outer gaps, drop shadows, and rounded corners, but removes borders.
hl.workspace_rule({
    workspace = "w[tv1]",
    gaps_out  = 8,
    gaps_in   = 3,
})
hl.window_rule({
    name = "single-window-option-2",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
})

-- ── OPTION 3: Zen / Centered Layout (Reading & Focused Coding Mode) ───────────
-- Centers single windows with generous horizontal padding so text isn't stretched wide.
-- hl.workspace_rule({
--     workspace = "w[tv1]",
--     gaps_out  = { top = 16, bottom = 16, left = 140, right = 140 },
--     gaps_in   = 0,
-- })
-- hl.window_rule({
--     name = "single-window-option-3",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
-- })

-- ── Global Fullscreen Behavior (Always seamless) ─────────────────────────────
hl.workspace_rule({
    workspace = "f[1]",
    gaps_out  = 0,
    gaps_in   = 0,
})
hl.window_rule({
    name = "smart-gaps-fullscreen",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})
