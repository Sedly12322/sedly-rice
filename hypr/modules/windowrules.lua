----------------------
---- WINDOW RULES ----
----------------------

-- Audio / System settings dialogs
hl.window_rule({ match = { class = "pavucontrol" }, float = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })
hl.window_rule({ match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ match = { class = "blueman-manager" }, float = true })

-- File dialogues & portals
hl.window_rule({ match = { title = "Open File" }, float = true })
hl.window_rule({ match = { title = "Save File" }, float = true })
hl.window_rule({ match = { title = "^(Confirm to replace files)$" }, float = true })
hl.window_rule({ match = { title = "^(File Operation Progress)$" }, float = true })
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true })
hl.window_rule({ match = { class = "hyprpolkitagent" }, float = true })
hl.window_rule({ match = { title = "^(Copying — Dolphin)$" }, float = true, move = { 40, 80 } })

-- Picture-in-Picture (Firefox, Chromium)
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true, pin = true })
hl.window_rule({ match = { title = "^(Picture in picture)$" }, float = true, pin = true })

-- Video players
hl.window_rule({ match = { class = "mpv" }, float = true })

-- Opacity rules
hl.window_rule({ match = { class = "kitty" }, opacity = 0.94 })
hl.window_rule({ match = { class = "Code" }, opacity = 0.96 })
