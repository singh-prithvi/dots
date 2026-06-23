return {
    {
        "sphamba/smear-cursor.nvim",
        event = "VeryLazy",
        opts = function()
            -- 🔁 CHANGE THIS NUMBER (1–6) to switch cursor style
            local style = 5

            local styles = {
                -- 1️⃣ Smooth (default)
                [1] = {
                    stiffness = 0.6,
                    trailing_stiffness = 0.45,
                    damping = 0.85,
                },

                -- 2️⃣ Fast / Snappy
                [2] = {
                    stiffness = 0.9,
                    trailing_stiffness = 0.7,
                    damping = 0.95,
                },

                -- 3️⃣ Elastic / Bouncy
                [3] = {
                    stiffness = 0.5,
                    trailing_stiffness = 0.3,
                    damping = 0.65,
                },

                -- 4️⃣ Minimal
                [4] = {
                    trailing_stiffness = 0.5,
                    matrix_pixel_threshold = 0.5,
                },

                -- 5️⃣ Fire 🔥
                [5] = {
                    stiffness = 0.55,
                    trailing_stiffness = 0.25,
                    damping = 0.7,

                    time_interval = 8,

                    cursor_color = "#ff5a00",

                    particles_enabled = true,
                    particles_per_second = 120,
                    particle_spread = 1,
                    particle_lifetime = 140,

                    trailing_exponent = 1.2,
                    gamma = 1.3,

                    distance_stop_animating = 0.3,
                },

                -- 6️⃣ Flash ⚡
                [6] = {
                    stiffness = 1,
                    trailing_stiffness = 0.95,
                    damping = 1,

                    time_interval = 8,

                    distance_stop_animating = 0.5,
                    trailing_exponent = 2.5,

                    cursor_color = "#00f7ff",

                    particles_enabled = true,
                    particles_per_second = 120,
                    particle_spread = 0.4,
                    particle_lifetime = 80,

                    gamma = 1,
                },

                -- [7] Deep Ocean 🌊
                [7] = {
                    stiffness = 0.72,
                    trailing_stiffness = 0.18,
                    damping = 0.82,

                    time_interval = 7,

                    cursor_color = "#4FD6FF",

                    particles_enabled = true,
                    particles_number = 140,
                    particles_spread = 0.22,
                    particle_lifetime = 180,

                    trailing_exponent = 1.05,
                    gamma = 1.6,

                    distance_stop_animating = 0.15,
                },

                -- [8] Neon Aqua ⚡🌊
                [8] = {
                    stiffness = 0.88,
                    trailing_stiffness = 0.45,
                    damping = 0.9,

                    time_interval = 6,

                    cursor_color = "#00FFF7",

                    particles_enabled = true,
                    particles_number = 170,
                    particles_spread = 0.18,
                    particle_lifetime = 120,

                    trailing_exponent = 1.7,
                    gamma = 1.8,

                    distance_stop_animating = 0.25,
                },

                -- [9] Rain Drop 💧
                [9] = {
                    stiffness = 0.58,
                    trailing_stiffness = 0.12,
                    damping = 0.75,

                    time_interval = 9,

                    cursor_color = "#89CFF0",

                    particles_enabled = true,
                    particles_number = 90,
                    particles_spread = 0.35,
                    particle_lifetime = 240,

                    trailing_exponent = 0.95,
                    gamma = 1.25,

                    distance_stop_animating = 0.08,
                },

                -- [10] Ice / Frost ❄️
                [10] = {
                    stiffness = 0.93,
                    trailing_stiffness = 0.52,
                    damping = 0.94,

                    time_interval = 5,

                    cursor_color = "#B8F3FF",

                    particles_enabled = true,
                    particles_number = 130,
                    particles_spread = 0.12,
                    particle_lifetime = 100,

                    trailing_exponent = 2.2,
                    gamma = 1.9,

                    distance_stop_animating = 0.3,
                },

                -- [11] Jelly / Liquid Goo 🫧
                [11] = {
                    stiffness = 0.48,
                    trailing_stiffness = 0.08,
                    damping = 0.68,

                    time_interval = 10,

                    cursor_color = "#3ABEFF",

                    particles_enabled = true,
                    particles_number = 160,
                    particles_spread = 0.42,
                    particle_lifetime = 260,

                    trailing_exponent = 0.82,
                    gamma = 1.1,

                    distance_stop_animating = 0.04,
                },

                -- [12] Tsunami 🌊⚡
                [12] = {
                    stiffness = 1,
                    trailing_stiffness = 0.65,
                    damping = 0.96,

                    time_interval = 4,

                    cursor_color = "#009DFF",

                    particles_enabled = true,
                    particles_number = 220,
                    particles_spread = 0.28,
                    particle_lifetime = 140,

                    trailing_exponent = 2.8,
                    gamma = 2,

                    distance_stop_animating = 0.45,
                },
            }

            local base = {
                cursor_color = "#89b4fa",
                smear_between_buffers = true,
                smear_between_neighbor_lines = true,
                smear_insert_mode = true,
            }

            return vim.tbl_deep_extend("force", base, styles[style])
        end,
    },
}
