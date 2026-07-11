return {
    "azabiong/vim-highlighter",
    keys = {
        { "<leader>mh", desc = "Highlight word" },
        { "<leader>mr", desc = "Remove highlight" },
        { "<leader>mc", desc = "Clear all highlights" },
    },
    init = function()
        vim.g.HiSet = "<leader>mh"
        vim.g.HiErase = "<leader>mr"
        vim.g.HiClear = "<leader>mc"
    end,
}
