return {
   'nvim-telescope/telescope.nvim',
   tag = '0.1.6',
   dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
   },
   config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local builtin = require('telescope.builtin')
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

      -- Load extensions
      pcall(telescope.load_extension, 'ui-select')

      -- Keymaps for common Telescope commands
      vim.keymap.set('n', '<localleader>e', function()
         builtin.find_files({
            prompt_title = 'Find Files (<esc> to quit)',
         })
      end, { desc = 'Telescope: [e]xplorer' })

      vim.keymap.set('n', '<leader>og', function()
         builtin.live_grep({
            prompt_title = 'Grep Files (<esc> to quit)',
         })
      end, { desc = 'Option: Telescope: [g]rep live' })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
