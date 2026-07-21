-- lua/config/keymaps/runner.lua
-- F5 multi-language runner: C++, Python, Rust, Java.
-- Shares all C++ build-resolution logic with debugging.lua via config.utils.
local utils = require("config.utils")

-- ─── Terminal management ───────────────────────────────────────────────────
-- vim.g.cpp_term_buf / vim.g.cpp_term_win track the persistent split terminal.
-- No explicit VimEnter initialisation needed — globals default to nil.

local function create_term()
    vim.cmd("botright split | resize 12 | terminal")
    vim.g.cpp_term_buf = vim.api.nvim_get_current_buf()
    vim.g.cpp_term_win = vim.api.nvim_get_current_win()
end

-- ─── C++ build-command builder ────────────────────────────────────────────
-- Tier logic (Makefile → CMake → single-file) lives in config.utils and is
-- shared with debugging.lua. This function only decides what *shell command*
-- to send to the terminal for each tier.

local function cpp_command(abs_file)
    local dir = vim.fn.fnamemodify(abs_file, ":h")

    -- Tier 1: Makefile
    local make_root = utils.find_build_root(dir, "Makefile")
    if make_root then
        local root_q = vim.fn.shellescape(make_root)
        local suffix = utils.makefile_has_run_target(make_root) and " && make run" or ""
        return "cd " .. root_q .. " && make" .. suffix
    end

    -- Tier 2: CMakeLists.txt
    local cmake_root = utils.find_build_root(dir, "CMakeLists.txt")
    if cmake_root then
        local root_q = vim.fn.shellescape(cmake_root)
        local build_cmd = "cd "
            .. root_q
            .. " && cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug -Wno-dev"
            .. " && cmake --build build"
        local exe = utils.cmake_executable(cmake_root)
        if exe then
            return build_cmd .. " && " .. vim.fn.shellescape(cmake_root .. "/build/" .. exe)
        end
        return build_cmd
    end

    -- Tier 3: single-file (+ companion sources that don't have their own main)
    local sources, out = utils.cpp_single_file_sources(abs_file)
    local escaped = {}
    for _, src in ipairs(sources) do
        table.insert(escaped, vim.fn.shellescape(src))
    end

    return "g++ -std=c++20 -g -Wall -Wextra "
        .. table.concat(escaped, " ")
        .. " -o "
        .. vim.fn.shellescape(out)
        .. " && "
        .. vim.fn.shellescape(out)
end

-- ─── Java build-command builder ───────────────────────────────────────────
-- Tier 1: Maven project. Tier 2: Gradle project. Tier 3: single file, using
-- the Java 11+ source-code launcher (`java Foo.java`), which compiles and
-- runs in one step — no explicit javac invocation needed.

local function java_command(abs_file, dir)
    -- Tier 1: Maven
    local maven_root = utils.find_project_root(dir, "pom.xml")
    if maven_root then
        -- Requires exec-maven-plugin with a mainClass configured in the pom;
        -- otherwise mvn will prompt for -Dexec.mainClass=...
        return "cd " .. vim.fn.shellescape(maven_root) .. " && mvn -q compile exec:java"
    end

    -- Tier 2: Gradle
    local gradle_root = utils.find_project_root(dir, "build.gradle") or utils.find_project_root(dir, "build.gradle.kts")
    if gradle_root then
        -- Requires the `application` plugin to provide the `run` task
        return "cd " .. vim.fn.shellescape(gradle_root) .. " && ./gradlew -q run"
    end

    -- Tier 3: single file
    return "java " .. vim.fn.shellescape(abs_file)
end

-- ─── Channel dispatcher ────────────────────────────────────────────────────

local function run_file_in_chan(chan, abs_file, ft)
    -- Clear terminal and print what we're running
    vim.fn.chansend(chan, "clear && printf '\\033[3J'\n")
    vim.fn.chansend(chan, "printf 'Running: %s\\n' " .. vim.fn.shellescape(abs_file) .. "\n")

    local dir = vim.fn.fnamemodify(abs_file, ":h")

    if ft == "cpp" then
        vim.fn.chansend(chan, cpp_command(abs_file) .. "\n")
    elseif ft == "python" then
        vim.fn.chansend(chan, "python3 " .. vim.fn.shellescape(abs_file) .. "\n")
    elseif ft == "java" then
        vim.fn.chansend(chan, java_command(abs_file, dir) .. "\n")
    elseif ft == "rust" then
        local cargo_root = utils.find_project_root(dir, "Cargo.toml")
        if cargo_root then
            vim.fn.chansend(chan, "cd " .. vim.fn.shellescape(cargo_root) .. " && cargo run\n")
        else
            -- No Cargo project — compile the single file with rustc
            local stem = vim.fn.fnamemodify(abs_file, ":t:r")
            local dir_hash = vim.fn.sha256(dir):sub(1, 6)
            local out = vim.fn.expand("~/temp/") .. stem .. "_" .. dir_hash
            vim.fn.mkdir(vim.fn.expand("~/temp"), "p")
            vim.fn.chansend(
                chan,
                "rustc "
                    .. vim.fn.shellescape(abs_file)
                    .. " -o "
                    .. vim.fn.shellescape(out)
                    .. " && "
                    .. vim.fn.shellescape(out)
                    .. "\n"
            )
        end
    end
end

-- ─── F5: Run current file ──────────────────────────────────────────────────
vim.keymap.set({ "n", "i", "t" }, "<F5>", function()
    -- If called from terminal window, switch back to code first
    if vim.bo.buftype == "terminal" then
        vim.cmd("wincmd p")
    end

    local ft = vim.bo.filetype
    if ft ~= "cpp" and ft ~= "python" and ft ~= "rust" and ft ~= "java" then
        return
    end

    vim.cmd("write")
    local abs_file = vim.fn.expand("%:p")

    local win = vim.g.cpp_term_win
    if not (win and vim.api.nvim_win_is_valid(win)) then
        create_term()
    else
        vim.api.nvim_set_current_win(win)
    end

    local chan = vim.b[vim.g.cpp_term_buf].terminal_job_id
    if chan then
        -- Send Ctrl-C to interrupt any running process, then wait a tick
        vim.fn.chansend(chan, "\003")
        vim.defer_fn(function()
            local new_chan = vim.b[vim.g.cpp_term_buf].terminal_job_id
            if new_chan and vim.fn.jobwait({ new_chan }, 0)[1] == -1 then
                run_file_in_chan(new_chan, abs_file, ft)
            else
                -- Terminal died; recreate it
                vim.cmd("bd! " .. vim.g.cpp_term_buf)
                create_term()
                local restart_chan = vim.b[vim.g.cpp_term_buf].terminal_job_id
                if restart_chan then
                    run_file_in_chan(restart_chan, abs_file, ft)
                end
            end
        end, 100)
    else
        -- Terminal just opened; give it a moment to initialise
        vim.defer_fn(function()
            local new_chan = vim.b[vim.g.cpp_term_buf].terminal_job_id
            if new_chan then
                run_file_in_chan(new_chan, abs_file, ft)
            end
        end, 150)
    end

    vim.cmd("wincmd p") -- return focus to source file
end, { desc = "Run current file (C++ / Python / Rust / Java)" })
