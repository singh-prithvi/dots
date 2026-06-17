return {
    {
        "folke/snacks.nvim",
        opts = function(_, opts)
            local lines = require("config.quotes")

            math.randomseed(vim.uv.hrtime())
            local line = lines[math.random(#lines)]

            opts.dashboard = vim.tbl_deep_extend("force", opts.dashboard or {}, {
                preset = {
                    header = [[
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
                    ]],
                },

                sections = {
                    { section = "header" },
                    { section = "keys", gap = 1, padding = 1 },
                    { text = line, align = "center" },
                    { gap = 1 },
                    { section = "startup", align = "center" },
                },
            })

            return opts
        end,
    },
}
