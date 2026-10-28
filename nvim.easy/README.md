# nvim.easy

Personal Neovim config: LSP, completion, snacks-based picker/explorer, git
UI, markdown preview, and domain-specific filetypes (SystemVerilog, Jira,
Trace32, etc.). Plugins are managed with **lazy.nvim** (auto-cloned on first
launch).

A parallel tree lives at [`~/dotfiles/nvim.pack`](../nvim.pack/README.md) —
same behavior, **`vim.pack`** instead of lazy.nvim. That one is now the
default `vi`; this tree is kept as the fallback (`vi -p`) and as the
reference for anything that has not been ported yet.

## Requirements

- Neovim **0.12+** — `core_plugins/undotree.lua` wires up the built-in
  `$VIMRUNTIME/pack/dist/opt/nvim.undotree` rather than mbbill/undotree
- `git` on `PATH` (lazy.nvim bootstrap)
- Optional but expected in practice: `make` (some plugin builds), Mason
  tools (`tree-sitter-cli`, `shfmt`, …) installed on first LSP session

## Activate

Config lives under `~/dotfiles/`; Neovim must see it via `XDG_CONFIG_HOME`
and a distinct app name so data dirs do not collide with other configs.

```bash
XDG_CONFIG_HOME=~/dotfiles NVIM_APPNAME=nvim.easy nvim
```

**Recommended:** use the `vi` wrapper in `~/dotfiles/utils/bash_nvim.sh`
(sourced from your shellrc). It exports those variables for you. Note that
the wrapper defaults to **`nvim.pack`**; this tree is the `-p` ("previous")
option:

```bash
vi -p           # lazy.nvim config (this tree)
vi              # nvim.pack, the default (see sibling README)
vi -p -x f.sv   # optional xterm wrapper
```

The wrapper consumes a bare `-p` as the config switch, so nvim's own
"open in tabs" flag has to be given a count: `vi -p5`.

Git difftool (from `~/dotfiles/initrc/gitconfig`) also points at this app
name for `git difftool`.

### Data directories

With `NVIM_APPNAME=nvim.easy`, Neovim isolates state under your XDG dirs,
for example:

| Purpose        | Typical path                              |
| -------------- | ----------------------------------------- |
| lazy.nvim      | `~/.local/share/nvim.easy/lazy/lazy.nvim` |
| Plugin clones  | `~/.local/share/nvim.easy/lazy/<plugin>`  |
| Mason packages | `~/.local/share/nvim.easy/mason/`         |
| Undo / shada   | `~/.local/state/nvim.easy/`               |

`nvim.pack` uses parallel `~/.local/{share,state,cache}/nvim.pack/` trees;
switching `vi` vs `vi -p` does not cross-contaminate plugin installs.

## First launch

1. `init.lua` sets `<Space>` as `mapleader`, then loads core Lua.
2. `lua/bootstrap.lua` clones **lazy.nvim** into
   `stdpath('data')/lazy/lazy.nvim` if missing, then runs `require('lazy').setup`.
3. lazy.nvim walks three import roots (see below), installs missing plugins,
   runs `build` hooks where declared, and records versions in `lazy-lock.json`.
4. Mason / treesitter / snacks may pull binaries and parsers in the
   background on early sessions.

Later launches only sync when you ask (`:Lazy sync` / update) or when the
lockfile changes after a git pull.

## Directory structure

```
~/dotfiles/nvim.easy/
├── init.lua                 Entry: leader, options → autocmds → commands →
│                            bootstrap (lazy) → keymaps
├── lazy-lock.json           Pinned plugin commits (commit after upgrades)
├── lazyvim.json             Legacy/metadata from LazyVim template (unused at runtime)
├── lua/
│   ├── bootstrap.lua        Clone lazy.nvim + `require('lazy').setup({...})`
│   ├── options.lua          `vim.opt.*` and global editor settings
│   ├── autocmds.lua         Autocmds (PDF helper, last-location restore, …)
│   ├── user_commands.lua    `:Utilities`, `:FormatAllSV`
│   ├── keymaps.lua          Plugin-agnostic maps (leader bindings mostly live
│   │                        in plugin specs via lazy `keys = { ... }`)
│   ├── plugins/             Lazy specs: small or “leaf” plugins
│   │   ├── colorscheme.lua  gruvbox
│   │   ├── flash.lua
│   │   ├── treesitter.lua
│   │   └── kaleidosearch.lua
│   ├── core_plugins/        UI, git, navigation, markdown
│   │   ├── mini.lua         mini.* modules + mini.clue (which-key replacement)
│   │   ├── lualine.lua
│   │   ├── snacks.lua       picker, explorer, lazygit, terminal, bigfile, …
│   │   ├── noice.lua
│   │   ├── render-markdown.lua
│   │   ├── gitsigns.lua / neogit.lua / diffview.lua
│   │   └── harpoon.lua / marks.lua / undotree.lua (builtin pack)
│   ├── code_plugins/        LSP, format, lint, debug, completion
│   │   ├── completions.lua  blink.cmp (must load before lspconfig)
│   │   ├── lspconfig.lua    mason + mason-lspconfig + lspconfig
│   │   ├── formatting.lua   conform.nvim
│   │   ├── linting.lua
│   │   └── debugging.lua    nvim-dap stack
│   ├── utils/               Pickers and one-off tools (`format_sv`, …)
│   └── markdown/links.lua   Markdown link helpers
├── after/
│   ├── ftdetect/filetype.lua
│   └── ftplugin/*.lua       Per-filetype settings (markdown, SV, jira, …)
├── ftplugin/sv.vim          Defers to built-in systemverilog ftplugin
├── indent/sv.vim            Defers to built-in SystemVerilogIndent()
├── queries/systemverilog/   treesitter textobjects (custom query)
├── syntax/*.vim             Vendored syntax (jira, map, trace32, tdf, …)
└── .stylua.toml             3-space, single quotes, column 160
```

