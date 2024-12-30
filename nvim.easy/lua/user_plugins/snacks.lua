local dim_enabled = false
return {
   "folke/snacks.nvim",
   priority = 1000,
   lazy = false,
   opts = {
      terminal = {
         win = {
            style = 'float',
         },
      }
   },
   config = function(_, opts)
      require('snacks').setup(opts)
      _G.Snacks = require("snacks")
   end,
   keys = {
         -- <leader>K for more info on cWORD snacks-lazygit-table-of-contents
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Snacks: git log for current file" },
      { "<leader>gl", function() Snacks.lazygit.log() end,      desc = "Snacks: git log" },
      { "<leader>ol", function() Snacks.lazygit() end,          desc = "Snacks: Lazygit: tui" },
         -- <leader>K for more info on cWORD snacks-terminal-table-of-contents
      { "<leader>ot", function() Snacks.terminal() end,         desc = "Snacks: Terminal: bash" },
         -- <leader>K for more info on cWORD snacks-bufdelete-table-of-contents
      { "<leader>bd", function() Snacks.bufdelete() end,        desc = "Delete Buffer" },
      {
         -- <leader>K for more info on cWORD snacks-dim-table-of-contents
         "\\f",
         function()
            if dim_enabled then
               Snacks.dim.disable()
               dim_enabled = false
               vim.notify("Dimming disabled", vim.log.levels.INFO)
            else
               Snacks.dim()
               dim_enabled = true
               vim.notify("Dimming enabled", vim.log.levels.INFO)
            end
         end,
         desc = "Toggle 'focus/dim'"
      },
   },
}
-- vim: ts=3 sts=3 sw=3 et
