return {
   'nvim-telescope/telescope.nvim',
   tag = '0.1.6',
   dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
   },
   config = function()
      require('telescope').setup({
         defaults = {
            mappings = {
               i = { ['<esc>'] = require('telescope.actions').close },
            },
         },
         extensions = {
            ['ui-select'] = {
               require('telescope.themes').get_dropdown(),
            },
         },
      })
      pcall(require('telescope').load_extension('ui-select'))

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<localleader>e', function()
         builtin.find_files({
            prompt_title = 'Find Files (<esc> to quit)',
         })
      end, { desc = 'Telescope: [e]xplorer' })
      vim.keymap.set('n', '<localleader>g', function()
         builtin.live_grep({
            prompt_title = 'Grep Files (<esc> to quit)',
         })
      end, { desc = 'Telescope: [g]rep live' })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
