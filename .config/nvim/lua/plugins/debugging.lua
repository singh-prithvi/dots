-- lua/plugins/debugging.lua
-- nvim-dap configuration for C/C++ and Rust via codelldb.
-- Lazy-loaded on first use of a debug keymap below, so dap/dapui/nvim-nio
-- never load just because Neovim started.
-- Build-resolution tier logic (Makefile → CMake → single-file) lives in
-- config.utils and is shared with runner.lua — see find_build_root et al.
return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
    },
    keys = {
        { "<Leader>dt", desc = "Toggle breakpoint" },
        { "<Leader>dc", desc = "Continue" },
        { "<Leader>dx", desc = "Terminate session" },
        { "<Leader>do", desc = "Step over" },
        { "<Leader>di", desc = "Step into" },
        { "<Leader>dO", desc = "Step out" },
        { "<F6>", desc = "Breakpoint + Start Debugging" },
    },
    config = function()
        local utils = require("config.utils")
        require("dapui").setup()
        local dap, dapui = require("dap"), require("dapui")

        -- ── C/C++ build cache ──────────────────────────────────────────────
        -- Cached per source-file so that nvim-dap evaluating `program` and
        -- `cwd` (in unspecified order) always sees the same decision, and the
        -- confirm prompts only ever fire once per file per debug session.
        --
        -- PREVIOUS BUG: the cache was keyed only on "did we resolve anything"
        -- (a single boolean/nil flag), so switching to a different .cpp file
        -- without pressing F6 again reused the previous file's binary. Fixed
        -- by keying the cache on the absolute file path.
        local cpp_cache = nil -- { file, cwd, program }

        local function resolve_cpp()
            local abs_file = vim.fn.expand("%:p")

            -- Return cache if we're on the same file
            if cpp_cache and cpp_cache.file == abs_file then
                return cpp_cache
            end

            local dir = vim.fn.fnamemodify(abs_file, ":h")
            local result = { file = abs_file, cwd = dir, program = nil }

            -- Tier 1: Makefile ─────────────────────────────────────────────
            local make_root = utils.find_build_root(dir, "Makefile")
            if make_root then
                result.cwd = make_root
                local target = utils.makefile_target(make_root)
                vim.notify("[dap] Building with make…", vim.log.levels.INFO)
                vim.fn.system("cd " .. vim.fn.shellescape(make_root) .. " && make")
                if vim.v.shell_error ~= 0 then
                    vim.notify("[dap] make failed", vim.log.levels.ERROR)
                else
                    result.program = target and (make_root .. "/" .. target)
                        or vim.fn.input("Executable: ", make_root .. "/", "file")
                end
                cpp_cache = result
                return result
            end

            -- Tier 2: CMakeLists.txt ───────────────────────────────────────
            local cmake_root = utils.find_build_root(dir, "CMakeLists.txt")
            if cmake_root then
                result.cwd = cmake_root
                vim.notify("[dap] Building with cmake…", vim.log.levels.INFO)
                vim.fn.system(
                    "cd "
                        .. vim.fn.shellescape(cmake_root)
                        .. " && cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug -Wno-dev"
                        .. " && cmake --build build"
                )
                if vim.v.shell_error ~= 0 then
                    vim.notify("[dap] cmake build failed", vim.log.levels.ERROR)
                else
                    local exe = utils.cmake_executable(cmake_root)
                    result.program = exe and (cmake_root .. "/build/" .. exe)
                        or vim.fn.input("Executable: ", cmake_root .. "/build/", "file")
                end
                cpp_cache = result
                return result
            end

            -- Tier 3: single-file + companion sources ─────────────────────
            local sources, out = utils.cpp_single_file_sources(abs_file)
            local escaped = {}
            for _, src in ipairs(sources) do
                table.insert(escaped, vim.fn.shellescape(src))
            end

            vim.notify("[dap] Compiling…", vim.log.levels.INFO)
            vim.fn.system("g++ -std=c++20 -g -Wall -Wextra " .. table.concat(escaped, " ") .. " -o " .. vim.fn.shellescape(out))
            if vim.v.shell_error ~= 0 then
                vim.notify("[dap] Compilation failed", vim.log.levels.ERROR)
            else
                result.program = out
            end

            cpp_cache = result
            return result
        end

        -- ── Rust build helper ──────────────────────────────────────────────
        local function rust_build()
            local dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
            local cargo_root = utils.find_project_root(dir, "Cargo.toml")
            if not cargo_root then
                vim.notify("[dap] No Cargo.toml found", vim.log.levels.ERROR)
                return nil
            end
            local name = vim.fn.trim(
                vim.fn.system(
                    "awk -F'\"' '/^name[[:space:]]*=/{print $2; exit}' "
                        .. vim.fn.shellescape(cargo_root .. "/Cargo.toml")
                )
            )
            if name == "" then
                vim.notify("[dap] Could not read crate name from Cargo.toml", vim.log.levels.ERROR)
                return nil
            end
            vim.notify("[dap] Building with cargo…", vim.log.levels.INFO)
            vim.fn.system("cd " .. vim.fn.shellescape(cargo_root) .. " && cargo build")
            if vim.v.shell_error ~= 0 then
                vim.notify("[dap] cargo build failed", vim.log.levels.ERROR)
                return nil
            end
            return cargo_root .. "/target/debug/" .. name
        end

        -- ── codelldb adapter ───────────────────────────────────────────────
        dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
                command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                args = { "--port", "${port}" },
            },
        }

        -- ── C / C++ launch config ──────────────────────────────────────────
        dap.configurations.cpp = {
            {
                name = "Launch",
                type = "codelldb",
                request = "launch",
                program = function()
                    return resolve_cpp().program
                end,
                cwd = function()
                    return resolve_cpp().cwd
                end,
                stopOnEntry = false,
            },
        }
        dap.configurations.c = dap.configurations.cpp

        -- ── Rust launch config ─────────────────────────────────────────────
        dap.configurations.rust = {
            {
                name = "Launch",
                type = "codelldb",
                request = "launch",
                program = rust_build,
                cwd = function()
                    local dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
                    return utils.find_project_root(dir, "Cargo.toml") or dir
                end,
                stopOnEntry = false,
            },
        }

        -- ── dap-ui: auto open on start, auto close on exit ─────────────────
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        -- ── Keymaps ────────────────────────────────────────────────────────
        local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { desc = desc })
        end
        map("<Leader>dt", "<cmd>DapToggleBreakpoint<CR>", "Toggle breakpoint")
        map("<Leader>dc", "<cmd>DapContinue<CR>",         "Continue")
        map("<Leader>dx", "<cmd>DapTerminate<CR>",         "Terminate session")
        map("<Leader>do", "<cmd>DapStepOver<CR>",          "Step over")
        map("<Leader>di", "<cmd>DapStepInto<CR>",          "Step into")
        map("<Leader>dO", "<cmd>DapStepOut<CR>",           "Step out")

        vim.keymap.set("n", "<F6>", function()
            cpp_cache = nil -- force fresh resolution for the current file
            dap.toggle_breakpoint()
            dap.continue()
        end, { desc = "Breakpoint + Start Debugging" })
    end,
}
