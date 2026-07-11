-- lua/config/autocmds.lua
-- Loaded automatically by LazyVim on the VeryLazy event (after plugins and
-- colorscheme are already set up).
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- ─── Relative-number toggle on insert ─────────────────────────────────────
-- Switch to absolute line numbers while typing, back to relative on leave.
local number_group = vim.api.nvim_create_augroup("user_number_toggle", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", {
    group = number_group,
    callback = function()
        vim.wo.relativenumber = false
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    group = number_group,
    callback = function()
        vim.wo.relativenumber = true
    end,
})

-- ─── Per-filetype indentation overrides ───────────────────────────────────
-- Pin C/C++ to 8-space indentation regardless of future global changes.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_indent", { clear = true }),
    pattern = { "c", "cpp" },
    callback = function()
        vim.opt_local.shiftwidth = 8
        vim.opt_local.tabstop = 8
        vim.opt_local.softtabstop = 8
    end,
})

-- ─── Theme overrides: transparency + Catppuccin Mocha cursor colour ───────
local function apply_theme_overrides()
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("user_theme_overrides", { clear = true }),
    callback = apply_theme_overrides,
})

apply_theme_overrides()
