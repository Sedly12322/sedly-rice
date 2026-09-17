-----------------
---- GENERAL ----
-----------------

hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = 12,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(bfc2ffee)", "rgba(c5c4ddee)" }, angle = 45 },
            inactive_border = "rgba(44455988)",
        },
        layout = "dwindle",
        resize_on_border = true,
        allow_tearing = false,
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        vrr = 1,
    },
})
