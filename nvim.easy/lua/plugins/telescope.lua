return {
   'nvim-telescope/telescope.nvim',
   version = '*',
   dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
   },
   config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local themes = require('telescope.themes')

      -- Telescope setup
      telescope.setup({
         defaults = {
            mappings = {
               i = {
                  ['<esc>'] = actions.close, -- Close Telescope with <esc>
               },
            },
         },
         extensions = {
            ['ui-select'] = {
               themes.get_dropdown(), -- Dropdown theme for `ui-select`
            },
         },
      })

      pcall(telescope.load_extension, 'ui-select')
      pcall(telescope.load_extension, 'fzf')
   end,
}
-- vim: ts=3 sts=3 sw=3 et
