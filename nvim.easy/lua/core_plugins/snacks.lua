return {
   'folke/snacks.nvim',
   priority = 1000,
   lazy = false,
   keys = {
      -- <leader>K for more info on cWORD snacks-lazygit-table-of-contents
      { '<leader>gf', function() require('snacks').lazygit.log_file() end, desc = 'Snacks: git log for current file' },
      { '<leader>gl', function() require('snacks').lazygit.log() end,      desc = 'Snacks: git log' },
      { '<leader>gg', function() require('snacks').lazygit() end,          desc = 'Snacks: Lazygit: tui' },
      -- Lives under <leader>v* alongside other "vim utilities" -- moved off
      -- bare <leader>T after the toggle family migrated to <leader>T*.
      { '<leader>vt',  function() require('snacks').terminal() end,        desc = 'Vim: floating [t]erminal (snacks)' },
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
      require('snacks').setup(opts)
      -- (Snacks sets `_G.Snacks` itself in setup(); we don't add another
      -- global here. Callers should `require('snacks')` rather than relying
      -- on the global so this config isn't coupled to that detail.)
   end,
}
-- vim: ts=3 sts=3 sw=3 et
