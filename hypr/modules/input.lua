---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us,cz",
        kb_variant = ",",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity  = 0.3,
        touchpad = {
            natural_scroll = true,
            scroll_factor  = 0.4,
        },
    },
    gestures = {
        workspace_swipe = true,
        workspace_swipe_fingers = 3,
        workspace_swipe_distance = 250,
    },
})
