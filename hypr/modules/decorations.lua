---------------------
---- DECORATIONS ----
---------------------

hl.config({
    decoration = {
        rounding = 14,
        active_opacity = 0.96,
        inactive_opacity = 0.90,
        fullscreen_opacity = 1.0,

        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            new_optimizations = true,
            xray = false,
            ignore_opacity = true,
        },

        shadow = {
            enabled = true,
            range = 20,
            render_power = 2,
            color = "rgba(00000044)",
        },
    },
})
