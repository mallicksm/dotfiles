return {
   'nvim-neo-tree/neo-tree.nvim',
   branch = 'v3.x',
   dependencies = {
      'nvim-lua/plenary.nvim',
      {
         'nvim-tree/nvim-web-devicons',
         config = function()
            require('nvim-web-devicons').setup({
               override_by_extension = {
                  ['f'] = {
                     icon = '',
                     color = '#4285f4',
                     name = 'f',
                  },
                  ['tdf'] = {
                     icon = '󰃰',
                     color = '#89e051',
                     name = 'tdf',
                  },
                  ['cmm'] = {
                     icon = '⚒️',
                     color = '#89e051',
                     name = 'cmm',
                  },
                  ['qel'] = {
                     icon = '󰛓',
                     color = '#e37933',
                     name = 'qel',
                  },
                  ['bash'] = {
                     icon = '󱆃',
                     color = '#89e051',
                     cterm_color = '113',
                     name = 'bash',
                  },
               },
            })
         end,
      },
      'MunifTanjim/nui.nvim',
      '3rd/image.nvim',
   },
   config = function()
      require('neo-tree').setup({
         window = {
            width = 40,
            mappings = {
               ['s'] = 'open_split',
               ['v'] = 'open_vsplit',
               ['Y'] = {
                  function(state)
                     local node = state.tree:get_node()
                     local path = node:get_id()
                     print('Copied to clipboard: ' .. path)
                     vim.fn.setreg('*', path)
                  end,
                  desc = 'Copy Path to Clipboard',
               },
            },
         },
         filesystem = {
            window = {
               mappings = {
                  ['u'] = 'navigate_up',
                  ['C'] = 'set_root',
               },
            },
         },
      })
      vim.keymap.set('n', '<leader>e', ':Neotree reveal_force_cwd toggle<cr>', { desc = 'Neo-tree: File browser toggle' })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
