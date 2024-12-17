return {
   { -- Collection of various small independent plugins/modules
      'echasnovski/mini.nvim',
      config = function()
         -- <leader>K for more info on cWORD MiniAi-textobject-builtin
         require('mini.ai').setup()

         -- <leader>K for more info on cWORD MiniSurround.config
         require('mini.surround').setup()

         -- <leader>K for more info on cWORD MiniPairs.config
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
         --  Check out: https://github.com/echasnovski/mini.nvim
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