Everything from `after/` down — plus `lua/utils/`, `lua/markdown/`,
`lua/autocmds.lua`, `lua/user_commands.lua`, and `.stylua.toml` — is
byte-identical to the `nvim.pack` tree. There are no symlinks between the
two: **a change to any of those files has to be made twice.**

### How lazy.nvim discovers plugins

`bootstrap.lua` registers three import paths:

```lua
require('lazy').setup({
   spec = {
      { import = 'plugins' },
      { import = 'core_plugins' },
      { import = 'code_plugins' },
   },
})
```

Each `lua/<import>/*.lua` file returns a lazy **spec table** (or list of
tables). Use `keys`, `event`, `cmd`, `ft`, and `dependencies` in the spec
for deferred loading; setup usually lives in the same file’s `config` or
`opts` function.

**Load order caveat:** blink.cmp must be available before lspconfig reads
LSP capabilities — keep `completions.lua` before `lspconfig.lua` in the
dependency graph (already satisfied via mason/lspconfig’s own deps).

## Upgrade and maintenance

### Plugins (lazy.nvim)

| Task             | Command               | Notes                                      |
| ---------------- | --------------------- | ------------------------------------------ |
| Update all       | `:Lazy update`        | Fetches newer commits; review then sync    |
| Install / repair | `:Lazy sync`          | Installs missing; updates `lazy-lock.json` |
| Inspect          | `:Lazy`               | UI: enable/disable, logs, profiling        |
| Single plugin    | `:Lazy update <name>` | e.g. `snacks.nvim`                         |
| Health           | `:checkhealth lazy`   |                                            |

After updating, **commit `lazy-lock.json`** with your dotfiles so other
machines reproduce the same plugin SHAs.

```bash
cd ~/dotfiles && git add nvim.easy/lazy-lock.json && git commit -m "nvim: bump lazy lockfile"
```

### Tooling (not managed by lazy)

```vim
:Mason              " LSP servers, formatters, DAP adapters (UI)
:TSUpdate           " Refresh treesitter parsers
:FormatAllSV        " Project-local: all SystemVerilog under cwd
:Utilities          " Picker for registers, colorscheme, etc.
```

`mason-tool-installer` may run on startup (`run_on_start` in
`code_plugins/lspconfig.lua`); it is a no-op once tools exist.

### Editing this config

- **New plugin:** add `lua/<area>/<name>.lua` returning a lazy spec; run
  `:Lazy sync`.
- **Keymaps tied to a plugin:** prefer `keys = { ... }` in that plugin’s
  spec so lazy can defer-load it.
- **New filetype:** add `after/ftplugin/<type>.lua` and optionally
  `syntax/<type>.vim` + treesitter parser in `plugins/treesitter.lua`.
- **Style:** `nvim.easy/.stylua.toml` (not the dotfiles root — stylua
  searches upward from the file being formatted, so the copy has to sit
  inside each config tree). Run `stylua` on changed Lua, or `<leader>mp`.

## Sibling config: nvim.pack

| Topic           | nvim.easy (this tree)     | nvim.pack                        |
| --------------- | ------------------------- | -------------------------------- |
| Launched by     | `vi -p`                   | `vi` (default)                   |
| Package manager | lazy.nvim                 | built-in `vim.pack` (0.12+)      |
| Plugin list     | auto-discovered specs     | explicit `lua/plugins.lua`       |
| Lockfile        | `lazy-lock.json`          | `nvim-pack-lock.json`            |
| Update command  | `:Lazy update` / `sync`   | `:lua vim.pack.update()`         |
| Lazy loading    | per-spec `keys` / `event` | two phases, deferred on VimEnter |

Details: [`../nvim.pack/README.md`](../nvim.pack/README.md).
