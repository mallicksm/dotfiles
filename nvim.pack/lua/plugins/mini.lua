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

-- mini.surround on upstream defaults: sa/sd/sr/sf/sF/sh on the `s` prefix.
-- Trade-off vs. our old `gs*` setup: bare `s` (vim's substitute-char) now
-- waits `timeoutlen` (300ms) before firing because vim checks whether
-- you'll continue with a/d/r/f/F/h. If the lag annoys you, drop timeoutlen
-- in options.lua or revert to `gs*`. Most folks use `cl` for substitute
-- anyway, so the lag is rarely felt.
require('mini.surround').setup()

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
