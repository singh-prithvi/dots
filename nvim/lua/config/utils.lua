-- lua/config/utils.lua
-- Shared helpers used across the config.
-- Keep this module free of side-effects — it is required at startup.
local M = {}

--- Walk up the directory tree from `dir` looking for a file/directory named
--- `marker`. Stops as soon as a `.git` boundary is crossed (i.e. never
--- escapes a project root).  Returns the first directory that contains
--- `marker`, or nil.
---
---@param dir    string  absolute starting directory
---@param marker string  filename or dirname to search for (e.g. "Makefile")
---@return string|nil
function M.find_project_root(dir, marker)
    local current = dir
    while true do
        if vim.fn.filereadable(current .. "/" .. marker) == 1
            or vim.fn.isdirectory(current .. "/" .. marker) == 1
        then
            return current
        end
        -- Never cross a git boundary
        if vim.fn.isdirectory(current .. "/.git") == 1 then
            return nil
        end
        local parent = vim.fn.fnamemodify(current, ":h")
        if parent == current then
            break -- reached filesystem root
        end
        current = parent
    end
    return nil
end

-- ─── Shared C/C++ build resolution ─────────────────────────────────────────
-- Used by both runner.lua (F5: run) and debugging.lua (F6: debug) so the
-- Makefile/CMake/single-file tier logic only lives in one place.

--- Like find_project_root, but if the marker lives above the file's own
--- directory, asks for confirmation before using it (you may just want to
--- compile the single file you're looking at). Returns nil if no root was
--- found, or if the user declined to use a root above the current dir.
---@param dir    string absolute starting directory
---@param marker string filename to search for (e.g. "Makefile")
---@return string|nil
function M.find_build_root(dir, marker)
    local root = M.find_project_root(dir, marker)
    if not root or root == dir then
        return root
    end
    local choice = vim.fn.confirm(
        ("Found %s at %s (not current dir). Build with it?"):format(marker, root),
        "&No, compile single file\n&Yes",
        1
    )
    return choice == 2 and root or nil
end

--- Whether the Makefile at `root` defines a `run:` target.
---@param root string directory containing the Makefile
---@return boolean
function M.makefile_has_run_target(root)
    vim.fn.system("grep -qE '^run[[:space:]]*:' " .. vim.fn.shellescape(root .. "/Makefile"))
    return vim.v.shell_error == 0
end

--- Extract the binary name from a Makefile's TARGET/BINARY/EXE assignment.
---@param root string directory containing the Makefile
---@return string|nil
function M.makefile_target(root)
    local target = vim.fn.trim(
        vim.fn.system(
            "grep -E '^(TARGET|BINARY|EXE)[[:space:]]*[:?]?=' "
                .. vim.fn.shellescape(root .. "/Makefile")
                .. " | head -1 | sed 's/.*=[[:space:]]*//' | awk '{print $1}'"
        )
    )
    return target ~= "" and target or nil
end

--- Extract the executable name from a CMakeLists.txt's first add_executable().
---@param root string directory containing CMakeLists.txt
---@return string|nil
function M.cmake_executable(root)
    local exe = vim.fn.trim(
        vim.fn.system(
            "awk '/add_executable/{gsub(/[()]/,\" \"); print $2; exit}' "
                .. vim.fn.shellescape(root .. "/CMakeLists.txt")
        )
    )
    if exe == "" or exe:match("^%$") then
        return nil
    end
    return exe
end

--- Build the source list and temp output path for a single-file compile:
--- the file itself plus any sibling .cpp files in the same directory that
--- don't define their own `main` (companion sources).
---@param abs_file string absolute path of the file being built
---@return string[] sources  absolute, unescaped paths
---@return string   out      temp executable path (unescaped)
function M.cpp_single_file_sources(abs_file)
    local dir = vim.fn.fnamemodify(abs_file, ":h")
    local stem = vim.fn.fnamemodify(abs_file, ":t:r")
    local dir_hash = vim.fn.sha256(dir):sub(1, 6)
    local out = vim.fn.expand("~/temp/") .. stem .. "_" .. dir_hash
    vim.fn.mkdir(vim.fn.expand("~/temp"), "p")

    local sources = { abs_file }
    for _, sibling in ipairs(vim.fn.glob(dir .. "/*.cpp", false, true)) do
        if sibling ~= abs_file then
            vim.fn.system("grep -qlE 'int[[:space:]]+main|auto[[:space:]]+main' " .. vim.fn.shellescape(sibling))
            if vim.v.shell_error ~= 0 then
                table.insert(sources, sibling)
            end
        end
    end
    return sources, out
end

return M
