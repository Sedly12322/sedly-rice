--------------------
---- ANIMATIONS ----
--------------------

hl.config({
    animations = {
        enabled = true,

        bezier = {
            { name = "md3_standard", cp1 = 0.2, cp2 = 0, cp3 = 0, cp4 = 1 },
            { name = "md3_decel",    cp1 = 0.05, cp2 = 0.7, cp3 = 0.1, cp4 = 1 },
            { name = "md3_accel",    cp1 = 0.3, cp2 = 0, cp3 = 0.8, cp4 = 0.15 },
            { name = "overshoot",    cp1 = 0.05, cp2 = 0.9, cp3 = 0.1, cp4 = 1.05 },
            { name = "hypr_standard",cp1 = 0.16, cp2 = 1, cp3 = 0.3, cp4 = 1 },
        },

        animation = {
            { name = "windows",     enable = 1, time = 4, bezier = "md3_decel", style = "popin 60%" },
            { name = "windowsIn",   enable = 1, time = 4, bezier = "md3_decel", style = "popin 70%" },
            { name = "windowsOut",  enable = 1, time = 3, bezier = "md3_accel", style = "popin 80%" },
            { name = "border",      enable = 1, time = 6, bezier = "md3_decel" },
            { name = "fade",        enable = 1, time = 3, bezier = "md3_decel" },
            { name = "workspaces",  enable = 1, time = 5, bezier = "hypr_standard", style = "slide" },
            { name = "specialWorkspace", enable = 1, time = 5, bezier = "md3_decel", style = "slidevert" },
            { name = "layers",      enable = 1, time = 4, bezier = "md3_decel", style = "popin" },
        },
    },
})
