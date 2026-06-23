-- lua/plugins/colorscheme.lua
-- Sets Catppuccin Mocha as the active colorscheme.
-- Previously this file was entirely commented out, meaning LazyVim silently
-- fell back to its default (tokyonight) while the cursor colours in
-- options.lua/autocmds.lua were hardcoded for Catppuccin Mocha (#1e1e2e,
-- #89b4fa). That was a theme mismatch. This file fixes it.
return {
    -- Tell LazyVim to use catppuccin instead of its default (tokyonight)
    {
        "LazyVim/LazyVim",
        opts = { colorscheme = "catppuccin" },
    },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,     -- load at startup
        priority = 1000,  -- load before all other plugins
        opts = {
            flavour = "mocha",
            transparent_background = true,
        },
    },
}
