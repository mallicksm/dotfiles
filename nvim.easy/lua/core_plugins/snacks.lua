return {
   'folke/snacks.nvim',
   priority = 1000,
   lazy = false,
   keys = {
      -- <leader>K for more info on cWORD snacks-lazygit-table-of-contents
      { '<leader>gF', function() require('snacks').lazygit.log_file() end, desc = 'Snacks: Lazygit: log current [F]ile' },
      { '<leader>gL', function() require('snacks').lazygit.log() end,      desc = 'Snacks: Lazygit: repo [L]og' },
      { '<leader>gl', function() require('snacks').lazygit() end,          desc = 'Snacks: [l]azygit TUI' },
      -- Lives under <leader>v* alongside other "vim utilities" -- moved off
      -- bare <leader>T after the toggle family migrated to <leader>T*.
      { '<leader>vt',  function() require('snacks').terminal() end,        desc = 'Vim: floating [t]erminal (snacks)' },
      -- Snacks.toggle.indent():map() requires snacks to be loaded first; in a
      -- lazy.nvim `keys = {}` spec the binding fires lazily after load, so
      -- using a plain rhs function (not :map()) is safest.
      { '<leader>vi',  function() require('snacks').toggle.indent():toggle() end, desc = 'Vim: toggle [i]ndent lines (snacks)' },
      -- (snacks.bufdelete moved to <leader>vd; lives in keymaps.lua under
      --  the <leader>v* "vim introspection / utilities" family.)
   },
   opts = {
      -- snacks.bigfile: replaces our old `nvim.bare` wrapper trick. When a
      -- file's bytes >= `size` OR its average line length is "minified",
      -- snacks attaches a BufReadPre handler that disables treesitter,
      -- LSP attach, syntax sync, matchparen, and a few other O(N) features
      -- *for that buffer only*. Result: 50-200 MB log files open in tens
      -- of ms instead of stalling. `notify=true` toasts once when triggered
      -- so we know we're in degraded mode.
      --
      -- size = 10 MB chosen to catch our typical sim logs / waveform dumps
      -- (often 30-100+ MB) without false-positive on big source files.
      bigfile = {
         enabled     = true,
         notify      = true,
         size        = 10 * 1024 * 1024, -- 10 MB
         line_length = 1000,             -- "minified file" heuristic
      },
      terminal = {
         win = {
            style    = 'float',
            border   = 'rounded',
            -- Mid-size centered float: 75% of editor width, 55% of height.
            -- Numbers between 0 and 1 are fractions of the editor; integers
            -- > 1 would be absolute row/col counts.
            width    = 0.75,
            height   = 0.55,
            position = 'float',
         },
      },
      -- <leader>K for more info on cWORD snacks-lazygit-table-of-contents
      lazygit = {
         -- We own our lazygit config out-of-band: $LG_CONFIG_FILE points at
         -- ~/dotfiles/initrc/lazygit.config.yml (set in shell rc). That file
         -- defines our gruvbox theme, zvim editor, delta pager flags, etc.
         -- Setting `configure = false` tells snacks to NOT generate a theme
         -- YAML and NOT mutate LG_CONFIG_FILE, so our curated config is the
         -- single source of truth. Only the float window styling below is ours.
         configure = false,
         win = {
            style = 'lazygit',
            border = 'rounded',
            width = 0.9,
            height = 0.9,
         },
      },
      -- Indent guides + current-scope line. Replaces lukas-reineke/indent-
      -- blankline.nvim. snacks.indent rotates `indent.hl` per depth, so the
      -- 7 Rainbow* groups give the same gruvbox rainbow that ibl produced.
      -- The Rainbow* hl groups are (re)created in the ColorScheme autocmd
      -- registered in `config` below, so they survive `:Telescope colorscheme`
      -- previews the same way the old ibl HIGHLIGHT_SETUP hook did.
      indent = {
         enabled = true,
         indent  = {
            char = '│',
            hl   = {
               'RainbowRed', 'RainbowYellow', 'RainbowBlue', 'RainbowOrange',
               'RainbowGreen', 'RainbowViolet', 'RainbowCyan',
            },
         },
         scope   = { enabled = true },    -- highlight the cursor's scope line
         chunk   = { enabled = false },   -- skip the animated bracket
         animate = { enabled = false },   -- match ibl behavior, no animation
      },
      image = {
         enabled = true,
         -- Drop `pdf` from the default formats list. Snacks otherwise registers
         -- its own BufReadCmd for `*.pdf` and tries to render the first page
         -- via `magick`, which (a) fails noisily on this box where ImageMagick
         -- isn't installed and (b) collides with our `*.pdf` BufReadCmd in
         -- lua/autocmds.lua that hands PDFs to evince. Keep `pdf` out so PDFs
         -- flow cleanly through our autocmd. (Videos like mp4/mov/avi/mkv/webm
         -- are still here but `magick` can't render them without ffmpeg -- prune
         -- them too if you start seeing similar warnings on those.)
         formats = {
            'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'tiff', 'heic', 'avif',
            'mp4', 'mov', 'avi', 'mkv', 'webm', 'icns',
         },
         doc = {
            -- Inline image rendering inside markdown. `max_width`/`max_height`
            -- are in TERMINAL CELLS (columns/rows), not pixels. The defaults
            -- (80 x 40) shrink every figure to a tiny preview regardless of how
            -- big the source PNG is. Bumped to fill the window — pick large
            -- caps so any reasonable terminal width/height is the actual limit.
            enabled = true,
            inline = true,
            float = true,
            max_width = 300,
            max_height = 200,
         },
         convert = {
            magick = { 'magick' },
         },
      },
   },
   config = function(_, opts)
      -- (Re)define the per-depth rainbow highlight groups used by
      -- snacks.indent.indent.hl. Fired on ColorScheme so theme swaps
      -- (Telescope colorscheme previews, etc.) restore them, and called
      -- once immediately so they exist before snacks first renders.
      local function set_rainbow_hl()
         vim.api.nvim_set_hl(0, 'RainbowRed',    { fg = '#fb4934' }) -- gruvbox red
         vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#fabd2f' }) -- gruvbox yellow
         vim.api.nvim_set_hl(0, 'RainbowBlue',   { fg = '#83a598' }) -- gruvbox blue
         vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#fe8019' }) -- gruvbox orange
         vim.api.nvim_set_hl(0, 'RainbowGreen',  { fg = '#b8bb26' }) -- gruvbox green
         vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#d3869b' }) -- gruvbox purple
         vim.api.nvim_set_hl(0, 'RainbowCyan',   { fg = '#8ec07c' }) -- gruvbox aqua
      end
      vim.api.nvim_create_autocmd('ColorScheme', { callback = set_rainbow_hl })
      set_rainbow_hl()

      require('snacks').setup(opts)
      -- (Snacks sets `_G.Snacks` itself in setup(); we don't add another
      -- global here. Callers should `require('snacks')` rather than relying
      -- on the global so this config isn't coupled to that detail.)
   end,
}
-- vim: ts=3 sts=3 sw=3 et
