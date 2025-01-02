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
}
-- vim: ts=3 sts=3 sw=3 et
