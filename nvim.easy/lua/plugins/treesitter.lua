return {
   'nvim-treesitter/nvim-treesitter',
   build = ':TSUpdate',
   config = function()
      require("nvim-treesitter.configs").setup({
         ensure_installed = {"lua"},
         highlight = { enable = true },
         indent = { enable = true},
      })
   end
}
-- vim: ts=3 sts=3 sw=3 et