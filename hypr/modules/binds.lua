---------------------
---- KEYBINDINGS ----
---------------------

local terminal = "kitty"
local fileManager = "dolphin"
local browser = "firefox"
local codeEditor = "code"

--## Apps & Launchers
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal), { description = "App: Terminal" })
hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager), { description = "App: File manager" })
hl.bind("SUPER + W", hl.dsp.exec_cmd(browser), { description = "App: Browser" })
hl.bind("SUPER + C", hl.dsp.exec_cmd(codeEditor), { description = "App: Code editor" })

-- Quickshell Launcher toggle
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("qs ipc call launcher toggle"), { release = true, description = "Shell: App Launcher" })
hl.bind("SUPER + SUPER_R", hl.dsp.exec_cmd("qs ipc call launcher toggle"), { release = true })

-- Keybindings Cheatsheet overlay toggle
hl.bind("SUPER + Slash", hl.dsp.exec_cmd("qs ipc call cheatsheet toggle"), { description = "Shell: Toggle keybinds overlay" })
hl.bind("SUPER + question", hl.dsp.exec_cmd("qs ipc call cheatsheet toggle"))
hl.bind("SUPER + F1", hl.dsp.exec_cmd("qs ipc call cheatsheet toggle"), { description = "Shell: Toggle keybinds overlay" })

--## Window Management
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Window: Close" })
hl.bind("SUPER + ALT + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Float/Tile" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Window: Fullscreen" })
hl.bind("SUPER + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Window: Maximize" })
hl.bind("SUPER + P", hl.dsp.window.pin(), { description = "Window: Pin" })

-- Mouse drag & resize
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Move" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize" })

-- Focus window in direction
local dirs = { "Left", "Right", "Up", "Down" }
local d_short = { "l", "r", "u", "d" }
for i = 1, 4 do
    hl.bind("SUPER + " .. dirs[i], hl.dsp.focus({ direction = d_short[i] }), { description = "Window: Focus " .. dirs[i] })
    hl.bind("SUPER + SHIFT + " .. dirs[i], hl.dsp.window.move({ direction = d_short[i] }), { description = "Window: Move " .. dirs[i] })
end

-- Workspace switching with SUPER + CTRL + Arrows
hl.bind("SUPER + CTRL + Left", hl.dsp.focus({ workspace = "r-1" }), { description = "Workspace: Previous" })
hl.bind("SUPER + CTRL + Right", hl.dsp.focus({ workspace = "r+1" }), { description = "Workspace: Next" })
hl.bind("SUPER + CTRL + Down", hl.dsp.focus({ workspace = "r-1" }), { description = "Workspace: Previous" })
hl.bind("SUPER + CTRL + Up", hl.dsp.focus({ workspace = "r+1" }), { description = "Workspace: Next" })
hl.bind("CTRL + SUPER + Left", hl.dsp.focus({ workspace = "r-1" }))
hl.bind("CTRL + SUPER + Right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + SUPER + Down", hl.dsp.focus({ workspace = "r-1" }))
hl.bind("CTRL + SUPER + Up", hl.dsp.focus({ workspace = "r+1" }))

-- Move focused window between workspaces with SUPER + CTRL + SHIFT + Arrows
hl.bind("SUPER + CTRL + SHIFT + Left", hl.dsp.window.move({ workspace = "r-1" }), { description = "Workspace: Move window to previous" })
hl.bind("SUPER + CTRL + SHIFT + Right", hl.dsp.window.move({ workspace = "r+1" }), { description = "Workspace: Move window to next" })
hl.bind("SUPER + CTRL + SHIFT + Down", hl.dsp.window.move({ workspace = "r-1" }), { description = "Workspace: Move window to previous" })
hl.bind("SUPER + CTRL + SHIFT + Up", hl.dsp.window.move({ workspace = "r+1" }), { description = "Workspace: Move window to next" })

--## Workspaces (1..10)
for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }), { description = "Workspace: Focus " .. i })
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Workspace: Move window to " .. i })
end

-- Code numbers fallback for different layouts
local num_codes = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
for i = 1, 10 do
    hl.bind("SUPER + code:" .. num_codes[i], hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + code:" .. num_codes[i], hl.dsp.window.move({ workspace = i }))
end

-- Workspace cycle & scratchpad
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "r+1" }), { description = "Workspace: Next" })
hl.bind("SUPER + SHIFT + Tab", hl.dsp.focus({ workspace = "r-1" }), { description = "Workspace: Prev" })
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("special"), { description = "Workspace: Toggle scratchpad" })

--## Utilities & Switcher
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/desktop-switch"), { description = "Rice: Switch desktop profile" })
hl.bind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel || cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"), { description = "Utilities: Clipboard history" })
hl.bind("SUPER + Period", hl.dsp.exec_cmd("qs ipc call launcher toggleEmoji || fuzzel-emoji"), { description = "Utilities: Emoji picker" })
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"), { description = "Utilities: Screenshot region" })
hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"), { description = "Utilities: Screenshot full screen" })
hl.bind("CTRL + SUPER + T", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"), { description = "Shell: Wallpaper manager" })
hl.bind("CTRL + SUPER + ALT + T", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/set-wallpaper.sh --random"), { description = "Shell: Random wallpaper" })
hl.bind("SUPER + A", hl.dsp.exec_cmd("qs ipc call controlcenter toggle"), { description = "Shell: Ovládací centrum (Quick Settings)" })
hl.bind("CTRL + SUPER + R", hl.dsp.exec_cmd("killall qs quickshell; qs &"), { description = "Shell: Restart Quickshell" })

--## Media & Hardware
local osdScript = os.getenv("HOME") .. "/.config/hypr/scripts/osd.sh"
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(osdScript .. " --vol-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osdScript .. " --vol-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(osdScript .. " --vol-mute"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(osdScript .. " --bright-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osdScript .. " --bright-down"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Lock & Sleep
hl.bind("SUPER + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"), { description = "Session: Lock" })
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("loginctl lock-session && systemctl suspend"), { locked = true, description = "Session: Suspend" })
