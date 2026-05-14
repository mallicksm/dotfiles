-- neo-tree.nvim (branch v3.x) -- file/buffer tree.
--
-- Full-feature mode: libuv watcher on (auto-refresh) + follow_current_file.
-- The original slowness on /project/bugatti was caused by git's "dubious
-- ownership" check failing per directory probe; fixed at the system level
-- via `git config --global --add safe.directory /project/bugatti`. With that
-- in place neo-tree opens fast even with the watcher on. If you ever land
-- on an NFS path where it's slow again, flip use_libuv_file_watcher = false.
local ntwidth = 55

require('neo-tree').setup({
   window = {
      width    = ntwidth,
      mappings = {
         ['s'] = 'open_split',
         ['v'] = 'open_vsplit',
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
      use_libuv_file_watcher = true,
      follow_current_file    = { enabled = true },
      scan_mode              = 'shallow',
      async_directory_scan   = 'always',
      components = {
         -- (1) truncate the depth-1 root header so long paths fit the window
         -- (2) color filenames per-extension via nvim-web-devicons hl group
         --     (mimics `ls --color`); preserves NeoTreeGit* hl on changed files
         name = function(config, node, state)
            local name = require('neo-tree.sources.common.components').name(config, node, state)
            if node:get_depth() == 1 then
               local path    = node:get_id()
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
            ['u'] = 'navigate_up',
            ['C'] = 'set_root',
         },
      },
   },
})

-- Auto-order-by-type after open. Reaches into neo-tree internals so it could
-- break across plugin updates -- pcall'd, failure logs to :messages instead.
local function order_by_type_safely()
   local ok, err = pcall(function()
      local state = require('neo-tree.sources.manager').get_state('filesystem')
      require('neo-tree.sources.common.commands').order_by_type(state)
   end)
   if not ok then
      vim.notify('[neo-tree] order_by_type failed (API may have moved): ' .. tostring(err), vim.log.levels.WARN)
   end
end

vim.keymap.set('n', '<leader>e', function()
   require('neo-tree.command').execute({
      action           = 'focus',
      source           = 'filesystem',
      position         = 'left',
      toggle           = true,
      reveal_force_cwd = true,
   })
   order_by_type_safely()
end, { desc = 'Neo-tree: File browser toggle' })

-- Lives under <leader>v* alongside the other "buffer" commands.
-- <leader>vb = raw :ls dump, <leader>vB = fancy neo-tree side panel.
vim.keymap.set('n', '<leader>vB', function()
   require('neo-tree.command').execute({
      action           = 'show',
      source           = 'buffers',
      position         = 'right',
      toggle           = true,
      reveal_force_cwd = true,
   })
end, { desc = 'Vim: [B]uffer list (neo-tree GUI panel)' })

-- vim: ts=3 sts=3 sw=3 et
