# nvim.pack

Same editor behavior as [`~/dotfiles/nvim.easy`](../nvim.easy/README.md), but
plugins are installed with Neovim’s built-in **`vim.pack`** package manager
(**Neovim 0.12+**) instead of lazy.nvim. No external bootstrap: one file
declares every repository; each plugin’s `setup()` lives in
`lua/plugins/<name>.lua`.

Use this tree to try the native pack workflow, or as the target if you
migrate off lazy.nvim. Day-to-day switching does not mix plugin data dirs.

## Requirements

- Neovim **0.12+** (`vim.pack.add`)
- `git` on `PATH`
- Same optional tooling as nvim.easy (Mason, tree-sitter CLI, etc.)

## Activate

```bash
XDG_CONFIG_HOME=~/dotfiles NVIM_APPNAME=nvim.pack nvim
```

Shell helper (from `~/dotfiles/utils/bash_nvim.sh`):

```bash
vi -p              # nvim.pack (note: consumes bare -p; use -p5 for nvim tabs)
```

Or a dedicated function:

```bash
nvp() { XDG_CONFIG_HOME=$HOME/dotfiles NVIM_APPNAME=nvim.pack nvim "$@"; }
```

### Data directories

Plugins clone to:

`~/.local/share/nvim.pack/site/pack/core/opt/<repo-name>/`

Other state (Mason, shada, undo) uses `~/.local/{share,state,cache}/nvim.pack/`
— separate from `nvim.easy`.

## First launch

1. `init.lua` loads options → autocmds → user commands → **`plugins`** → keymaps.
2. `lua/plugins.lua` calls `vim.pack.add({...})` — missing repos are cloned
   synchronously into `site/pack/core/opt/`.
3. The same file `require()`s each `lua/plugins/*.lua` setup in a fixed
   order (colorscheme → mini/icons → … → blink before lspconfig → treesitter
   before render-markdown).
4. Treesitter parsers and Mason tools may install on early sessions (same as
   nvim.easy).

Subsequent launches: `vim.pack.add` only verifies rtp; no reinstall unless
you update or delete packs.

## Directory structure

```
~/dotfiles/nvim.pack/
├── init.lua                     Entry point (no bootstrap.lua)
├── nvim-pack-lock.json          Pinned plugin revisions (optional record)
├── lua/
│   ├── options.lua              vim.opt.* (kept in sync with nvim.easy)
│   ├── autocmds.lua
│   ├── user_commands.lua        :Utilities, :FormatAllSV
│   ├── keymaps.lua              Basic, plugin-agnostic maps
│   ├── plugins.lua              vim.pack.add() manifest + setup load order
│   ├── plugins/                 One setup file per plugin
│   │   ├── colorscheme.lua      gruvbox
│   │   ├── mini.lua             mini.* + mini.clue (replaces which-key)
│   │   ├── lualine.lua
│   │   ├── snacks.lua           picker, explorer, lazygit (replaces telescope/neo-tree)
│   │   ├── noice.lua
│   │   ├── treesitter.lua
│   │   ├── render-markdown.lua
│   │   ├── gitsigns.lua / neogit.lua / diffview.lua
│   │   ├── flash.lua / kaleidosearch.lua
│   │   ├── harpoon.lua / marks.lua / undotree.lua
│   │   ├── completions.lua      blink.cmp (before lspconfig)
│   │   ├── lspconfig.lua        mason + mason-lspconfig + lspconfig
│   │   ├── formatting.lua / linting.lua / debugging.lua
│   │   └── verilog.lua          verilog_systemverilog.vim globals
│   ├── utils/                   Shared helpers (z_picker, format_sv, …)
│   └── markdown/links.lua
├── after/                       ftdetect + ftplugin (mirrors nvim.easy)
├── queries/systemverilog/
└── syntax/*.vim                 Vendored syntax files
```

Shared with nvim.easy: `after/`, `syntax/`, most `lua/utils/` and
filetype-specific behavior. When changing behavior for both configs, edit
the corresponding file in each tree (or symlink if you later unify).

## Differences vs nvim.easy

Functionally the same plugins and keymaps; only the **loading mechanism**
differs:

| Concept              | nvim.easy (lazy.nvim)              | nvim.pack (`vim.pack`)                |
|----------------------|------------------------------------|---------------------------------------|
| Bootstrap            | `lua/bootstrap.lua` clones lazy    | none                                  |
| Plugin discovery     | `import` of `plugins/`, `core_plugins/`, `code_plugins/` | explicit list in `lua/plugins.lua` |
| Deferred load        | `keys` / `event` / `cmd` in spec   | none — eager load at startup          |
| Transitive deps      | lazy resolves                      | list every repo in `plugins.lua`      |
| Post-install builds  | `build = '...'` in spec            | idempotent steps at bottom of `plugins.lua` |
| Lockfile             | `lazy-lock.json`                   | `nvim-pack-lock.json`                 |
| Update all           | `:Lazy update` then `:Lazy sync`   | `:lua vim.pack.update()`              |
| Browse on disk       | `:Lazy`                            | `~/.local/share/nvim.pack/site/pack/core/opt/` |
| Remove from disk     | `:Lazy clean`                      | `:lua vim.pack.del({'plugin-dir-name'})` |

Removed vs older lazy-era stacks (both configs): **telescope**, **neo-tree**,
**which-key**, **nvim-notify**, **nvim-web-devicons** — replaced by
snacks.picker/explorer, mini.clue, snacks.notifier, and mini.icons.

## Upgrade and maintenance

### Plugins (`vim.pack`)

```vim
:lua vim.pack.update()                    " all plugins
:lua vim.pack.update({'flash.nvim'})      " one plugin (interactive)
:lua vim.pack.del({'flash.nvim'})         " remove clone from pack path
```

Record results in `nvim-pack-lock.json` when you want reproducible SHAs
across machines (analogous to `lazy-lock.json` in nvim.easy).

### Tooling

```vim
:Mason
:TSUpdate
:FormatAllSV
:Utilities
```

### Adding a new plugin

1. Add `{ src = 'https://github.com/...' }` to the `vim.pack.add({...})`
   table in `lua/plugins.lua` (respect dependency order).
2. Create `lua/plugins/<name>.lua` with `require(...).setup({...})` and
   any `vim.keymap.set` calls.
3. Restart nvim; run `:lua vim.pack.update()` if the clone failed mid-flight.

## Known caveats

1. **Eager load** — startup is ~50–150 ms slower than a heavily
   lazy-deferred config; usually fine on SSD.
2. **Treesitter** — parsers install via `plugins/treesitter.lua` on first
   use; no lazy `build` hook.
3. **`mason-tool-installer`** — `run_on_start = true` in
   `plugins/lspconfig.lua`; no-op once tools exist. Set `false` if you
   prefer manual `:Mason` only.
4. **Evicted plugins** — old packs may remain on disk until
   `:lua vim.pack.del({'name'})` (comments in `plugins.lua` list retired
   repos: which-key, neo-tree, telescope, fidget, etc.).

## Primary config: nvim.easy

Daily `vi` without `-p` uses lazy.nvim:

[`../nvim.easy/README.md`](../nvim.easy/README.md)
