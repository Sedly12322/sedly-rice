---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us,cz",
        kb_variant = ",",
        kb_model   = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0.3,

        touchpad = {
            natural_scroll = true,
            scroll_factor  = 0.4,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})
hl.gesture({
    fingers = 4,
    direction = "horizontal",
    action = "workspace",
})
