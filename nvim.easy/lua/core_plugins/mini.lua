-- Add custom key mapping for toggling background
return {
   { -- Collection of various small independent plugins/modules
      'echasnovski/mini.nvim',
      lazy = false, -- mini.basics + mini.hipatterns wire global autocmds; load at startup
      config = function()
         -----------------------------------------------------
         -- <leader>K for more info on cWORD MiniBasics.config
         -----------------------------------------------------
         require('mini.basics').setup({
            options = {
               -- Extra UI features ('winblend', 'cmdheight=0', ...)
               extra_ui = true,
            },
            mappings = {
               -- Window navigation with <C-hjkl>, resize with <C-arrow>
               -- windows = true,
            },
         })
         -- mini.basics enables smartindent globally as part of its `basic = true`
         -- bundle. It's redundant once any indentexpr/treesitter-indent is active
         -- and it triggers a per-open warning in vhda/verilog_systemverilog.vim.
         vim.opt.smartindent = false
         -------------------------------------------------------------
         -- <leader>K for more info on cWORD MiniExtra
         -------------------------------------------------------------
         require('mini.extra').setup()

         -------------------------------------------------------------
         -- <leader>K for more info on cWORD MiniAi-textobject-builtin
         -------------------------------------------------------------
         require('mini.ai').setup({
            custom_textobjects = {
               B = require('mini.extra').gen_ai_spec.buffer(),
               L = require('mini.extra').gen_ai_spec.line(),
            },
         })

         -------------------------------------------------------
         -- <leader>K for more info on cWORD MiniSurround.config
         -------------------------------------------------------
         -- Remapped from the default `s` prefix to `gs` so that bare `s` and
         -- `S` are free for flash.nvim's label-based jump motions (see
         -- lua/plugins/flash.lua). Trade-off: one extra keystroke per
         -- surround op (saiw" -> gsaiw") in exchange for getting flash on
         -- the canonical bindings everyone else's vim uses.
         require('mini.surround').setup({
            mappings = {
               add            = 'gsa', -- add surrounding (visual or operator)
               delete         = 'gsd', -- delete surrounding
               find           = 'gsf', -- find surrounding (to the right)
               find_left      = 'gsF', -- find surrounding (to the left)
               highlight      = 'gsh', -- highlight surrounding
               replace        = 'gsr', -- replace surrounding
               update_n_lines = 'gsn', -- update `n_lines`
               -- These two are NOT prefixes; they're suffix chars used inside
               -- the chord, e.g. `gsfn` = find next, `gsfl` = find prev.
               suffix_last    = 'l',
               suffix_next    = 'n',
            },
         })

         ----------------------------------------------------
         -- <leader>K for more info on cWORD MiniPairs.config
         ----------------------------------------------------
         require('mini.pairs').setup({
            mappings = {
               ['`'] = false,
            },
            disable_filetypes = {
               'TelescopePrompt',
               'NvimTree',
               'neo-tree',
            },
         })

         ------------------------------------------------
         -- <leader>K for more info on cWORD mini.comment
         ------------------------------------------------
         require('mini.comment').setup()

         ---------------------------------------------------
         -- <leader>K for more info on cWORD mini.hipatterns
         ---------------------------------------------------
         require('mini.hipatterns').setup({
            highlighters = {
               -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
               fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
               hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
               todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
               note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
               smdebug = { pattern = '%f[%w]()smdebug()%f[%W]', group = 'MiniHipatternsFixme' },
               smtodo = { pattern = '%f[%w]()smtodo()%f[%W]', group = 'MiniHipatternsHack' },
               sminfo = { pattern = '%f[%w]()sminfo()%f[%W]', group = 'MiniHipatternsNote' },
               smnote = { pattern = '%f[%w]()smnote()%f[%W]', group = 'MiniHipatternsTodo' },

               -- Highlight hex color strings (`#rrggbb`) using that color
               hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
            },
         })
         --  Check out: https://github.com/echasnovski/mini.nvim
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
