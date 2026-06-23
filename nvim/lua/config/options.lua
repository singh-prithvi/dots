-- lua/config/options.lua
-- Loaded automatically by LazyVim before lazy.nvim starts.
-- Keep this file to pure option-setting; autocmds live in autocmds.lua.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Always show the tabline (bufferline needs it)
vim.opt.showtabline = 2

-- 8-space indentation with space expansion.
-- Note: the Linux kernel itself uses real tab characters (expandtab=false).
-- If you want true kernel style, flip expandtab to false here and in autocmds.lua.
vim.opt.tabstop = 8
vim.opt.shiftwidth = 8
vim.opt.softtabstop = 8
vim.opt.expandtab = true

-- Cursor shape per mode (colours applied in autocmds.lua via ColorScheme)
vim.opt.guicursor = {
    "n-v-c:block-Cursor",
    "i-ci:ver25-Cursor",
    "r-cr:hor20-Cursor",
}

-- Short enough that jk → Esc feels instant; LazyVim default is 300
vim.opt.timeoutlen = 200
