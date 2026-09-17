-----------------
---- GENERAL ----
-----------------

hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = 12,
        border_size = 2,
        ["col.active_border"] = "rgba(bfc2ffee) rgba(c5c4ddee) 45deg",
        ["col.inactive_border"] = "rgba(44455988)",
        layout = "dwindle",
        resize_on_border = true,
    },
    dwindle = {
        pseudotile = true,
        preserve_split = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        vrr = 1,
    },
})
