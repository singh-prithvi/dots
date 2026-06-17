return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
    },
    config = function()
        require("dapui").setup()
        local dap, dapui = require("dap"), require("dapui")

        local function find_project_root(dir, marker)
            local current = dir
            while true do
                if vim.fn.filereadable(current .. "/" .. marker) == 1 then
                    return current
                end

                -- Stop at a git repo boundary
                if vim.fn.isdirectory(current .. "/.git") == 1 then
                    return nil
                end

                local parent = vim.fn.fnamemodify(current, ":h")
                if parent == current then
                    break
                end
                current = parent
            end
            return nil
        end

        -- Cached per-run resolution of {cwd, program} for the C/C++ launch
        -- config. Cached so that nvim-dap evaluating `program` and `cwd`
        -- (whose order is NOT guaranteed) always sees the same decision,
        -- and so the confirm prompt only ever fires once per run.
        local cpp_resolved = nil

        local function resolve_cpp()
            if cpp_resolved then
                return cpp_resolved
            end

            local abs_file = vim.fn.expand("%:p")
            local dir = vim.fn.fnamemodify(abs_file, ":h")
            local result = { cwd = dir, program = nil }

            -- ── Tier 1: Makefile ────────────────────────────────────────
            local make_root = find_project_root(dir, "Makefile")
            if make_root and make_root ~= dir then
                local choice = vim.fn.confirm(
                    "Found Makefile at " .. make_root .. " (not current dir). Build with it?",
                    "&No, compile single file\n&Yes",
                    1
                )
                if choice ~= 2 then
                    make_root = nil
                end
            end

            if make_root then
                result.cwd = make_root
                local mf_q = vim.fn.shellescape(make_root .. "/Makefile")
                local target = vim.fn.trim(
                    vim.fn.system(
                        "grep -E '^(TARGET|BINARY|EXE)[[:space:]]*[:?]?=' "
                            .. mf_q
                            .. " | head -1 | sed 's/.*=[[:space:]]*//' | awk '{print $1}'"
                    )
                )
                vim.notify("[dap] Building with make…", vim.log.levels.INFO)
                vim.fn.system("cd " .. vim.fn.shellescape(make_root) .. " && make")
                if vim.v.shell_error ~= 0 then
                    vim.notify("[dap] make failed", vim.log.levels.ERROR)
                    cpp_resolved = result
                    return result
                end
                if target ~= "" then
                    result.program = make_root .. "/" .. target
                else
                    result.program = vim.fn.input("Executable: ", make_root .. "/", "file")
                end
                cpp_resolved = result
                return result
            end

            -- ── Tier 2: CMakeLists.txt ──────────────────────────────────
            local cmake_root = find_project_root(dir, "CMakeLists.txt")
            if cmake_root and cmake_root ~= dir then
                local choice = vim.fn.confirm(
                    "Found CMakeLists.txt at " .. cmake_root .. " (not current dir). Build with it?",
                    "&No, compile single file\n&Yes",
                    1
                )
                if choice ~= 2 then
                    cmake_root = nil
                end
            end

            if cmake_root then
                result.cwd = cmake_root
                local exe = vim.fn.trim(
                    vim.fn.system(
                        "awk '/add_executable/{gsub(/[()]/,\" \"); print $2; exit}' "
                            .. vim.fn.shellescape(cmake_root .. "/CMakeLists.txt")
                    )
                )
                vim.notify("[dap] Building with cmake…", vim.log.levels.INFO)
                vim.fn.system(
                    "cd "
                        .. vim.fn.shellescape(cmake_root)
                        .. " && cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug -Wno-dev"
                        .. " && cmake --build build"
                )
                if vim.v.shell_error ~= 0 then
                    vim.notify("[dap] cmake build failed", vim.log.levels.ERROR)
                    cpp_resolved = result
                    return result
                end
                if exe ~= "" and not exe:match("^%$") then
                    result.program = cmake_root .. "/build/" .. exe
                else
                    result.program = vim.fn.input("Executable: ", cmake_root .. "/build/", "file")
                end
                cpp_resolved = result
                return result
            end

            -- ── Tier 3: single-file + companion sources ──────────────────
            result.cwd = dir
            local stem = vim.fn.fnamemodify(abs_file, ":t:r")
            local dir_hash = vim.fn.sha256(dir):sub(1, 6)
            local out = vim.fn.expand("~/temp/") .. stem .. "_" .. dir_hash
            vim.fn.mkdir(vim.fn.expand("~/temp"), "p")

            local sources = { vim.fn.shellescape(abs_file) }
            for _, sibling in ipairs(vim.fn.glob(dir .. "/*.cpp", false, true)) do
                if sibling ~= abs_file then
                    vim.fn.system(
                        "grep -qlE 'int[[:space:]]+main|auto[[:space:]]+main' " .. vim.fn.shellescape(sibling)
                    )
                    if vim.v.shell_error ~= 0 then
                        table.insert(sources, vim.fn.shellescape(sibling))
                    end
                end
            end

            vim.notify("[dap] Compiling…", vim.log.levels.INFO)
            vim.fn.system(
                "g++ -std=c++20 -g -Wall -Wextra " .. table.concat(sources, " ") .. " -o " .. vim.fn.shellescape(out)
            )
            if vim.v.shell_error ~= 0 then
                vim.notify("[dap] Compilation failed", vim.log.levels.ERROR)
            else
                result.program = out
            end

            cpp_resolved = result
            return result
        end

        -- Builds the Cargo project and returns the path to the debug binary, or nil.
        -- ${cargo:program} is not supported by nvim-dap core, so we build manually.
        local function rust_build()
            local dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
            local cargo_root = find_project_root(dir, "Cargo.toml")
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

        -- ── codelldb adapter ──────────────────────────────────────────────
        dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
                command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                args = { "--port", "${port}" },
            },
        }

        -- ── C / C++ ───────────────────────────────────────────────────────
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

        -- ── Rust ──────────────────────────────────────────────────────────
        dap.configurations.rust = {
            {
                name = "Launch",
                type = "codelldb",
                request = "launch",
                program = rust_build,
                cwd = function()
                    local dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
                    return find_project_root(dir, "Cargo.toml") or dir
                end,
                stopOnEntry = false,
            },
        }

        -- ── dap-ui auto open/close ────────────────────────────────────────
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

        -- ── Keymaps ───────────────────────────────────────────────────────
        vim.keymap.set("n", "<Leader>dt", ":DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint" })
        vim.keymap.set("n", "<Leader>dc", ":DapContinue<CR>", { desc = "Continue" })
        vim.keymap.set("n", "<Leader>dx", ":DapTerminate<CR>", { desc = "Terminate session" })
        vim.keymap.set("n", "<Leader>do", ":DapStepOver<CR>", { desc = "Step over" })
        vim.keymap.set("n", "<Leader>di", ":DapStepInto<CR>", { desc = "Step into" })
        vim.keymap.set("n", "<Leader>dO", ":DapStepOut<CR>", { desc = "Step out" })
        vim.keymap.set("n", "<F6>", function()
            cpp_resolved = nil -- force a fresh resolution every run
            dap.toggle_breakpoint()
            dap.continue()
        end, { desc = "Breakpoint + Start Debugging" })
    end,
}
