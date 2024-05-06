return {
   "hedyhli/outline.nvim",
   lazy = true,
   cmd = { "Outline", "OutlineOpen" },
   keys = {
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
   },
   config = function()
      require("outline").setup()
   end,
}
-- vim: ts=3 sts=3 sw=3 et
