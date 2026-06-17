return {
    "michaelb/sniprun",
    build = "sh install.sh",

    config = function()
        require("sniprun").setup({
            display = { "Classic" },
        })

        -- run current line / selection
        vim.keymap.set("n", "<leader>r", ":SnipRun<CR>", { desc = "SnipRun" })
        vim.keymap.set("v", "<leader>r", ":SnipRun<CR>", { desc = "SnipRun selection" })
    end,
}
