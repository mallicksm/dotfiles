-- echasnovski/mini.nvim -- collection of independent modules; we only enable
-- the ones we use. Setup IS opt-in per module.

require('mini.basics').setup({
   options  = { extra_ui = true },     -- 'winblend', cmdheight=0, etc.
   mappings = {
      -- (window nav stays via <leader>hjkl in keymaps.lua)
      -- Disable the entire `\X` option-toggle family (\w \h \c \r \n \l \i \s
      -- \d \b \C). We have our own <leader>t* equivalents in keymaps.lua
      -- (toggle wrap / hlsearch / cursorline / relnum / case). Empty string
      -- here = "do not install any of the option_toggle mappings".
      option_toggle_prefix = '',
   },
})
-- mini.basics enables smartindent globally as part of `basic = true`. It's
-- redundant once any indentexpr/treesitter-indent is active, and it triggers
-- a per-open warning in vhda/verilog_systemverilog.vim. Turn it back off.
vim.opt.smartindent = false

require('mini.extra').setup()

-- mini.icons -- replaces nvim-tree/nvim-web-devicons. We set up mini.icons here
-- AND call mock_nvim_web_devicons() so every other plugin that still does
-- require('nvim-web-devicons') (neo-tree, lualine, snacks, render-markdown,
-- ...) keeps working transparently. One icons source, one set of highlight
-- groups (MiniIconsRed / MiniIconsBlue / ...).
--
-- The per-extension overrides below mirror what the old devicons.lua had:
-- '.f' (verilog include), '.tdf' (tcl-driven flows), '.cmm' (Trace32),
-- '.qel' (Cadence emulator), '.bash'.
require('mini.icons').setup({
   extension = {
      ['f']    = { glyph = '',  hl = 'MiniIconsBlue'   },
      ['tdf']  = { glyph = '', hl = 'MiniIconsGreen'  },
      ['cmm']  = { glyph = '⚒', hl = 'MiniIconsGreen'  },
      ['qel']  = { glyph = '󰛓', hl = 'MiniIconsOrange' },
      ['bash'] = { glyph = '', hl = 'MiniIconsGreen'  },
   },
})
require('mini.icons').mock_nvim_web_devicons()

local ai = require('mini.ai')
local extra = require('mini.extra')
local ts = ai.gen_spec.treesitter
local function ts_textobject(captures)
   local spec = ts(captures)
   return function(ai_type, id, opts)
      pcall(function() vim.treesitter.get_parser(0):parse() end)
      return spec(ai_type, id, opts)
   end
end
ai.setup({
   n_lines = 10000, -- SV modules/classes are often huge; needed for TS textobjects
   custom_textobjects = {
      B = extra.gen_ai_spec.buffer(),
      L = extra.gen_ai_spec.line(),
      f = ts_textobject({ a = '@function.outer',  i = '@function.inner' }),
      m = ts_textobject({ a = '@module.outer',    i = '@module.inner' }),
      c = ts_textobject({ a = '@class.outer',     i = '@class.inner' }),
      a = ts_textobject({ a = '@parameter.outer', i = '@parameter.inner' }),
      b = ts_textobject({ a = '@block.outer',     i = '@block.inner' }),
      u = ts_textobject({ a = '@instance.outer',  i = '@instance.inner' }),
      n = ts_textobject({ a = '@field.outer',     i = '@field.inner' }),
   },
})

-- tpope/vim-surround-style chords (see :h MiniSurround-vim-surround-config).
require('mini.surround').setup({
   mappings = {
      add = 'ys',
      delete = 'ds',
      find = '',
      find_left = '',
      highlight = '',
      replace = 'cs',
      suffix_last = '',
      suffix_next = '',
   },
   search_method = 'cover_or_next',
})
vim.keymap.del('x', 'ys')
vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], {
   silent = true,
   desc = 'Surround visual selection (vim-surround S)',
})
vim.keymap.set('n', 'yss', 'ys_', { remap = true, desc = 'Surround current line (yss)' })

require('mini.pairs').setup({
   mappings          = { ['`'] = false },
   disable_filetypes = { 'snacks_picker_input' }, -- don't auto-pair inside snacks picker prompts
})

require('mini.comment').setup()

