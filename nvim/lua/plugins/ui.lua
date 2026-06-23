-- lua/plugins/ui.lua
-- Previously this file defined 12 cursor-animation presets (216 lines) but
-- only style 5 ("fire") was ever active. The other 11 presets were dead code.
-- Only the active configuration remains below.
--
-- To switch styles: just change the values directly, or comment this block out
-- for a plain cursor. All available options are documented at:
-- https://github.com/sphamba/smear-cursor.nvim
return {
    {
        "sphamba/smear-cursor.nvim",
        event = "VeryLazy",
        opts = {
            -- Base colour: Catppuccin Mocha blue
            cursor_color = "#89b4fa",

            smear_between_buffers = true,
            smear_between_neighbor_lines = true,
            smear_insert_mode = true,

            -- 🔥 Fire style
            stiffness = 0.55,
            trailing_stiffness = 0.25,
            damping = 0.7,
            time_interval = 8,
            trailing_exponent = 1.2,
            gamma = 1.3,
            distance_stop_animating = 0.3,

            particles_enabled = true,
            particles_per_second = 120,
            particle_spread = 1,
            particle_lifetime = 140,
        },
    },
}
