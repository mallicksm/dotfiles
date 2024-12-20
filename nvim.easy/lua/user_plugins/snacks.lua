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
   keys = {
      { "<leader>gf", function() Snacks.lazygit.log_file() end,      desc = "Lazygit: for current file" },
      { "<leader>gl", function() Snacks.lazygit.log() end,           desc = "Lazygit: log" },
      { "<leader>ol", function() Snacks.lazygit() end,               desc = "Option: Lazygit: tui" },
      { "<leader>ot", function() Snacks.terminal() end,              desc = "Option: Terminal: bash" },
      { "<leader>bd", function() Snacks.bufdelete() end,             desc = "Delete Buffer" },
   }
}
-- vim: ts=3 sts=3 sw=3 et
