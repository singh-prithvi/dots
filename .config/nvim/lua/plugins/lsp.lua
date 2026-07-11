return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                clangd = {
                    -- --background-index: builds a persistent symbol index for fast completions.
                    -- Omit --clang-tidy here; linting is handled asynchronously by nvim-lint (lint.lua).
                    cmd = { "clangd", "--background-index" },
                },

                pyright = {},       -- Python LSP
                rust_analyzer = {}, -- Rust LSP (no extra opts needed; mason handles install)
            },
        },
    },

    {
        -- Mason installs LSP servers and DAP adapters into ~/.local/share/nvim/mason/
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "clangd",
                "pyright",
                "rust-analyzer",
                "codelldb", -- DAP adapter for C/C++ debugging (used by debugging.lua)
            },
        },
    },
}
