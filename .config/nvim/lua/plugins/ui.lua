return {
    {
        "sphamba/smear-cursor.nvim",
        event = "VeryLazy",
        opts = function()
            -- 🔀 SWITCH: choose manual vs automatic battery-based style selection
            --   true  -> automatically detect AC/battery and pick style 5 or 13
            --   false -> always use `manual_style` below, ignoring power state
            local use_battery_detection = false

            -- 🔁 Used only when use_battery_detection = false.
            -- CHANGE THIS NUMBER (1–13) to switch cursor style manually.
            local manual_style = 5

            -- 🔋 Detect AC vs battery power by scanning /sys/class/power_supply
            -- for the supply whose `type` is "Mains", rather than assuming
            -- fixed names like AC / AC0 / ADP0.
            -- Returns style 5 (Fire) when on AC/charging, 13 (Invisible) on battery.
            -- Defaults to 5 if detection fails for any reason.
            local function detect_power_style()
                local success, result = pcall(function()
                    local base = "/sys/class/power_supply"
                    local entries = vim.fn.readdir(base)
                    if not entries or #entries == 0 then
                        error("no power supply entries found")
                    end

                    for _, entry in ipairs(entries) do
                        local type_path = base .. "/" .. entry .. "/type"
                        local f = io.open(type_path, "r")
                        if f then
                            local content = f:read("*l")
                            f:close()
                            if content then
                                content = content:gsub("%s+", "")
                            end
                            if content == "Mains" then
                                local online_path = base .. "/" .. entry .. "/online"
                                local of = io.open(online_path, "r")
                                if of then
                                    local online = of:read("*l")
                                    of:close()
                                    if online then
                                        online = online:gsub("%s+", "")
                                        if online == "1" then
                                            return 5
                                        else
                                            return 13
                                        end
                                    end
                                end
                                error("Mains supply found but online status unreadable")
                            end
                        end
                    end

                    error("no Mains power supply found")
                end)

                if success and result then
                    return result
                else
                    -- Fallback: default to AC/charging behavior
                    return 5
                end
            end

            -- Final style resolution: automatic detection or manual override
            local style
            if use_battery_detection then
                style = detect_power_style()
            else
                style = manual_style
            end

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
                -- [13] Invisible / Native Cursor
                [13] = {
                    -- Instant movement
                    stiffness = 1.0,
                    trailing_stiffness = 1.0,
                    damping = 1.0,

                    -- No trail
                    trailing_exponent = 8,
                    distance_stop_animating = 100,

                    -- No particles
                    particles_enabled = false,

                    -- Match your cursor color (or omit this)
                    cursor_color = "#89b4fa",

                    -- Update less often
                    time_interval = 16,

                    -- Disable extra rendering
                    gamma = 1,
                    matrix_pixel_threshold = 1,
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
