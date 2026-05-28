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

      -- ---------- snacks.picker bindings (replaces telescope) ----------
      -- <leader>t* family kept identical to the old telescope bindings so
      -- muscle memory survives the swap.
      { '<leader>tf', function() require('snacks').picker.recent({ title = 'Oldfiles (<esc> to quit)' }) end,
        desc = 'Picker: old[f]iles' },
      { '<leader>tr', function() require('snacks').picker.resume() end,
        desc = 'Picker: [r]esume last picker' },
      { '<leader>te', function() require('snacks').picker.files({ title = 'Find Files (<esc> to quit)' }) end,
        desc = 'Picker: [e]xplorer (find_files)' },
      { '<leader>tE', function() require('snacks').picker.files({ title = 'Find Files - all', hidden = true, ignored = true }) end,
        desc = 'Picker: [E]xplorer all files (hidden + ignored)' },
      {
         -- live grep with current-buffer extension pre-seeded as a ripgrep
         -- glob, matching the old telescope-live-grep-args UX. Press <C-g>
         -- inside the picker to toggle the glob filter.
         '<leader>tg',
         function()
            local ext = vim.fn.expand('%:e')
            local args = (ext ~= '' and { '-g', '*.' .. ext }) or nil
            require('snacks').picker.grep({
               title = "Live Grep" .. (ext ~= '' and (" (-g *." .. ext .. ")") or ''),
               args = args,
            })
         end,
         desc = 'Picker: live [g]rep (with rg glob for current ext)',
      },
      { '<leader>tb', function() require('snacks').picker.buffers({ title = 'Buffers (<esc> to quit)' }) end,
        desc = 'Picker: open [b]uffers' },
      -- <leader>td -- frecency-ranked DIRECTORIES from rupa/z's database (~/.z).
      -- <CR> lcds; <C-f> chains into a files-picker scoped to that dir.
      -- Implementation now uses snacks.picker (utils/z_picker.lua).
      { '<leader>td', function() require('utils.z_picker').open() end,
        desc = 'Picker: z [d]irectories (frecency from ~/.z)' },
      { '<leader>po', function() require('snacks').picker.lsp_symbols({ title = 'Document Symbols' }) end,
        desc = 'ls[p]: [o]utline -- document symbols' },

      -- ---------- file explorer ----------
      -- snacks.explorer owns <leader>e since neo-tree was retired (it was too
      -- slow on /project NFS paths; snacks.explorer is noticeably faster
      -- because the fuzzy filter pre-narrows the tree before any IO).
      { '<leader>e', function() require('snacks').explorer({ cwd = vim.fn.getcwd() }) end,
        desc = 'Snacks: [e]xplorer (file browser)' },
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

      -- snacks.words: replaces the hand-rolled CursorHold/CursorMoved
      -- document_highlight autocmd we had in lspconfig.lua. snacks.words
      -- debounces the highlight call and adds ]] / [[ jumps between
      -- references (also `]w` / `[w` per upstream defaults).
      words = {
         enabled  = true,
         debounce = 200, -- ms; default 100. 200 is gentler on big SV files
         notify_jump = false,
         notify_end  = true, -- subtle toast when we wrap around at end of refs
      },

      -- snacks.notifier: replaces rcarriga/nvim-notify as noice's notification
      -- backend. Same top-right popup behavior; no NotifyBackground warning;
      -- no extra dep. Style 'compact' is the closest visual to nvim-notify.
      notifier = {
         enabled       = true,
         style         = 'compact',   -- 'compact' | 'fancy' | 'minimal'
         top_down      = false,        -- stack newest at the bottom (like nvim-notify)
         margin        = { top = 0, right = 1, bottom = 0 },
         level         = vim.log.levels.TRACE, -- snacks decides what to show; noice still routes INFO/DEBUG -> mini
         timeout       = 3000,
      },

      -- snacks.input: replaces vim.ui.input default + the telescope-ui-select
      -- adapter we used to load. Picks up vim.ui.input AND vim.ui.select.
      input = { enabled = true },

      -- snacks.picker: replaces telescope.nvim + ui-select + fzf-native +
      -- live-grep-args entirely. Keymaps are in the `keys` table above.
      picker = {
         enabled = true,
         ui_select = true, -- override vim.ui.select with the picker
         layout = { preset = 'default', preview = true },
         win = {
            input = {
               keys = {
                  -- Close on <esc> in insert mode, matching the old telescope
                  -- behavior bound in plugins/telescope.lua.
                  ['<esc>'] = { 'close', mode = { 'n', 'i' } },
               },
            },
         },
      },

      -- snacks.explorer: file tree, bound to <leader>e in the `keys` table
      -- above. Replaced neo-tree (which was too slow on /project NFS paths).
      explorer = { enabled = true },
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
