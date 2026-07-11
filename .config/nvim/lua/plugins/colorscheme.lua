-- lua/plugins/colorscheme.lua
-- Sets Catppuccin Mocha as the active colorscheme.
-- Previously this file was entirely commented out, meaning LazyVim silently
-- fell back to its default (tokyonight) while the cursor colours in
-- options.lua/autocmds.lua were hardcoded for Catppuccin Mocha (#1e1e2e,
-- #89b4fa). That was a theme mismatch. This file fixes it.
return {
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        opts = {
            flavour = "mocha",
            transparent_background = true,
            custom_highlights = function(colors)
                return {
                    Normal = { bg = colors.none },
                    NormalNC = { bg = colors.none },
                    EndOfBuffer = { bg = colors.none },
                }
            end,
        },
    },
}
