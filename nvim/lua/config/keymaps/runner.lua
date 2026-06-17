vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.g.cpp_term_buf = nil
        vim.g.cpp_term_win = nil
    end,
})

local function create_term()
    vim.cmd("botright split | resize 12 | terminal")
    vim.g.cpp_term_buf = vim.api.nvim_get_current_buf()
    vim.g.cpp_term_win = vim.api.nvim_get_current_win()
end

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

local function cpp_command(abs_file)
    local dir = vim.fn.fnamemodify(abs_file, ":h")

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
        local root_q = vim.fn.shellescape(make_root)
        vim.fn.system("grep -qE '^run[[:space:]]*:' " .. vim.fn.shellescape(make_root .. "/Makefile"))
        local suffix = vim.v.shell_error == 0 and " && make run" or ""
        return "cd " .. root_q .. " && make" .. suffix
    end

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
        local root_q = vim.fn.shellescape(cmake_root)
        local exe = vim.fn.trim(
            vim.fn.system(
                "awk '/add_executable/{gsub(/[()]/,\" \"); print $2; exit}' "
                    .. vim.fn.shellescape(cmake_root .. "/CMakeLists.txt")
            )
        )
        local build_cmd = "cd "
            .. root_q
            .. " && cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug -Wno-dev"
            .. " && cmake --build build"
        -- exe is unusable when it's a CMake variable like ${PROJECT_NAME}
        if exe ~= "" and not exe:match("^%$") then
            return build_cmd .. " && " .. vim.fn.shellescape(cmake_root .. "/build/" .. exe)
        end
        return build_cmd
    end

    local stem = vim.fn.fnamemodify(abs_file, ":t:r")
    -- Hash the directory so two projects with the same filename (e.g. main.cpp)
    -- never share the same binary in ~/temp/.
    local dir_hash = vim.fn.sha256(dir):sub(1, 6)
    local out = vim.fn.expand("~/temp/") .. stem .. "_" .. dir_hash
    vim.fn.mkdir(vim.fn.expand("~/temp"), "p")

    local sources = { vim.fn.shellescape(abs_file) }
    for _, sibling in ipairs(vim.fn.glob(dir .. "/*.cpp", false, true)) do
        if sibling ~= abs_file then
            -- Exclude files that define their own entry point to avoid duplicate-main
            -- linker errors. Covers: int main, int  main, auto main -> int (C++20).
            vim.fn.system("grep -qlE 'int[[:space:]]+main|auto[[:space:]]+main' " .. vim.fn.shellescape(sibling))
            if vim.v.shell_error ~= 0 then
                table.insert(sources, vim.fn.shellescape(sibling))
            end
        end
    end

    return "g++ -std=c++20 -g -Wall -Wextra "
        .. table.concat(sources, " ")
        .. " -o "
        .. vim.fn.shellescape(out)
        .. " && "
        .. vim.fn.shellescape(out)
end

local function run_file_in_chan(chan, abs_file, ft)
    vim.fn.chansend(chan, "clear && printf '\\033[3J'\n")
    -- printf %s is safe for any path; echo 'Running: ' .. path breaks on paths with single quotes.
    vim.fn.chansend(chan, "printf 'Running: %s\\n' " .. vim.fn.shellescape(abs_file) .. "\n")

    local dir = vim.fn.fnamemodify(abs_file, ":h")

    if ft == "cpp" then
        vim.fn.chansend(chan, cpp_command(abs_file) .. "\n")
    elseif ft == "python" then
        vim.fn.chansend(chan, "python3 " .. vim.fn.shellescape(abs_file) .. "\n")
    elseif ft == "rust" then
        local cargo_root = find_project_root(dir, "Cargo.toml")
        if cargo_root then
            vim.fn.chansend(chan, "cd " .. vim.fn.shellescape(cargo_root) .. " && cargo run\n")
        else
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

-- ─── Runner ─────────────────────────────────────────────────────────────────
vim.keymap.set({ "n", "i", "t" }, "<F5>", function()
    if vim.bo.buftype == "terminal" then
        vim.cmd("wincmd p")
    end
    local ft = vim.bo.filetype
    if ft ~= "cpp" and ft ~= "python" and ft ~= "rust" then
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
        vim.fn.chansend(chan, "\003")
        vim.defer_fn(function()
            local new_chan = vim.b[vim.g.cpp_term_buf].terminal_job_id
            if new_chan and vim.fn.jobwait({ new_chan }, 0)[1] == -1 then
                run_file_in_chan(new_chan, abs_file, ft)
            else
                vim.cmd("bd! " .. vim.g.cpp_term_buf)
                create_term()
                local restart_chan = vim.b[vim.g.cpp_term_buf].terminal_job_id
                if restart_chan then
                    run_file_in_chan(restart_chan, abs_file, ft)
                end
            end
        end, 100)
    else
        vim.defer_fn(function()
            local new_chan = vim.b[vim.g.cpp_term_buf].terminal_job_id
            if new_chan then
                run_file_in_chan(new_chan, abs_file, ft)
            end
        end, 150)
    end
    vim.cmd("wincmd p")
end, { desc = "Run current file (C++ / Python / Rust)" })
