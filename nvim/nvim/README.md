<div align="center">

# ⚡ nvim

**A minimal, fast, opinionated Neovim config built on [LazyVim](https://lazyvim.org)**  
Tuned for C++ / Python / Rust development — with a personality.

![Neovim](https://img.shields.io/badge/Neovim-%3E%3D0.10-57A143?style=flat-square&logo=neovim&logoColor=white)
![LazyVim](https://img.shields.io/badge/LazyVim-v8-7C3AED?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)

</div>

---

## 📸 Overview

This is a **production-ready personal Neovim config** on top of LazyVim's solid foundation — not a framework, not a distribution. Just a carefully curated setup that stays out of your way while you code.

The design goal is simple: **fast startup, predictable behavior, and a workflow that feels modern without abandoning Vim's core strengths.** Every plugin earns its place. Every keymap has a reason.

---

## ✨ Features

- 🚀 **One-key multi-language runner** — F5 compiles and runs C++, Python, or Rust in a persistent bottom terminal, with smart process management (interrupt → recompile, auto-restart on crash)
- ⚡ **SnipRun integration** — run small code snippets or selections instantly inside the editor (inline / floating) via `<leader>r`, ideal for quick logic testing without leaving the buffer
- 🗂 **Buffer-centric navigation** — Bufferline with ordinal numbers and `<leader>t1–9` direct jumps, matching the muscle memory of browser tab navigation
- 🎨 **Catppuccin Mocha** with transparent background and a custom blue cursor tied to the palette
- 🔥 **Animated fire cursor** via smear-cursor.nvim — because why not
- 💬 **Self-roast dashboard** — 220 rotating programmer quotes on startup. Motivational in the only honest way
- 🧠 **Smart insert-mode escape** (`jk`) that detects when you're mid-word and doesn't interrupt normal typing
- ⬆️ **Jump-past-closing-bracket** in insert mode (`<C-l>`) — skip `)`, `}`, `]`, `"` without reaching for Escape or arrow keys
- 📐 **Mode-aware cursor shapes** — block in Normal, beam in Insert, underline in Replace
- 🔢 **Relative line numbers** that switch to absolute in Insert mode automatically
- 🔍 **Clang-tidy linting** on every C/C++ write
- 🧩 **Minimal plugin footprint** — ~33 total plugins, mostly LazyVim defaults, zero bloat

---

## 🧠 Philosophy

> *Extend LazyVim. Don't fight it.*

This config treats LazyVim as infrastructure, not a starting point to tear down. Plugins are overridden via `opts` merging, not reimplemented. The plugin set is deliberately small — if something doesn't directly improve the edit→run→debug loop, it probably isn't here.

**Priorities, in order:**
1. Speed — fast startup, responsive editing
2. Correctness — behavior should be predictable and consistent
3. Ergonomics — common actions should be effortless
4. Aesthetics — the environment should feel good to be in

**What this config is not:**
- A showcase of every Neovim feature
- A port of VS Code
- A config that changes every week

---

## ⌨️ Key Bindings

> Leader key: `<Space>`

### 🏃 Run & Terminal

| Key | Mode | Action |
|-----|------|--------|
| `<F5>` | Normal / Insert / Terminal | Compile & run current file (C++ / Python / Rust) |
| `<leader>k` | Normal / Insert / Terminal | Toggle focus between code and terminal |

### 🗂 Buffer Navigation

| Key | Mode | Action |
|-----|------|--------|
| `<leader>t1` – `<leader>t9` | Normal | Jump to buffer by ordinal position |
| `<leader>tt` | Normal | New buffer tab |
| `<leader>tc` | Normal | Smart close current buffer |
| `<leader>to` | Normal | Close all other buffers |
| `<S-h>` / `<S-l>` | Normal | Previous / Next buffer *(LazyVim default)* |

### ✏️ Insert Mode Helpers

| Key | Mode | Action |
|-----|------|--------|
| `jk` | Insert | Escape to Normal (skips if mid-word) |
| `<C-l>` | Insert | Jump past next closing bracket or quote |

### 🔍 Search & Navigation *(LazyVim defaults, included for reference)*

| Key | Action |
|-----|--------|
| `<leader>/` | Search in current buffer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Browse open buffers |
| `<leader>fr` | Recent files |

---

## 📂 Structure

```
nvim/
├── init.lua                    # Bootstrap only — requires config.lazy
├── lazyvim.json                # LazyVim extras (currently none)
├── lazy-lock.json              # Locked plugin versions
└── lua/
    ├── config/
    │   ├── lazy.lua            # Plugin manager setup & performance opts
    │   ├── options.lua         # Editor options, cursor shape, colorscheme hook
    │   ├── keymaps.lua         # All custom keymaps + F5 runner logic
    │   ├── autocmds.lua        # Custom autocommands
    │   └── quotes.lua          # 220 fun programmer quotes for the dashboard
    └── plugins/
        ├── colorscheme.lua     # Catppuccin Mocha (transparent) + Tokyonight fallback
        ├── dashboard.lua       # Snacks dashboard with custom header + random quote
        ├── bufferline.lua      # Ordinal buffer numbers
        ├── ui.lua              # Smear-cursor with fire style
        ├── lsp.lua             # Clangd, Pyright, Rust-analyzer
        ├── lint.lua            # Clang-tidy for C/C++
        └── render-markdown.lua # Markdown rendering in-buffer
```

---

## 🔌 Plugins

### Added by this config

| Plugin | Purpose |
|--------|---------|
| `catppuccin/nvim` | Colorscheme — Mocha flavour, transparent background |
| `folke/tokyonight.nvim` | Kept lazy as a fallback colorscheme |
| `sphamba/smear-cursor.nvim` | Animated cursor trail (fire style) |
| `mfussenegger/nvim-lint` | Linting engine — runs clang-tidy on C/C++ files |
| `MeanderingProgrammer/render-markdown.nvim` | Renders Markdown with syntax, tables, and formatting inline |

### Key LazyVim defaults (inherited)

| Plugin | Purpose |
|--------|---------|
| `akinsho/bufferline.nvim` | Buffer tab bar with ordinal numbering |
| `folke/snacks.nvim` | Dashboard, file picker, buffer deletion, and more |
| `neovim/nvim-lspconfig` | LSP client configuration |
| `mason-org/mason.nvim` | LSP / linter installer |
| `nvim-treesitter` | Syntax highlighting and text objects |
| `blink.cmp` | Fast completion engine |
| `conform.nvim` | Code formatting on save |
| `flash.nvim` | Lightning-fast cursor jumping |
| `gitsigns.nvim` | Git change indicators in the gutter |
| `trouble.nvim` | Diagnostics panel |
| `grug-far.nvim` | Project-wide find and replace |
| `mini.pairs` | Auto-close brackets and quotes |
| `mini.ai` | Extended text objects (`a`, `i`) |
| `noice.nvim` | Replaced command line and notification UI |
| `which-key.nvim` | Keymap popup guide |
| `persistence.nvim` | Session save and restore |
| `todo-comments.nvim` | Highlight and search TODO/FIXME/HACK comments |

---

## ⚡ Performance

- **Startup time kept low** by disabling unused built-in plugins: `gzip`, `tarPlugin`, `tohtml`, `tutor`, `zipPlugin`
- **Smear-cursor** loads on `VeryLazy` — deferred until after startup is complete
- **Render-markdown** is filetype-gated (`ft = { "markdown" }`) — zero cost unless you open a `.md` file
- **Plugin updates** are checked silently in the background (`checker.notify = false`) — no popup noise on startup
- **All plugins pinned** via `lazy-lock.json` — reproducible installs, no surprise breakage from upstream changes
- `version = false` across all plugins — always tracks latest git commit, not semver tags

---

## 🧩 Custom Features

### F5 — Persistent Multi-Language Runner

Press `<F5>` from any C++, Python, or Rust file. The runner:

1. Saves the current file
2. Opens a persistent `12`-line terminal split at the bottom (or reuses the existing one)
3. Sends an interrupt (`Ctrl-C`) to stop any running process
4. Compiles and runs:
   - **C++**: `g++ file.cpp -o out && ./out`
   - **Python**: `python3 file.py`
   - **Rust**: `cargo run` if a `Cargo.toml` exists, otherwise `rustc` directly
5. Returns focus to the code window automatically

The terminal is **persistent across runs** — it stays open and reuses the same window. If the terminal process dies unexpectedly, the runner detects this and restarts it cleanly.

Works from Normal, Insert, and Terminal mode. Filenames with spaces or special characters are shell-escaped safely.

---

### SnipRun — Quick Code Execution

- `<leader>r` → run current line or selection  
- Output inside Neovim (inline / floating)  
- For quick logic checks — not full programs  
- No interactive input (`cin`, `scanf`)  
- Not for multi-file execution  
- Test a loop, condition, or small snippet instantly
- Avoid recompiling the entire program

---

### Smart Insert Escape (`jk`)

The `jk` → `<Esc>` mapping includes word-boundary detection. If the character immediately before the cursor is a letter (i.e., you're mid-word), `jk` types literally. Only triggers escape at word boundaries.

This means typing `object`, `reject`, `jacket` in insert mode works normally without misfiring.

---

### Jump Past Closing Pair (`<C-l>`)

In insert mode, if the cursor is sitting just before `)`, `}`, `]`, `"`, or `'`, pressing `<C-l>` moves the cursor past it instead of inserting a literal character. Pairs naturally with `mini.pairs` auto-closing — type the open bracket, write content, `<C-l>` to exit.

---

### Mode-Aware Cursor Shapes

```
Normal / Visual  →  Block cursor  (█)
Insert           →  Beam cursor   (|)
Replace          →  Underline     (_)
```

Cursor color is pinned to Catppuccin blue (`#89b4fa`) and re-applied automatically after every colorscheme load so it survives `:colorscheme` resets.

---

### Self-Roast Dashboard

The startup dashboard picks one of **220 programmer quotes** at random on every launch. They range from gently ironic to brutally honest. No inspirational nonsense.

```
Your code works best when you don't touch it.
```

Quote selection uses `vim.uv.hrtime()` as the random seed — no repeated sequences across sessions.

---

## 🚀 Installation

**Requirements:**

- Neovim `≥ 0.10`
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (for icons)
- `g++` (for C++ runner)
- `python3` (for Python runner)
- `cargo` / `rustc` (for Rust runner)
- `clangd` and `clang-tidy` (auto-installed via Mason)
- `node` ≥ 16 (required by Mason for some LSP servers)

**Install:**

```bash
# Back up existing config if you have one
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this config
git clone https://github.com/singh-prithvi/nvim-config ~/.config/nvim

# Launch Neovim — lazy.nvim bootstraps automatically
nvim
```

On first launch, LazyVim will install all plugins. Mason will then install the language servers (`clangd`, `pyright`, `rust-analyzer`) in the background.

---

## 🛠 Requirements Summary

| Dependency | Version | Purpose |
|------------|---------|---------|
| Neovim | ≥ 0.10 | Required |
| Git | any | Plugin management |
| Nerd Font | any | Icons and glyphs |
| Node.js | ≥ 16 | Mason LSP installer |
| `g++` | any | C++ compilation (F5 runner) |
| `python3` | any | Python execution (F5 runner) |
| `cargo` / `rustc` | any | Rust compilation (F5 runner) |
| `clangd` | any | C/C++ LSP (auto-installed by Mason) |
| `clang-tidy` | any | C/C++ linting (auto-installed by Mason) |

---

<div align="center">

Built on [LazyVim](https://lazyvim.org) by [@folke](https://github.com/folke)

</div>
