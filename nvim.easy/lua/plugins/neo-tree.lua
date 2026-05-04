return {
   'nvim-neo-tree/neo-tree.nvim',
   branch = 'v3.x',
   cmd = { 'Neotree' },
   keys = {
      {
         '<leader>e',
         function()
            require('neo-tree.command').execute({
               action = 'focus',
               source = 'filesystem',
               position = 'left',
               toggle = true,
               reveal_force_cwd = true,
            })
            -- Auto order files by type after open. This reaches into neo-tree
            -- internals (sources.manager + sources.common.commands) so it could
            -- break across plugin updates -- pcall'd so a failure just logs to
            -- :messages instead of breaking the keymap. If this ever fires,
            -- check whether neo-tree v3.x added a public sort_by_type config.
            local ok, err = pcall(function()
               local state = require('neo-tree.sources.manager').get_state('filesystem')
               require('neo-tree.sources.common.commands').order_by_type(state)
            end)
            if not ok then
               vim.notify('[neo-tree] order_by_type failed (API may have moved): ' .. tostring(err), vim.log.levels.WARN)
            end
         end,
         desc = 'Neo-tree: File browser toggle',
      },
      {
         '<leader>ob',
         function()
            require('neo-tree.command').execute({
               action = 'show',
               source = 'buffers',
               position = 'right',
               toggle = true,
               reveal_force_cwd = true,
            })
         end,
         desc = 'Neo-Tree: Buffer list',
      },
   },
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
                  vim.fn.setreg('*', path)
                  vim.notify('Copied to clipboard: (*) ' .. path, vim.log.levels.INFO)
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