-- mini.clue -- replaces folke/which-key.nvim. Pops a small floating window
-- after `delay` ms when a registered trigger key has been pressed and there
-- are pending child keymaps. Reads every vim.keymap.set() description
-- automatically, so we only need to declare GROUP LABELS (e.g.
-- "<Leader>g = +Git") and the trigger list -- leaf keys come along for free.
--
-- Notable diffs vs which-key:
--  - no per-group colored icons; clue is fg-only (visual downgrade).
--  - no `hidden = true` list needed; leaf keys never trigger a popup.
--  - no "register a keymap here" path; <leader>gb moves into gitsigns.lua.
do
   local miniclue = require('mini.clue')
   miniclue.setup({
      window = {
         delay  = 200, -- ms; matches the which-key feel we had
         config = {
            border = 'rounded',
            anchor = 'SW', -- bottom-left (default SE = bottom-right)
            row = 'auto',
            col = 'auto',
            width = 60, -- default is 30; double for longer map descs
         },
      },
      triggers = {
         -- Leader (n + x = normal AND visual-mode leader chains)
         { mode = 'n', keys = '<Leader>' },
         { mode = 'x', keys = '<Leader>' },

         -- `g` chain. Built-in `g*` + gc* (mini.comment). Surround is ys/ds/cs.
         { mode = 'n', keys = 'g' },
         { mode = 'x', keys = 'g' },

         -- `z` chain (folds, scroll)
         { mode = 'n', keys = 'z' },
         { mode = 'x', keys = 'z' },

         -- Marks
         { mode = 'n', keys = "'" },
         { mode = 'n', keys = '`' },
         { mode = 'x', keys = "'" },
         { mode = 'x', keys = '`' },

         -- Registers. Insert-mode <C-r> is intentionally NOT a trigger here:
         -- we own that key with snacks.picker.registers (see lua/keymaps.lua),
         -- and a mini.clue popup competing with the picker doubles up
         -- "helpers". Cmdline-mode <C-r> stays a trigger -- snacks isn't bound
         -- there, so the register clue is the only hint you get for
         -- :s/foo/<C-r>... and similar.
         { mode = 'n', keys = '"' },
         { mode = 'x', keys = '"' },
         { mode = 'c', keys = '<C-r>' },

         -- Window commands
         { mode = 'n', keys = '<C-w>' },

         -- Bracket motions
         { mode = 'n', keys = '[' },
         { mode = 'n', keys = ']' },
         { mode = 'x', keys = '[' },
         { mode = 'x', keys = ']' },

         -- Built-in insert-mode completion (i_CTRL-X)
         { mode = 'i', keys = '<C-x>' },
      },
      clues = {
         -- Built-in clue generators document Vim's own multi-key chains.
         miniclue.gen_clues.builtin_completion(),
         miniclue.gen_clues.g(),
         miniclue.gen_clues.marks(),
         miniclue.gen_clues.registers(),
         miniclue.gen_clues.windows(),
         miniclue.gen_clues.z(),
         miniclue.gen_clues.square_brackets(),

         -- Leader-prefix GROUP labels (mirroring the old which-key spec).
         -- Leading nerd-font glyph + `+` (= "group, not leaf"). mini.clue
         -- only has ONE highlight group for ALL group descs
         -- (MiniClueDescGroup); glyphs come back, per-group colors do not.
         -- The set_clue_hl() block below retunes MiniClueDescGroup to a
         -- saturated gruvbox yellow so it pops vs leaf descs.
         { mode = 'n', keys = '<Leader>d', desc = '󰃤  +[D]ap' },
         { mode = 'n', keys = '<Leader>g', desc = '  +[G]it' },
         { mode = 'n', keys = '<Leader>p', desc = '󰒋  +ls[p]' },
         { mode = 'n', keys = '<Leader>t', desc = '󰍉  +[t]ools (picker)' },
         { mode = 'n', keys = '<Leader>s', desc = '󰫖  +[S]earch (kaleido)' },
         { mode = 'n', keys = '<Leader>H', desc = '󰀢  +[H]arpoon' },
         { mode = 'n', keys = '<Leader>v', desc = '󰈈  +[V]im' },
         { mode = 'n', keys = '<Leader>V', desc = '󰈉  +[V]im tools' },

         -- mini.surround (tpope / vim-surround style)
         { mode = 'n', keys = 'ys', desc = '󰅪  +surround [y]ank/add' },
         { mode = 'n', keys = 'ds', desc = '󰅪  delete surround' },
         { mode = 'n', keys = 'cs', desc = '󰅪  change surround' },
         { mode = 'x', keys = 'S',  desc = '󰅪  surround visual selection' },
      },
   })

   -- Retune the five MiniClue* highlight groups for gruvbox. Re-fired on
   -- ColorScheme so :Telescope colorscheme previews etc. don't wipe them.
   local function set_clue_hl()
      vim.api.nvim_set_hl(0, 'MiniClueDescGroup',           { fg = '#fabd2f', bold = true }) -- gruvbox bright_yellow -- groups pop
      vim.api.nvim_set_hl(0, 'MiniClueDescSingle',          { fg = '#ebdbb2' })              -- gruvbox fg1 (cream) -- leaves
      vim.api.nvim_set_hl(0, 'MiniClueNextKey',             { fg = '#83a598', bold = true }) -- gruvbox bright_blue -- key letter
      vim.api.nvim_set_hl(0, 'MiniClueNextKeyWithPostkeys', { fg = '#fb4934', bold = true }) -- gruvbox bright_red -- key w/ postkeys
      vim.api.nvim_set_hl(0, 'MiniClueSeparator',           { fg = '#928374' })              -- gruvbox gray -- ' › ' separator
   end
   set_clue_hl()
   vim.api.nvim_create_autocmd('ColorScheme', {
      group    = vim.api.nvim_create_augroup('user-mini-clue-hl', { clear = true }),
      callback = set_clue_hl,
      desc     = 'mini.clue: re-apply gruvbox highlights after theme switch',
   })
end

require('mini.hipatterns').setup({
   highlighters = {
      fixme    = { pattern = '%f[%w]()FIXME()%f[%W]',   group = 'MiniHipatternsFixme' },
      hack     = { pattern = '%f[%w]()HACK()%f[%W]',    group = 'MiniHipatternsHack'  },
      todo     = { pattern = '%f[%w]()TODO()%f[%W]',    group = 'MiniHipatternsTodo'  },
      note     = { pattern = '%f[%w]()NOTE()%f[%W]',    group = 'MiniHipatternsNote'  },
      smdebug  = { pattern = '%f[%w]()smdebug()%f[%W]', group = 'MiniHipatternsFixme' },
      smtodo   = { pattern = '%f[%w]()smtodo()%f[%W]',  group = 'MiniHipatternsHack'  },
      sminfo   = { pattern = '%f[%w]()sminfo()%f[%W]',  group = 'MiniHipatternsNote'  },
      smnote   = { pattern = '%f[%w]()smnote()%f[%W]',  group = 'MiniHipatternsTodo'  },
      hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
   },
})

-- vim: ts=3 sts=3 sw=3 et
