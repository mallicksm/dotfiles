-- Module-level state for the dim toggle (persists across `\f` presses).
local dim_enabled = false

return {
   'folke/snacks.nvim',
   priority = 1000,
   lazy = false,
   keys = {
      -- <leader>K for more info on cWORD snacks-lazygit-table-of-contents
      { '<leader>gf', function() require('snacks').lazygit.log_file() end, desc = 'Snacks: git log for current file' },
      { '<leader>gl', function() require('snacks').lazygit.log() end,      desc = 'Snacks: git log' },
      { '<leader>gg', function() require('snacks').lazygit() end,          desc = 'Snacks: Lazygit: tui' },
      -- <leader>K for more info on cWORD snacks-terminal-table-of-contents
      { '<leader>T',  function() require('snacks').terminal() end,         desc = 'Snacks: Terminal: bash' },
      -- <leader>K for more info on cWORD snacks-bufdelete-table-of-contents
      { '<leader>bd', function() require('snacks').bufdelete() end,        desc = 'Delete Buffer' },
      -- <leader>K for more info on cWORD snacks-dim-table-of-contents
      {
         '\\f',
         function()
            local snacks = require('snacks')
            if dim_enabled then
               snacks.dim.disable()
               dim_enabled = false
               vim.notify('Dimming disabled', vim.log.levels.INFO)
            else
               snacks.dim()
               dim_enabled = true
               vim.notify('Dimming enabled', vim.log.levels.INFO)
            end
         end,
         desc = "Toggle 'focus/dim'",
      },
   },
   opts = {
      terminal = {
         win = {
            style = 'float',
         },
      },
      image = {
         enabled = true,
         doc = {
            enabled = true,
            inline = true,
            float = true,
            max_width = 80,
            max_height = 40,
         },
         convert = {
            magick = { 'magick' },
         },
      },
   },
   config = function(_, opts)
      require('snacks').setup(opts)
      -- (Snacks sets `_G.Snacks` itself in setup(); we don't add another
      -- global here. Callers should `require('snacks')` rather than relying
      -- on the global so this config isn't coupled to that detail.)
   end,
}
-- vim: ts=3 sts=3 sw=3 et
