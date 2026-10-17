-- =============================================================================
--  Hyprland Keybindings & Workspace Configuration
-- =============================================================================
local programs = require("programs")

-- ── 1. Helpers & Wrappers ────────────────────────────────────────────────────
-- Executes a shell command
local function app(cmd, args)
    return hl.dsp.exec_cmd(args and (cmd .. " " .. args) or cmd)
end

-- Launches URL in browser app-mode
local function webapp(url)
    return app(programs.browser, "--new-window --app='" .. url .. "'")
end

-- Binds combo with SUPER modifier
local function bind(combo, dispatcher, opts)
    hl.bind(programs.super .. " + " .. combo, dispatcher, opts)
end

-- Hardware / media key bind (no SUPER, works on lockscreen)
local function hw_bind(key, cmd, repeating)
    hl.bind(key, hl.dsp.exec_cmd(cmd), { locked = true, repeating = repeating or false })
end

-- Calculates workspace target based on active monitor
local function get_target_workspace(num)
    local slot = (num == 0) and 10 or num
    local mon = hl.get_active_monitor()
    if mon and (mon.name == "HDMI-A-1" or mon.name == "HDMI-A-2") then
        return 10 + slot
    end
    return slot
end

-- Cycles workspaces strictly within the current monitor's range (1-10 or 11-20)
local function cycle_monitor_workspace(step)
    local ws = hl.get_active_workspace()
    local mon = hl.get_active_monitor()
    local is_hdmi = mon and (mon.name == "HDMI-A-1" or mon.name == "HDMI-A-2")
    local min_ws = is_hdmi and 11 or 1
    local max_ws = is_hdmi and 20 or 10

    local current_id = ws and ws.id or min_ws
    if current_id < min_ws or current_id > max_ws then
        current_id = min_ws
    end

    local next_id = current_id + step
    if next_id > max_ws then
        next_id = min_ws
    elseif next_id < min_ws then
        next_id = max_ws
    end

    hl.dispatch(hl.dsp.focus({ workspace = tostring(next_id) }))
end



