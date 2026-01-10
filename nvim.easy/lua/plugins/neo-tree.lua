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
                     icon = "\u{eb65}",
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
                     icon = "\u{f1183}",
                     color = '#89e051',
                     cterm_color = '113',
                     name = 'bash',
                  },

               },
            })
         end,
      },
      'MunifTanjim/nui.nvim',
   },
   config = function()
      local ntwidth = 55 -- Neo-tree window width
      require('neo-tree').setup({
         window = {
            width = ntwidth,
            mappings = {
               ['s'] = 'open_split',  -- Open in split window
               ['v'] = 'open_vsplit', -- Open in vertical split window
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
               -- Truncate Neo-tree header for filesystem
               name = function(config, node, state)
                  local name = require('neo-tree.sources.common.components').name(config, node, state)
                  if node:get_depth() == 1 then
                     local path = node:get_id()
                     local pathlen = string.len(path)
                     if pathlen > (ntwidth - 8) then
                        name.text = '..' .. string.sub(path, pathlen - (ntwidth - 8))
                     end
                  end
                  return name
               end,
            },
            window = {
               mappings = {
                  ['u'] = 'navigate_up', -- Navigate up one level
                  ['C'] = 'set_root',    -- Set root directory
               },
            },
         },
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
