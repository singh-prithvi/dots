-- Miscellaneous keymaps

-- ─── Buffer navigation (Alt+H/L — fast left/right without leader) ─────────────
vim.keymap.set("n", "<A-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<A-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- ─── Clear search highlight on Escape ─────────────────────────────────────────
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { silent = true })

-- ─── Move lines up/down in visual mode ────────────────────────────────────────
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ─── Keep cursor centred when jumping ─────────────────────────────────────────
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- ─── Paste without overwriting register ───────────────────────────────────────
-- In visual mode, pasting replaces the selected text but keeps original in register
vim.keymap.set("v", "<leader>p", '"_dP', { desc = "Paste without yanking selection" })

-- ─── Yank to system clipboard ─────────────────────────────────────────────────
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })

-- ─── Highlight code for visual─────────────────────────────────────────────────
