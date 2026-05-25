# nvim.pack

Same configuration as `nvim.easy`, but powered by Neovim's built-in
**`vim.pack`** package manager (Neovim 0.12+) instead of `lazy.nvim`.

Modern, minimal, no external bootstrap. One file declares every plugin;
each plugin's setup lives next to it.

## Activate

```bash
XDG_CONFIG_HOME=~/dotfiles NVIM_APPNAME=nvim.pack nvim
```

Or add a function to your shellrc:

```bash
function nvp() {
   XDG_CONFIG_HOME=$HOME/dotfiles NVIM_APPNAME=nvim.pack nvim "$@"
}
```

First launch will:

1. Clone every plugin to `~/.local/share/nvim.pack/site/pack/core/opt/`.
2. Build `telescope-fzf-native`'s `libfzf.so` (via `make`, idempotent).
3. Download required tree-sitter parsers via `nvim-treesitter`.
4. Run `mason-tool-installer` to fetch `tree-sitter-cli`, `shfmt`, etc.

Subsequent launches: nothing reinstalls, just `vim.pack.add` checks rtp.

## Layout

```
~/dotfiles/nvim.pack/
├── init.lua                     entry point
├── README.md                    this file
├── lua/
│   ├── options.lua              vim.opt.* (verbatim from nvim.easy)
│   ├── autocmds.lua             real autocmds (PDF reader, last-loc restore)
│   ├── user_commands.lua        :Utilities / :FormatAllSV
│   ├── keymaps.lua              basic, plugin-agnostic keymaps
│   ├── plugins.lua              vim.pack.add() of every repo + post-build steps
│   ├── plugins/                 per-plugin setup, one file each
│   │   ├── colorscheme.lua      gruvbox
│   │   ├── mini.lua             mini.{basics,extra,ai,surround,pairs,comment,hipatterns}
│   │   ├── devicons.lua         nvim-web-devicons + custom file-type icons
│   │   ├── lualine.lua          + :LualineToggle command + \\\\ key
│   │   ├── snacks.lua           lazygit / terminal / dim / image / bufdelete
│   │   ├── which-key.lua
│   │   ├── noice.lua            + nvim-notify
│   │   ├── indentline.lua       indent-blankline (gruvbox rainbow)
│   │   ├── treesitter.lua       fold via TS, parser install, FT autocmd
│   │   ├── render-markdown.lua  + gruvbox-tuned highlights
│   │   ├── gitsigns.lua
│   │   ├── neogit.lua           + diffview
│   │   ├── flash.lua            s/S/r/R/<C-s>
│   │   ├── kaleidosearch.lua    custom 8-color highlighter palette
│   │   ├── harpoon.lua
│   │   ├── marks.lua
│   │   ├── undotree.lua
│   │   ├── neo-tree.lua         + per-extension filename colors
│   │   ├── telescope.lua        <leader>t{g,b} -- live_grep / buffers
│   │   ├── completions.lua      blink.cmp (must precede lspconfig)
│   │   ├── lspconfig.lua        mason + mason-lspconfig + nvim-lspconfig
│   │   ├── formatting.lua       conform.nvim
│   │   ├── linting.lua          nvim-lint
│   │   ├── debugging.lua        nvim-dap + dap-ui + dap-virtual-text
│   │   └── verilog.lua          vhda/verilog_systemverilog.vim global
│   ├── markdown/links.lua       (verbatim from nvim.easy)
│   ├── utils/                   helper utilities (z_picker, format_sv, etc.)
│   └── user_plugins/            (verbatim) nvim_notes blink source
├── after/
│   ├── ftdetect/filetype.lua    (verbatim)
│   └── ftplugin/*.lua           (verbatim) markdown / jira / verilog / tdf / ...
└── syntax/*.vim                 (verbatim) jira / map / semifore / scat / trace32 / tdf / f
```

## Differences vs nvim.easy

Functionally identical -- same plugins, same keymaps, same behavior. Only the
**loading mechanism** differs:

| Concept             | nvim.easy (lazy.nvim)                        | nvim.pack (vim.pack)                  |
|---------------------|----------------------------------------------|---------------------------------------|
| Plugin manager      | external (lazy.nvim cloned in `bootstrap.lua`) | built-in `vim.pack.add({...})`        |
| Plugin discovery    | `{ import = 'plugins' }` walks `lua/plugins/` | explicit list in `lua/plugins.lua`    |
| Lazy loading        | per-plugin via `keys = / event = / cmd = `   | none -- everything eager (fast on SSD)|
| Dependencies        | declared in spec; resolved automatically     | declare every transitive dep yourself |
| `build = '...'` hook| automatic                                    | explicit, in `lua/plugins.lua`        |
| Keymaps             | `keys = {...}` table                         | `vim.keymap.set(...)` in setup file   |
| Update              | `:Lazy update`                               | `:lua vim.pack.update()`              |
| Browse installed    | `:Lazy`                                      | `~/.local/share/nvim.pack/site/pack/core/opt/` |

## Maintenance

Update everything:

```vim
:lua vim.pack.update()
```

Update one plugin (interactive prompt):

```vim
:lua vim.pack.update({'flash.nvim'})
```

Remove a plugin (deletes from disk):

```vim
:lua vim.pack.del({'flash.nvim'})
```

After a mason-managed binary or a tree-sitter parser stops working:

```vim
:Mason            " inspect / re-install via the UI
:TSUpdate         " refresh treesitter parsers
```

## Known caveats vs lazy.nvim

1. **Eager load = ~50-150 ms slower startup** vs a lazy-loaded config.
   On modern nvim with SSD this is invisible. If you want it back, wrap
   slow plugin setups in autocmds (`event = 'VeryLazy'` becomes
   `vim.api.nvim_create_autocmd('User', { pattern = 'VeryLazy', ... })`).

2. **No build hook for treesitter**: `nvim-treesitter` (main branch) self-
   manages parsers via `ts.install(...)` in `plugins/treesitter.lua`. The
   first launch on a fresh checkout will pull parsers in the background.

3. **`telescope-fzf-native` build runs once at startup** if `libfzf.so` is
   missing (see plugins.lua). If it fails (no `make` on PATH), the fzf
   sorter falls back to telescope's default sorter.

4. **`mason-tool-installer` runs on every startup** (`run_on_start = true`,
   inherited from nvim.easy). It's a no-op once tools are installed; if
   you find this annoying, set `run_on_start = false` in
   `plugins/lspconfig.lua`.
