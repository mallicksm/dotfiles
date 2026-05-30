-- Shared dashboard action: :lcd + open snacks.picker.files for `dir`. The
-- isdirectory() stat is intentionally deferred to keypress time -- doing it
-- inside the dashboard section generators costs one NFS metadata round-trip
-- per row, and /project/* is on NFS, so it blocked the first paint for
-- seconds. (Symptom: blank screen for 2-4s; press any key -> instant render.)
-- Defining at file scope so both the Workspaces and Projects generators
-- share one closure factory.
local function dashboard_open_dir(label, dir)
   return function()
      if vim.fn.isdirectory(dir) == 0 then
         vim.notify(string.format('[%s] not a directory: %s', label, dir), vim.log.levels.WARN)
         return
      end
      vim.cmd.lcd(dir)
      require('snacks').picker.files({ cwd = dir, title = label .. ' files' })
   end
end

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

      -- ---------- [e]xplorer / file pickers (was <leader>t* / lone <leader>e) ----------
      { '<leader>ee', function() require('snacks').explorer({ cwd = vim.fn.getcwd() }) end,
        desc = '[e]xplorer: file [e]browser (snacks tree)' },
      { '<leader>eo', function() require('snacks').picker.recent({ title = 'Oldfiles (<esc> to quit)' }) end,
        desc = '[e]xplorer: [o]ld files' },
      { '<leader>ef', function() require('snacks').picker.files({ title = 'Find Files (<esc> to quit)' }) end,
        desc = '[e]xplorer: [f]ind files' },
      { '<leader>eF', function() require('snacks').picker.files({ title = 'Find Files - all', hidden = true, ignored = true }) end,
        desc = '[e]xplorer: [F]ind files (hidden + ignored)' },
      {
         -- live grep with current-buffer extension pre-seeded as a ripgrep
         -- glob, matching the old telescope-live-grep-args UX. Press <C-g>
         -- inside the picker to toggle the glob filter.
         '<leader>eg',
         function()
            local ext = vim.fn.expand('%:e')
            local args = (ext ~= '' and { '-g', '*.' .. ext }) or nil
            require('snacks').picker.grep({
               title = "Live Grep" .. (ext ~= '' and (" (-g *." .. ext .. ")") or ''),
               args = args,
            })
         end,
         desc = '[e]xplorer: live [g]rep (rg glob for current ext)',
      },
      { '<leader>eb', function() require('snacks').picker.buffers({ title = 'Buffers (<esc> to quit)' }) end,
        desc = '[e]xplorer: open [b]uffers' },
      -- <leader>ed -- frecency-ranked DIRECTORIES from rupa/z's database (~/.z).
      { '<leader>ed', function() require('utils.z_picker').open() end,
        desc = '[e]xplorer: z [d]irectories (frecency from ~/.z)' },
      { '<leader>er', function() require('snacks').picker.resume() end,
        desc = '[e]xplorer: [r]esume last picker' },
      { '<leader>co', function() require('snacks').picker.lsp_symbols({ title = 'Document Symbols' }) end,
        desc = '[c]ode: [o]utline -- document symbols' },

      -- ---------- dashboard reopener ----------
      -- snacks.dashboard auto-opens when nvim launches with no file argument.
      -- This binding re-opens it on demand (e.g. after :bd-ing all buffers
      -- you want to land back on the project picker without restarting nvim).
      { '<leader>D', function() require('snacks').dashboard() end,
        desc = 'Snacks: open [D]ashboard' },
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

      -- snacks.explorer: file tree, bound to <leader>ee in the `keys` table
      -- above. Replaced neo-tree (which was too slow on /project NFS paths).
      explorer = { enabled = true },

      -- snacks.dashboard: the start page. Shows when nvim opens with no
      -- file argument (the user's `vi` function passes -O/-p only when
      -- files are given, so bare `vi` lands here).
      --
      -- The "Projects" section is env-var-driven: each entry below is only
      -- shown if the corresponding $VAR is set AND points at an existing
      -- directory. Unset / missing paths are silently skipped -- no
      -- broken-link rows. Pressing a project key :lcds into the dir AND
      -- opens snacks.picker.files scoped there.
      dashboard = {
         enabled = true,
         width   = 52, -- matches the EZ Nvim ASCII header width; tighter column
         -- Left-align every line type within the dashboard column (defaults
         -- center the header/footer). With width=52 this gives a consistent
         -- vertical edge at the dashboard's left margin, which the user
         -- found visually steadier than the centered-everything default.
         formats = {
            header = { '%s', align = 'left' },
            footer = { '%s', align = 'left' },
         },
         preset = {
            -- "EZ Nvim" ASCII art. Single-color (SnacksDashboardHeader -> Title).
            header = table.concat({
               '',
               '███████╗███████╗   ███╗   ██╗██╗   ██╗██╗███╗   ███╗',
               '██╔════╝╚══███╔╝   ████╗  ██║██║   ██║██║████╗ ████║',
               '█████╗    ███╔╝    ██╔██╗ ██║██║   ██║██║██╔████╔██║',
               '██╔══╝   ███╔╝     ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║',
               '███████╗███████╗   ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║',
               '╚══════╝╚══════╝   ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝',
               '            h j k l   —   no mouse required',
               '',
            }, '\n'),
            -- Slim action list: just the two the user reaches for daily.
            -- (Find File / Find Text / New File / Edit Config / Lazy were
            -- removed -- the picker keys <leader>ef/eg/eo cover them.)
            keys = {
               { icon = ' ', key = 'r', desc = 'Recent Files', action = function() require('snacks').picker.recent() end },
               { icon = ' ', key = 'q', desc = 'Quit',         action = ':qa' },
            },
         },
         sections = {
            { section = 'header' },

            -- Workspaces: hardcoded paths to bugatti / sparews workspace
            -- roots. NO fs probe in the generator -- the dir check lives in
            -- dashboard_open_dir() (file-scope, above). A workspace that gets
            -- deleted simply shows a "[label] not a directory" toast on
            -- keypress instead of blocking the first paint with an NFS stat.
            function()
               local workspaces = {
                  { key = '0', label = 'bugatti_ws0', dir = '/project/bugatti/users/smallick/bugatti_ws0' },
                  { key = '1', label = 'bugatti_ws1', dir = '/project/bugatti/users/smallick/bugatti_ws1' },
                  { key = '2', label = 'sparews/ws0', dir = '/project/bugatti/users/smallick/sparews/ws0' },
                  { key = '3', label = 'sparews/ws1', dir = '/project/bugatti/users/smallick/sparews/ws1' },
               }
               local items = { title = 'Workspaces', padding = 1 }
               for _, w in ipairs(workspaces) do
                  table.insert(items, {
                     icon = '󰉋 ', key = w.key, desc = w.label,
                     action = dashboard_open_dir(w.label, w.dir),
                  })
               end
               return items
            end,

            -- Projects: env-var-driven shortcuts. We gate on env-var
            -- presence (free string check) but NOT on isdirectory(), same
            -- NFS-stat reason as Workspaces above.
            function()
               local projects = {
                  { key = 'e', label = 'ETH_MAC',  env = 'ETH_MAC_DIR'  },
                  { key = 'p', label = 'PCS100G',  env = 'PCS100G_DIR'  },
                  { key = 'P', label = 'PCS800G',  env = 'PCS800G_DIR'  },
                  { key = 'M', label = 'MAC100G',  env = 'MAC100G_DIR'  },
                  { key = 's', label = 'SERDES',   env = 'PMD_RTL_DIR'  },
               }
               local items = { title = 'Projects', padding = 1 }
               for _, p in ipairs(projects) do
                  local dir = vim.env[p.env]
                  if dir and dir ~= '' then
                     table.insert(items, {
                        icon = '󰍛 ', key = p.key, desc = p.label,
                        action = dashboard_open_dir(p.label, dir),
                     })
                  end
               end
               return #items > 0 and items or nil
            end,

            -- Documentation: reference material under $HOME/docs/. Same
            -- deferred-isdirectory pattern as Workspaces/Projects -- no NFS
            -- stat during render. Add more entries here as needed.
            function()
               local docs = {
                  { key = 'd', label = 'Latest_docs', dir = vim.env.HOME .. '/docs/Latest_docs' },
               }
               local items = { title = 'Documentation', padding = 1 }
               for _, d in ipairs(docs) do
                  table.insert(items, {
                     icon = '󰂺 ', key = d.key, desc = d.label,
                     action = dashboard_open_dir(d.label, d.dir),
                  })
               end
               return items
            end,

            { section = 'keys', gap = 1, padding = 1 },
            { section = 'startup' },
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
