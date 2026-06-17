-- Ctrl-L pair skip
vim.keymap.set("i", "<C-l>", function()
    local col = vim.fn.col(".")
    local line = vim.api.nvim_get_current_line()

    -- for (), [], {}, <>, "", '', ;
    if line:sub(col, col):match("[%)%}%]%>\"';]") then
        return "<Right>"
    end

    return "<C-l>"
end, { expr = true, silent = true, desc = "Jump past closing pair" })

-- jk escape
vim.keymap.set("i", "jk", function()
    local col = vim.fn.col(".") - 1
    local line = vim.fn.getline(".")

    if col > 0 then
        local prev_char = line:sub(col, col)

        if prev_char:match("%a") then
            return "jk"
        end
    end

    return "<Esc>"
end, { expr = true, noremap = true, silent = true })

-- Ctrl Backspace
vim.keymap.set("i", "<C-BS>", "<C-w>", { noremap = true })
