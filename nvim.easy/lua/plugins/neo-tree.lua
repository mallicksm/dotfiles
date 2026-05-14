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
            -- Auto order files by type after open. Reaches into neo-tree
            -- internals (sources.manager + sources.common.commands) so it
            -- could break across plugin updates -- pcall'd so a failure just
            -- logs to :messages instead of breaking the keymap. If this ever
            -- fires, check whether neo-tree v3.x added a public sort_by_type.
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
         -- Lives under <leader>v* alongside the other "buffer" commands.
         -- <leader>vb = raw :ls dump, <leader>vB = fancy neo-tree side panel.
         '<leader>vB',
         function()
            require('neo-tree.command').execute({
               action = 'show',
               source = 'buffers',
               position = 'right',
               toggle = true,
               reveal_force_cwd = true,
            })
         end,
         desc = 'Vim: [B]uffer list (neo-tree GUI panel)',
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
            -- Full-feature mode: live file watcher + follow current buffer.
            -- The original slowness on /project/bugatti was caused by git's
            -- "dubious ownership" check failing per directory probe; fixed by
            -- adding /project/bugatti to ~/.gitconfig safe.directory. With
            -- that fix in place, neo-tree opens fast even with the watcher
            -- on. If you ever land on an NFS path where it's slow again, the
            -- inotify setup is the most likely culprit -- flip
            -- use_libuv_file_watcher = false here.
            use_libuv_file_watcher = true,
            follow_current_file    = { enabled = true },
            -- Lazy-scan: only scan visible (expanded) directories, never
            -- pre-walk the whole tree. This is the default but make it
            -- explicit so it survives upstream config changes.
            scan_mode = 'shallow',
            -- Async directory scan so first paint never blocks on slow IO.
            async_directory_scan = 'always',
            components = {
               -- Custom name component:
               --   1. Truncate the depth-1 root header so long paths fit the window.
               --   2. Color the filename text per-extension (mimics `ls --color`).
               --      We borrow nvim-web-devicons' icon highlight group
               --      (DevIconLua, DevIconPython, ...), which is the same group
               --      driving the leading icon -- so name + icon stay color-synced.
               --      Only applied to regular files past depth 1, and only when
               --      neo-tree's default highlight isn't one of the NeoTreeGit*
               --      groups (so modified / staged / untracked files keep their
               --      git status color, which we want to be more salient than
               --      filetype color).
               name = function(config, node, state)
                  local name = require('neo-tree.sources.common.components').name(config, node, state)
                  if node:get_depth() == 1 then
                     local path = node:get_id()
                     local pathlen = string.len(path)
                     if pathlen > (ntwidth - 8) then
                        name.text = '..' .. string.sub(path, pathlen - (ntwidth - 8))
                     end
                  end
                  if node.type == 'file' and node:get_depth() > 1
                     and (not name.highlight or not tostring(name.highlight):find('^NeoTreeGit'))
                  then
                     local web = require('nvim-web-devicons')
                     local _, hl = web.get_icon(node.name, vim.fn.fnamemodify(node.name, ':e'), { default = true })
                     if hl then name.highlight = hl end
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
