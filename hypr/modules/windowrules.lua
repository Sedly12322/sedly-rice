----------------------
---- WINDOW RULES ----
----------------------

hl.window_rule({ match = { class = "pavucontrol" }, float = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })
hl.window_rule({ match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ match = { class = "blueman-manager" }, float = true })
hl.window_rule({ match = { title = "Open File" }, float = true })
hl.window_rule({ match = { title = "Save File" }, float = true })
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true })
hl.window_rule({ match = { class = "hyprpolkitagent" }, float = true })

-- Opacity rules
hl.window_rule({ match = { class = "kitty" }, opacity = 0.94 })
hl.window_rule({ match = { class = "Code" }, opacity = 0.96 })
