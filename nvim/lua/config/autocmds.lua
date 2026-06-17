-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Group prevents duplicate autocmds if this file is ever re-sourced
local number_group = vim.api.nvim_create_augroup("user_number_toggle", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", {
    group = number_group,
    callback = function()
        vim.wo.relativenumber = false
        vim.wo.number = true
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    group = number_group,
    callback = function()
        vim.wo.relativenumber = true
        vim.wo.number = true
    end,
})

-- Per-filetype indentation overrides
-- C/C++ explicitly set to 8-space tabs to match Linux kernel style.
-- This FileType autocmd is intentional even though the global default in
-- options.lua is already 8 — it guards against future global changes and
-- ensures these filetypes always get this specific width regardless.
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function()
        vim.opt_local.shiftwidth = 8
        vim.opt_local.tabstop = 8
        vim.opt_local.softtabstop = 8
    end,
})
