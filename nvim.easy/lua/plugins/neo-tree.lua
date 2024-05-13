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
      local ntwidth = 35
      require('neo-tree').setup({
         window = {
            width = ntwidth,
            mappings = {
               ['s'] = 'open_split',
               ['v'] = 'open_vsplit',
               ['y'] = {
                  function(state)
                     local node = state.tree:get_node()
                     local path = node:get_id()
                     print('Copied to clipboard: (*) ' .. path)
                     vim.fn.setreg('*', path)
                  end,
                  desc = 'Copy Path to Clipboard',
               },
            },
         },
         filesystem = {
            components = {
               --[[ truncate neo-tree header ]]
               name = function(config, node, state)
                  local name = require('neo-tree.sources.common.components').name(config, node, state)
                  if node:get_depth() == 1 then
                     local path = node:get_id()
                     local pathlen = string.len(path)
                     if pathlen > (ntwidth - 8) then
                        name.text = '..' .. string.sub(path, pathlen - (ntwidth - 8))
                     end
                     name.text = name.text
                  end
                  return name
               end,
            },
            window = {
               mappings = {
                  ['u'] = 'navigate_up',
                  ['C'] = 'set_root',
               },
            },
         },
      })
      vim.keymap.set('n', '<leader>e', function()
         require('neo-tree.command').execute({
            action = 'focus',
            source = 'filesystem',
            position = 'left',
            toggle = true,
            reveal_force_cwd = true,
         })
         --[[ auto execute ot which is order by type ]]
         local state = require('neo-tree.sources.manager').get_state("filesystem")
         require('neo-tree.sources.common.commands').order_by_type(state)
      end, { desc = 'Neo-tree: File browser toggle' })
      vim.keymap.set('n', '<leader>b', function()
         require('neo-tree.command').execute({
            action = 'show',
            source = 'buffers',
            position = 'right',
            toggle = true,
            reveal_force_cwd = true,
         })
      end, { desc = 'Neo-tree: Buffer browser toggle' })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
