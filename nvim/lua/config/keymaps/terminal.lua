vim.keymap.set({ "n", "i", "t" }, "<leader>k", function()
    if vim.bo.buftype == "terminal" then
        vim.cmd("wincmd p")
        return
    end

    local win = vim.g.cpp_term_win

    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
    else
        vim.notify("No terminal open — press F5 first.", vim.log.levels.WARN)
    end
end, { desc = "Toggle code/terminal focus" })
