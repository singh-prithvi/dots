-- lua/plugins/lint.lua
-- clangd's --clang-tidy is intentionally omitted in lsp.lua; C/C++ linting
-- is handled here, asynchronously, via nvim-lint + clang-tidy.
--
-- PREVIOUS BUG: linters_by_ft was configured but nothing ever called
-- lint.try_lint(), so clang-tidy never actually ran — the plugin loaded
-- (eagerly, since it had no lazy-load trigger either) and did nothing.
-- Fixed below: ft-gated lazy load, plus the autocmd that actually lints.
return {
    "mfussenegger/nvim-lint",
    ft = { "c", "cpp" },
    opts = {
        linters_by_ft = {
            cpp = { "clangtidy" },
            c = { "clangtidy" },
        },
    },
    config = function(_, opts)
        local lint = require("lint")
        lint.linters_by_ft = opts.linters_by_ft

        vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
            group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
            pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