-- ── 2. System & Session Controls ─────────────────────────────────────────────
-- SUPER + M             : Shutdown / Exit menu
bind("M", app("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- SUPER + L             : Lock screen
bind("L", app("loginctl lock-session || hyprlock --grace 0"))
bind("SHIFT + L", app("loginctl lock-session || hyprlock --grace 0"))

-- SUPER + SHIFT + SPACE : Toggle Waybar status bar
-- Waybar controls: Hold SUPER + SHIFT to peek, release to hide, or SUPER + SHIFT + SPACE to pin/toggle
bind("SPACE", app("/home/safvan/.config/waybar/peek.sh toggle"))
-- Hold SUPER + SHIFT to peek Waybar (peek_watcher handles hiding on key release)
bind("SHIFT_L", hl.dsp.exec_cmd("/home/safvan/.config/waybar/peek.sh show"), { non_consuming = true })
bind("SHIFT_R", hl.dsp.exec_cmd("/home/safvan/.config/waybar/peek.sh show"), { non_consuming = true })
hl.bind("SHIFT + SUPER_L", hl.dsp.exec_cmd("/home/safvan/.config/waybar/peek.sh show"), { non_consuming = true })
hl.bind("SHIFT + SUPER_R", hl.dsp.exec_cmd("/home/safvan/.config/waybar/peek.sh show"), { non_consuming = true })


-- SUPER + H             : Switch wallpaper
-- bind("H", app("/home/safvan/.config/hypr/scripts/wallpaper.sh"))
bind("code:21", hl.dsp.exec_cmd('wallpapercli next'))
bind("MINUS", hl.dsp.exec_cmd('wallpapercli prev'))


-- ── 3. Core Applications ─────────────────────────────────────────────────────
bind("RETURN", app(programs.terminal))     -- Terminal (foot)
bind("SHIFT + SPACE",  app(programs.menu))         -- App launcher (hyprlauncher)
bind("B",      app(programs.browser))      -- Web browser
bind("F",      app(programs.fileManager))  -- File manager (nautilus)


-- ── 4. Web Applications (SUPER + Key) ─────────────────────────────────────────
local webapps = {
    ["SHIFT + E"] = "https://mail.google.com",
    ["SHIFT + C"] = "https://chatgpt.com",
    ["SHIFT + Y"] = "https://www.youtube.com/",
    ["SHIFT + W"] = "https://web.whatsapp.com",
    ["SHIFT + V"] = "https://meet.google.com/svo-phmi-mrf",
    ["SHIFT + T"] = "https://student.brototype.com/",
}

for key, url in pairs(webapps) do
    bind(key, webapp(url))
end


-- ── 5. Window Management ─────────────────────────────────────────────────────
bind("D",         hl.dsp.window.close())                  -- Close focused window
bind("V",         hl.dsp.window.float({ action = "toggle" })) -- Toggle floating
bind("P",         hl.dsp.layout("togglesplit"))           -- Toggle split layout
bind("SHIFT + P", hl.dsp.window.pseudo())                 -- Pseudo-tile window


-- ── 6. Directional Navigation & Content Scrolling ────────────────────────────
-- Focus window with J / I / K (Left / Right / Up / Down)
local directions = {
    ["J"] = "left",
    ["L"] = "right",
    ["I"] = "up",
    ["K"] = "down",
}
for key, dir in pairs(directions) do
    bind(key, hl.dsp.focus({ direction = dir }))
end

-- Next & Previous workspace (per-monitor)
bind("T", function() cycle_monitor_workspace(1) end)   -- Next workspace on current monitor
bind("R", function() cycle_monitor_workspace(-1) end)  -- Previous workspace on current monitor


-- ── 7. Workspaces & Navigation ───────────────────────────────────────────────
-- Numeric Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    bind(tostring(key), function()
        local target = get_target_workspace(key)
        hl.dispatch(hl.dsp.focus({ workspace = tostring(target) }))
    end)
    bind("SHIFT + " .. key, function()
        local target = get_target_workspace(key)
        hl.dispatch(hl.dsp.window.move({ workspace = tostring(target) }))
    end)
end


-- Special Scratchpads
bind("Grave",         hl.dsp.workspace.toggle_special("dev_scratch"))
bind("SHIFT + Grave", hl.dsp.window.move({ workspace = "special:dev_scratch" }))
bind("S",             hl.dsp.workspace.toggle_special("magic"))
bind("ALT + S",     hl.dsp.window.move({ workspace = "special:magic" }))


-- ── 8. Media & Hardware Controls ─────────────────────────────────────────────
-- Audio volume & mute
hw_bind("XF86AudioRaiseVolume",  "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", true)
hw_bind("XF86AudioLowerVolume",  "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",      true)
hw_bind("XF86AudioMute",         "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",     true)
hw_bind("XF86AudioMicMute",      "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",   true)

-- Screen Brightness
hw_bind("XF86MonBrightnessUp",   "brightnessctl set 5%+", true)
hw_bind("XF86MonBrightnessDown", "brightnessctl set 5%-", true)

-- Media Player Controls
for key, action in pairs({
    XF86AudioNext  = "next",
    XF86AudioPause = "play-pause",
    XF86AudioPlay  = "play-pause",
    XF86AudioPrev  = "previous",
}) do
    hw_bind(key, "playerctl " .. action)
end


-- ── 9. Screenshots & Mouse Controls ──────────────────────────────────────────
-- Screenshots (hyprshot)
local screenshot_dir = "/home/safvan/Photos/screenshorts"
hw_bind("PRINT",        "hyprshot -m output -o " .. screenshot_dir)
bind("PRINT",           hl.dsp.exec_cmd("hyprshot -m region -o " .. screenshot_dir))
bind("SHIFT + PRINT",   hl.dsp.exec_cmd("hyprshot -m window -o " .. screenshot_dir))

-- Helpers to check modifier keys
local function is_z_held()
    return hl.is_key_down("z") or hl.is_key_down("Z")
end

local function is_x_held()
    return hl.is_key_down("x") or hl.is_key_down("X")
end

-- Mouse actions:
-- • SUPER + Z + Scroll Up/Down : Volume Up / Down (wpctl)
-- • SUPER + X + Scroll Up/Down : Brightness Up / Down (brightnessctl)
-- • SUPER + Scroll             : Cycle workspaces on active monitor
bind("mouse_up", function()
    if is_z_held() then
        hl.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
    elseif is_x_held() then
        hl.exec_cmd("brightnessctl set 5%+")
    else
        cycle_monitor_workspace(-1)
    end
end)

bind("mouse_down", function()
    if is_z_held() then
        hl.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
    elseif is_x_held() then
        hl.exec_cmd("brightnessctl set 5%-")
    else
        cycle_monitor_workspace(1)
    end
end)

bind("mouse:272",  hl.dsp.window.drag(),   { mouse = true })
bind("mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Consume SUPER + Z and SUPER + X so they don't trigger application-level actions
bind("Z", hl.dsp.no_op())
bind("X", hl.dsp.no_op())


-- Scroll active window content (Up / Down)
bind("U", hl.dsp.send_shortcut({ mods = "", key = "Up" }),   { repeating = true })
bind("N", hl.dsp.send_shortcut({ mods = "", key = "Down" }), { repeating = true })

-- ── Available Free Letters Cheat Sheet ───────────────────────────────────────
-- SUPER + [A, O, Q] are currently 100% free for new keybindings (Z = volume scroll, X = brightness scroll).
-- SUPER + SHIFT + [any letter except P, S] are also free.



