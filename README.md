# Hyprland Dotfiles & Configuration Guide

> **Comprehensive Architecture, Module Layout, and Developer Guide**  
> This document outlines the complete system design, modular Lua architecture, keybindings, hardware controls, and developer workflows for this Hyprland environment. It is designed to provide anyone—human developer or AI agent—instant, complete context on how every component functions and interacts.

---

## 1. System & Architecture Overview

* **Compositor**: Hyprland `v0.56.2+`
* **Configuration Format**: **Native Embedded Lua API** (Hyprland v0.55+ native Lua embed utilizing the global `hl` table).
* **Entry Point**: [`hyprland.lua`](file:///home/safvan/.config/hypr/hyprland.lua) (modular architecture, cleanly loads components via `require(...)`).
* **Live Reload Command**: 
  ```bash
  hyprctl reload config-only
  ```
  *(Applies configuration changes instantly without display flicker or restarting Wayland sessions).*
* **Core Ecosystem & Tools**:
  * **Status Bar**: [Waybar](https://github.com/Alexays/Waybar) with a custom stateful **Peek & Pin** engine ([`peek.sh`](file:///home/safvan/.config/waybar/peek.sh) + [`peek_watcher.py`](file:///home/safvan/.config/waybar/peek_watcher.py)).
  * **Dynamic Theming**: [Matugen](https://github.com/InioX/matugen) dynamic Material You colors via [`colors.lua`](file:///home/safvan/.config/hypr/colors.lua) and [`colors.css`](file:///home/safvan/.config/hypr/colors.css).
  * **Wallpaper Engine**: `hyprpaper` configured via [`hyprpaper.conf`](file:///home/safvan/.config/hypr/hyprpaper.conf) and cycled via `wallpapercli`.
  * **Audio Server**: WirePlumber / PipeWire via `wpctl`.
  * **Backlight**: `brightnessctl`.
  * **Media Playback**: `playerctl`.
  * **Screenshots**: `hyprshot` (stored in `~/Photos/screenshorts`).
  * **Terminal**: `foot`.
  * **App Launcher**: `hyprlauncher`.
  * **Browser**: `helium-browser` (default web browser and general web apps), `brave` (dedicated for Spotify app mode).
  * **File Manager**: `nautilus`.
  * **Screen Sharing Portal**: `xdg-desktop-portal-hyprland` configured via [`xdph.conf`](file:///home/safvan/.config/hypr/xdph.conf).

---

## 2. Directory Structure & File Map

All configuration files reside in `/home/safvan/.config/hypr/`:

| File | Type | Purpose & Details |
| :--- | :---: | :--- |
| [`hyprland.lua`](file:///home/safvan/.config/hypr/hyprland.lua) | **Entry Point** | Master loader. Requires each modular file in strict initialization order. |
| [`monitors.lua`](file:///home/safvan/.config/hypr/monitors.lua) | **Display** | Display outputs, custom 1.25x scaling for laptop and HDMI, and fallback rules. |
| [`workspaces.lua`](file:///home/safvan/.config/hypr/workspaces.lua) | **Workspaces** | Strict monitor-to-workspace bindings (1–10 for laptop, 11–20 for HDMI), smart gaps, and scratchpad rules. |
| [`autostart.lua`](file:///home/safvan/.config/hypr/autostart.lua) | **Lifecycle** | Listens to `hyprland.start` to spawn essential daemons (`waybar & hyprpaper`). |
| [`programs.lua`](file:///home/safvan/.config/hypr/programs.lua) | **Defaults** | Central dictionary of preferred applications (`terminal`, `browser`, `fileManager`, `super`). |
| [`environment.lua`](file:///home/safvan/.config/hypr/environment.lua) | **Env Vars** | GTK (`Adwaita:dark`), Qt (`qt6ct`), and cursor theme / size configurations. |
| [`appearance.lua`](file:///home/safvan/.config/hypr/appearance.lua) | **Visuals** | Border styling, 45° gradients, blur, dwindle layout, and custom spring/bezier animation curves. |
| [`colors.lua`](file:///home/safvan/.config/hypr/colors.lua) | **Palette** | Auto-generated palette by Matugen with RGB and raw hex values consumed by `appearance.lua`. |
| [`colors.css`](file:///home/safvan/.config/hypr/colors.css) | **Style Tokens** | CSS color variables shared with Waybar and GTK widgets. |
| [`input.lua`](file:///home/safvan/.config/hypr/input.lua) | **Input Devices** | Keyboard layout (`us`), natural touchpad scrolling, tap-to-click, and 3-finger swipe gestures. |
| [`keybindings.lua`](file:///home/safvan/.config/hypr/keybindings.lua) | **Keybindings** | Complete shortcut maps, custom stateful mouse scroll hooks, and dual-monitor workspace routing. |
| [`window_rules.lua`](file:///home/safvan/.config/hypr/window_rules.lua) | **Window Rules** | XWayland drag fixes, maximization suppression, and floating dialog overrides. |
| [`xdph.conf`](file:///home/safvan/.config/hypr/xdph.conf) | **Portal** | Screencopy cursor mode configuration for `xdg-desktop-portal-hyprland`. |
| [`hyprpaper.conf`](file:///home/safvan/.config/hypr/hyprpaper.conf) | **Wallpaper** | Hyprpaper preload definitions and monitor wallpaper assignments. |
| [`hyprlock.conf`](file:///home/safvan/.config/hypr/hyprlock.conf) | **Lockscreen** | GPU-blurred live background, digital clock, date, username, and rounded pill password input. |
| [`hypridle.conf`](file:///home/safvan/.config/hypr/hypridle.conf) | **Idle Daemon** | 5-minute inactivity screen lock (`loginctl lock-session`) and 10-minute display sleep (`dpms off`). |
| [`hyprlock-colors.conf`](file:///home/safvan/.config/hypr/hyprlock-colors.conf) | **Theme Colors** | Dynamic Material You palette generated by Matugen for Hyprlock. |
| [`scripts/workspace.sh`](file:///home/safvan/.config/hypr/scripts/workspace.sh) | **Helper** | Dual-monitor workspace dispatcher script for switching and moving windows across monitors. |

---

## 3. Monitor & Workspace Architecture

### Dual-Monitor Workspace Split
Workspaces are strictly isolated between connected displays to ensure independent multi-monitor workflows:
* **Monitor A (`eDP-1` - Laptop screen)**: Workspaces **`1` through `10`** (Default: `1`).
* **Monitor B (`HDMI-A-1` - External display)**: Workspaces **`11` through `20`** (Default: `11`).

### Intelligent Workspace Routing
The configuration uses a unified function [`get_target_workspace(num)`](file:///home/safvan/.config/hypr/keybindings.lua#L28-L35):
* When your cursor/focus is on the **laptop (`eDP-1`)**, keys `1`–`0` switch/move to workspaces **`1`–`10`**.
* When your cursor/focus is on the **external monitor (`HDMI-A-1`)**, keys `1`–`0` automatically offset by `+10` and switch/move to workspaces **`11`–`20`**.
* You never need to remember or type two-digit workspace numbers.

### Monitor Workspace Cycling (`cycle_monitor_workspace(step)`)
* Pressing `SUPER + T` (next) or `SUPER + R` (previous) loops **strictly within the bounds of the active monitor**:
  * On `eDP-1`: Cycles within `1` $\leftrightarrow$ `10`.
  * On `HDMI-A-1`: Cycles within `11` $\leftrightarrow$ `20`.

### Special Scratchpads
Hyprland special workspaces act as floating, summonable scratchpad layers:
* **`special:dev_scratch`**:
  * **Toggle**: `SUPER + Grave (~)`
  * **Move window into scratchpad**: `SUPER + SHIFT + Grave (~)`
  * **Auto-spawn**: Automatically launches `foot` if empty upon opening.
* **`special:magic`**:
  * **Toggle**: `SUPER + S`
  * **Move window into magic**: `SUPER + ALT + S`
  * **Auto-spawn**: Automatically launches `foot` if empty upon opening.
* **How to remove a window from a special scratchpad**:
  * While focused on the window inside the scratchpad, press **`SUPER + SHIFT + [1-0]`** (or whichever workspace move shortcut you use). This immediately moves the window back onto that standard workspace and out of the scratchpad.

---

## 4. Keybinding & Control Reference

The primary modifier across all custom bindings is `SUPER` (Windows key).

### System & Session Controls
| Keybinding | Action | Command / Mechanism |
| :--- | :--- | :--- |
| `SUPER + M` | Exit / Shutdown Menu | Launches `hyprshutdown`, fallback to `hl.dsp.exit()` |
| `SUPER + SHIFT + L` | **Manual Screen Lock** | `loginctl lock-session || hyprlock` |
| `SUPER + SHIFT + SPACE` | **Toggle / Pin Waybar** | Calls `/home/safvan/.config/waybar/peek.sh toggle` (pins open/closed) |
| `SUPER + SHIFT` *(Hold)* | **Peek Waybar** | Calls `peek.sh show`; hides automatically when either key is released |
| `SUPER + W` | **Wallpaper Gallery** | Launches `~/.config/hypr/scripts/wallpaper-selector` (Rofi gallery) |
| `SUPER + SHIFT + =` (`code:21`) | Next Wallpaper | `wallpapercli next` |
| `SUPER + SHIFT + -` (`MINUS`) | Previous Wallpaper | `wallpapercli prev` |

### Core Applications
| Keybinding | Application | Executable |
| :--- | :--- | :--- |
| `SUPER + RETURN` | Terminal | `foot` |
| `SUPER + SPACE` | Application Launcher | `hyprlauncher` |
| `SUPER + B` | Web Browser | `helium-browser` |
| `SUPER + F` | File Manager | `nautilus` |
| `SUPER + O` | Notes / Knowledge Base | `obsidian` |

### Standalone Web Apps (Chromium App Mode)
Pressing these shortcuts opens dedicated, borderless web application windows:
* `SUPER + SHIFT + E` $\rightarrow$ Gmail (`https://mail.google.com`)
* `SUPER + SHIFT + C` $\rightarrow$ ChatGPT (`https://chatgpt.com`)
* `SUPER + SHIFT + Y` $\rightarrow$ YouTube Subscriptions (`https://www.youtube.com/feed/subscriptions`)
* `SUPER + SHIFT + W` $\rightarrow$ WhatsApp Web (`https://web.whatsapp.com`)
* `SUPER + SHIFT + V` $\rightarrow$ Google Meet (`https://meet.google.com/svo-phmi-mrf`)
* `SUPER + SHIFT + T` $\rightarrow$ Brototype (`https://student.brototype.com/`)
* `SUPER + SHIFT + S` $\rightarrow$ Spotify Web (`https://open.spotify.com/` - opens via **Brave**)
* `SUPER + SHIFT + I` $\rightarrow$ Instagram (`https://instagram.com/` - opens via **Brave**)

### Window Management & Directional Navigation
| Keybinding | Action |
| :--- | :--- |
| `SUPER + D` | Close focused window (`hl.dsp.window.close()`) |
| `SUPER + V` | Toggle window floating mode (`hl.dsp.window.float()`) |
| `SUPER + P` | Toggle layout split orientation (`hl.dsp.layout("togglesplit")`) |
| `SUPER + SHIFT + P` | Pseudo-tile focused window |
| `SUPER + J` / `L` / `I` / `K` | Focus window **Left** / **Right** / **Up** / **Down** |
| `SUPER + T` | Next workspace on current monitor |
| `SUPER + R` | Previous workspace on current monitor |
| `SUPER + Tab` / `SUPER + SHIFT + Tab` | Cycle forward / backward through workspaces |
| `SUPER + [1-0]` | Switch to workspace (1–10 on laptop, 11–20 on HDMI) |
| `SUPER + SHIFT + [1-0]` | Move focused window to workspace (1–10 on laptop, 11–20 on HDMI) |
| `SUPER + U` / `SUPER + N` | Send keyboard Up / Down to scroll active window content |

### Mouse Controls
| Input Action | Result |
| :--- | :--- |
| `SUPER + Left Click Drag` (`mouse:272`) | **Drag / Move** floating or tiled window |
| `SUPER + Right Click Drag` (`mouse:273`) | **Resize** active window |
| `SUPER + Scroll Up / Down` (alone) | Cycle workspaces on current monitor |
| `SUPER + Z + Scroll Up / Down` | Increase / Decrease Audio Volume (5% increments via `wpctl`) |
| `SUPER + X + Scroll Up / Down` | Increase / Decrease Screen Brightness (5% increments via `brightnessctl`) |

> **Note on `SUPER + Z` and `SUPER + X`**:  
> Both keys are captured in Hyprland with `bind("Z", hl.dsp.no_op())` and `bind("X", hl.dsp.no_op())` so holding them as mouse modifiers does not leak keystrokes into focused applications.

### Hardware & Media Keys
* `XF86AudioRaiseVolume` / `LowerVolume`: Volume +/- 5% (`wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+/-`)
* `XF86AudioMute` / `MicMute`: Toggle speaker / microphone mute (`wpctl set-mute`)
* `XF86MonBrightnessUp` / `Down`: Backlight +/- 5% (`brightnessctl set 5%+/-`)
* `XF86AudioPlay` / `Pause` / `Next` / `Prev`: Media control via `playerctl`
* `Print`: Fullscreen capture (`hyprshot -m output`)
* `SUPER + Print`: Area/region screenshot (`hyprshot -m region`)
* `SUPER + SHIFT + Print`: Active window screenshot (`hyprshot -m window`)

---

## 5. Waybar Peek & Hardware Event Watcher Architecture

To achieve macOS/GNOME-style **"hold keys to peek the status bar, release to hide"** without screen flicker or input lag, this setup uses a coordinated two-tier architecture:

```
[Key Press: SUPER + SHIFT]
          │
          ▼
   Hyprland Lua
   bind("SHIFT_L", peek.sh show)
          │
          ▼
   peek.sh show  ──────► Sends SIGUSR1 to reveal Waybar
          │
          ▼
   peek_watcher.py (Daemon)
          │
          ├─► Dynamically finds all keyboard nodes (/proc/bus/input/devices)
          ├─► Reads hardware key state directly via Linux evdev ioctl (EVIOCGKEY)
          ├─► Loops while both SUPER (125/126) and SHIFT/ALT (42/54/56/100) are down
          │
          ▼ [On Key Release]
   peek.sh hide  ──────► Sends SIGUSR1 to hide Waybar cleanly
```

### Key Highlights of the Watcher
1. **Zero Device Hardcoding**: Discovers all attached keyboards dynamically (laptop keyboard, wireless receiver, external BY Tech Hydra 10, etc.). It never breaks when `/dev/input/eventX` numbers change.
2. **Lock-File Pinning**: When `SUPER + SHIFT + SPACE` is pressed to permanently pin Waybar, `LOCK_FILE` (`/run/user/<uid>/waybar_pinned`) is created. The watcher detects this and skips hiding.

---

## 6. Theming & Animation Engine

* **Dynamic Colors**: [`appearance.lua`](file:///home/safvan/.config/hypr/appearance.lua) loads [`colors.lua`](file:///home/safvan/.config/hypr/colors.lua), which is dynamically generated from wallpaper palettes by Matugen. If `colors.lua` is absent, it seamlessly falls back to a curated Tokyo Night palette.
* **Spring & Bezier Physics**:
  * Window openings and popins utilize an analytical physical spring (`mass = 1`, `stiffness = 238.12`, `dampening = 24.21`).
  * Workspace changes utilize a fast `almostLinear` fade curve (`speed = 1.94`) for seamless, jitter-free monitor navigation.
  * Window borders feature dynamic 45-degree dual-color gradient rotation between `colors.primary` and `colors.secondary`.

---

## 7. Key Availability Cheat Sheet

When planning or adding new custom keybindings, consult this availability guide:

* **`SUPER + [A, O, Q]`**: **100% Free** for custom user applications or scripts.
* **`SUPER + CTRL + [any key]`**: **100% Free** (unused across the entire config).
* **`SUPER + ALT + [any key except S]`**: **100% Free** (`SUPER + ALT + S` is move-to-magic).
* **`SUPER + [Z, X]`**: **Reserved** as modifier keys for mouse wheel volume and brightness.

---

## 8. Developer & Modification Rules

When updating or extending this configuration, adhere to these guidelines:

1. **Never create duplicate bindings**:
   Hyprland executes all matching registered handlers. When adding conditional scroll or key handlers, consolidate them within a single callback instead of registering duplicate `mouse_up` / `mouse_down` entries.
2. **Reload gracefully**:
   Always test and apply changes using:
   ```bash
   hyprctl reload config-only
   ```
3. **Verify bindings via CLI**:
   Ensure binds registered correctly without collisions:
   ```bash
   hyprctl binds | grep -C 3 <key_or_event>
   ```
4. **Preserve modularity**:
   Keep programs in [`programs.lua`](file:///home/safvan/.config/hypr/programs.lua), appearance in [`appearance.lua`](file:///home/safvan/.config/hypr/appearance.lua), and key logic in [`keybindings.lua`](file:///home/safvan/.config/hypr/keybindings.lua). Never merge modules into a monolithic configuration file.
