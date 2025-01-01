return {
   {
      'ThePrimeagen/harpoon',
      branch = 'harpoon2',
      dependencies = { 'nvim-lua/plenary.nvim' },

      config = function()
         local harpoon = require('harpoon')
         harpoon:setup({
            settings = {
               -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
               save_on_toggle = false,
            },
         })
         harpoon:extend({
            UI_CREATE = function(cx)
               vim.keymap.set('n', 'v', function()
                  harpoon.ui:select_menu_item({ vsplit = true })
               end, { buffer = cx.bufnr })

               vim.keymap.set('n', 's', function()
                  harpoon.ui:select_menu_item({ split = true })
               end, { buffer = cx.bufnr })

               vim.keymap.set('n', 't', function()
                  harpoon.ui:select_menu_item({ tabedit = true })
               end, { buffer = cx.bufnr })
            end,
         })

      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
