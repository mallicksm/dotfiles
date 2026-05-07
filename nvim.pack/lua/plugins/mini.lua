-- echasnovski/mini.nvim -- collection of independent modules; we only enable
-- the ones we use. Setup IS opt-in per module.

require('mini.basics').setup({
   options  = { extra_ui = true },     -- 'winblend', cmdheight=0, etc.
   mappings = {},                       -- (window nav stays via <leader>hjkl in keymaps.lua)
})
-- mini.basics enables smartindent globally as part of `basic = true`. It's
-- redundant once any indentexpr/treesitter-indent is active, and it triggers
-- a per-open warning in vhda/verilog_systemverilog.vim. Turn it back off.
vim.opt.smartindent = false

require('mini.extra').setup()

require('mini.ai').setup({
   custom_textobjects = {
      B = require('mini.extra').gen_ai_spec.buffer(),
      L = require('mini.extra').gen_ai_spec.line(),
   },
})

-- mini.surround on `gs*` prefix (sa/sd/sr/sf/sF/sh moved off the bare `s`
-- prefix so flash.nvim can use `s`/`S` for label-based jump motions).
require('mini.surround').setup({
   mappings = {
      add            = 'gsa', -- add surrounding (visual or operator)
      delete         = 'gsd', -- delete surrounding
      find           = 'gsf', -- find surrounding (to the right)
      find_left      = 'gsF', -- find surrounding (to the left)
      highlight      = 'gsh', -- highlight surrounding
      replace        = 'gsr', -- replace surrounding
      update_n_lines = 'gsn', -- update `n_lines`
      suffix_last    = 'l',   -- suffix INSIDE the chord, e.g. gsfl = find prev
      suffix_next    = 'n',
   },
})

require('mini.pairs').setup({
   mappings          = { ['`'] = false },
   disable_filetypes = { 'TelescopePrompt', 'NvimTree', 'neo-tree' },
})

require('mini.comment').setup()

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
