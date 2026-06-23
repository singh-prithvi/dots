-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.showtabline = 2 -- Always show tabline

vim.opt.tabstop = 8
vim.opt.shiftwidth = 8
vim.opt.softtabstop = 8
vim.opt.expandtab = true

-- Cursor shape per mode
vim.opt.guicursor = {
    "n-v-c:block-Cursor",
    "i-ci:ver25-Cursor",
    "r-cr:hor20-Cursor",
}

-- Re-apply the Cursor highlight every time a colorscheme loads,
-- because :colorscheme resets all highlights and would wipe this otherwise.
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("user_cursor_hl", { clear = true }),
    callback = function()
        vim.api.nvim_set_hl(0, "Cursor", { fg = "#1e1e2e", bg = "#89b4fa" })
    end,
})

vim.opt.timeoutlen = 200 -- Time (ms) to wait for mapped key sequences (jk → Esc)

vim.schedule(function()
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
end)
