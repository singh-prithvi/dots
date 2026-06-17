vim.keymap.set("n", "<leader>tc", function()
    local current_buf = vim.api.nvim_get_current_buf()
    local current_ft = vim.bo[current_buf].filetype

    if current_ft == "snacks_explorer" then
        vim.notify("Explorer can't be closed with this", vim.log.levels.WARN)
        return
    end

    local real_bufs = {}

    for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if vim.bo[buf.bufnr].filetype ~= "snacks_explorer" then
            table.insert(real_bufs, buf.bufnr)
        end
    end

    local tabs = vim.fn.tabpagenr("$")

    if #real_bufs == 1 and tabs == 1 then
        vim.cmd("confirm q")
        return
    end

    if #real_bufs > 1 then
        vim.cmd("bnext")
        vim.cmd("confirm bd " .. current_buf)
    else
        vim.cmd("enew")
    end
end, { desc = "Close buffer (smart)" })

for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", {
        desc = "Go to buffer " .. i,
    })
end
