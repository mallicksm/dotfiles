return {
   { -- Collection of various small independent plugins/modules
      'echasnovski/mini.nvim',
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
               windows = true,
            },
         })

         -------------------------------------------------------------
         -- <leader>K for more info on cWORD MiniAi-textobject-builtin
         -------------------------------------------------------------
         require('mini.ai').setup()

         -------------------------------------------------------
         -- <leader>K for more info on cWORD MiniSurround.config
         -------------------------------------------------------
         require('mini.surround').setup()

         ----------------------------------------------------
         -- <leader>K for more info on cWORD MiniPairs.config
         ----------------------------------------------------
         require('mini.pairs').setup({
            mappings = {
               ["`"] = false,
            },
            disable_filetypes = {
               'TelescopePrompt',
               'NvimTree',
               'neo-tree'
            },
         })

         ------------------------------------------------
         -- <leader>K for more info on cWORD mini.comment
         ------------------------------------------------
         require('mini.comment').setup()

         ------------------------------------------------
         -- <leader>K for more info on cWORD mini.starter
         ------------------------------------------------
         require('mini.starter').setup({
            evaluate_single = true,
            header = table.concat({
               "██████ ███████╗██╗   ██╗██╗███╗   ███╗",
               "██╔══  ╚══███╔╝██║   ██║██║████╗ ████║",
               "█████    ███╔╝ ██║   ██║██║██╔████╔██║",
               "██╔══   ███╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║",
               "██████ ███████╗ ╚████╔╝ ██║██║ ╚═╝ ██║",
               "╚════╝ ╚══════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
            }, "\n"
            ),
         })

         ---------------------------------------------------
         -- <leader>K for more info on cWORD mini.hipatterns
         ---------------------------------------------------
         require('mini.hipatterns').setup({
            highlighters = {
               -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
               fixme     = { pattern = '%f[%w]()FFIXME()%f[%W]', group = 'MiniHipatternsFixme' },
               hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
               todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
               note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

               -- Highlight hex color strings (`#rrggbb`) using that color
               hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
            },

         })
         --  Check out: https://github.com/echasnovski/mini.nvim
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
