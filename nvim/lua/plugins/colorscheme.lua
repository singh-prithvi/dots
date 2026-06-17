return {
    -- set colorscheme for LazyVim
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },

    -- install colorscheme
    -- make sure we load the wanted colorscheme during startup if it is your main colorscheme (by putting lazy = false)
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha",
            transparent_background = true,
        },
    },
    {
        "folke/tokyonight.nvim",
        lazy = true, -- don't load automatically
    },
}
