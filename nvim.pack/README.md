# nvim.pack

Same editor behavior as [`~/dotfiles/nvim.easy`](../nvim.easy/README.md), but
plugins are installed with Neovim’s built-in **`vim.pack`** package manager
(**Neovim 0.12+**) instead of lazy.nvim. No external bootstrap: one file
declares every repository; each plugin’s `setup()` lives in
`lua/plugins/<name>.lua`.

This is the **default** config — plain `vi` lands here. `nvim.easy` is the
fallback, reached with `vi -p`. Day-to-day switching does not mix plugin
data dirs.

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
vi                 # nvim.pack -- this tree, the wrapper's default
vi -p              # nvim.easy instead ("previous")
```

The wrapper consumes a bare `-p` as that config switch, so nvim's own
"open in tabs" flag has to carry a count: `vi -p5`.

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
2. `lua/plugins.lua` first requires `pack_nfs_dtype_fix` (see caveats), then
   calls `vim.pack.add({...})` — missing repos are cloned synchronously into
   `site/pack/core/opt/`.
3. The same file runs each `lua/plugins/<name>.lua` setup in two phases
   (see below).
4. Treesitter parsers and Mason tools may install on early sessions (same as
   nvim.easy).

Subsequent launches: `vim.pack.add` only verifies rtp; no reinstall unless
you update or delete packs.

### Two-phase setup

`vim.pack` has no lazy loading and no `priority` knob, so running every
`setup()` inline meant ~340 ms of toolchain work before `VimEnter` fired —
and the snacks dashboard only opens on `VimEnter`. The result was nvim's
built-in intro sitting on screen for about a second before the dashboard
painted over it. `lua/plugins.lua` splits the work instead:

- **Phase 1, inline:** colorscheme → mini (its
  `mock_nvim_web_devicons()` must precede anything that requires
  `nvim-web-devicons`) → lualine, snacks, noice → git stack → navigation.
- **Phase 2, on `VimEnter` via `vim.schedule`:** treesitter →
  render-markdown, then blink.cmp → lspconfig (capabilities ordering),
  then conform, nvim-lint, dap.

Phase 2 finishes by re-firing `FileType` on every already-loaded real
buffer, so `vi somefile.sv` still gets treesitter and LSP attached even
though those handlers registered after that buffer's original `FileType`.

`vim.pack.add()` itself is **not** deferred — all plugins still join the
runtimepath at startup (~24 ms), which keeps `:packadd` unnecessary and the
dashboard's plugin count accurate.

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
│   ├── pack_nfs_dtype_fix.lua   NFS d_type shim; must load before vim.pack.add
│   ├── plugins.lua              vim.pack.add() manifest + two-phase setup
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
│   │   └── formatting.lua / linting.lua / debugging.lua
│   ├── utils/                   Shared helpers (z_picker, format_sv, …)
│   └── markdown/links.lua
├── after/                       ftdetect + ftplugin (mirrors nvim.easy)
├── ftplugin/sv.vim              Defers to built-in systemverilog ftplugin
├── indent/sv.vim                Defers to built-in SystemVerilogIndent()
├── queries/systemverilog/
├── syntax/*.vim                 Vendored syntax files
└── .stylua.toml                 3-space, single quotes, column 160
```

### Shared with nvim.easy

These are **byte-identical copies**, not symlinks — `after/` (ftdetect plus
all eleven ftplugins), `syntax/`, `ftplugin/sv.vim`, `indent/sv.vim`,
`queries/`, every file in `lua/utils/`, `lua/markdown/links.lua`,
`lua/autocmds.lua`, `lua/user_commands.lua`, and `.stylua.toml`.

**A change to any of them has to be made twice**, once per tree. Verify
with:

```sh
cd ~/dotfiles && diff -rq nvim.easy nvim.pack
```

Files that legitimately differ: `init.lua`, `lua/options.lua` (this tree
adds `shortmess:append('I')` to suppress the intro flash),
`lua/keymaps.lua` (comment path references only), the four shared specs in
`lua/plugins/` that exist in both (`colorscheme`, `flash`, `treesitter`,
`kaleidosearch` — same logic, unwrapped from the lazy spec table), the
lockfiles, and the READMEs.

`.stylua.toml` must be present in *both* trees: stylua searches upward from
the file being formatted, and `~/dotfiles` itself has no copy, so a tree
without one silently gets stylua's defaults (4-space, double quotes).

## Differences vs nvim.easy

Functionally the same plugins and keymaps; only the **loading mechanism**
differs:

| Concept             | nvim.easy (lazy.nvim)                         | nvim.pack (`vim.pack`)                         |
| ------------------- | --------------------------------------------- | ---------------------------------------------- |
| Bootstrap           | `lua/bootstrap.lua` clones lazy               | none                                           |
| Plugin discovery    | `import` of `plugins/`, `core_plugins/`,      | explicit list in `lua/plugins.lua`             |
|                     | `code_plugins/`                               |                                                |
| Deferred load       | `keys` / `event` / `cmd` in spec              | two phases, split by hand in `plugins.lua`     |
| Transitive deps     | lazy resolves                                 | list every repo in `plugins.lua`               |
| Post-install builds | `build = '...'` in spec                       | idempotent steps at bottom of `plugins.lua`    |
| Lockfile            | `lazy-lock.json`                              | `nvim-pack-lock.json`                          |
| Update all          | `:Lazy update` then `:Lazy sync`              | `:lua vim.pack.update()`                       |
| Browse on disk      | `:Lazy`                                       | `~/.local/share/nvim.pack/site/pack/core/opt/` |
| Remove from disk    | `:Lazy clean`                                 | `:lua vim.pack.del({'plugin-dir-name'})`       |

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

1. **Eager `add`** — every plugin joins the runtimepath at startup, so
   this is still somewhat slower than a heavily lazy-deferred config. The
   expensive `setup()` calls are deferred (see "Two-phase setup"), which
   recovers most of it; what remains is usually fine on SSD.
2. **NFS plugin store** — if `~/.local/share` is NFS-mounted, `vim.pack`
   re-clones already-installed plugins on every launch, because an NFS
   `READDIR` returns `DT_UNKNOWN` and libuv surfaces that as a nil file
   type, which `lock_sync()` reads as "not a directory, so not installed".
   `lua/pack_nfs_dtype_fix.lua` wraps `vim.fs.dir` to backfill the type
   with a `stat()`. It must be required **before** `vim.pack.add()`.
3. **Treesitter** — parsers install via `plugins/treesitter.lua` on first
   use; no lazy `build` hook.
4. **`mason-tool-installer`** — `run_on_start = true` in
   `plugins/lspconfig.lua`; no-op once tools exist. Set `false` if you
   prefer manual `:Mason` only.
5. **Evicted plugins** — old packs may remain on disk until
   `:lua vim.pack.del({'name'})` (comments in `plugins.lua` list retired
   repos: which-key, neo-tree, telescope, fidget, etc.).

## Fallback config: nvim.easy

Same editor, lazy.nvim instead of `vim.pack`. Reach it with `vi -p`:

[`../nvim.easy/README.md`](../nvim.easy/README.md)
