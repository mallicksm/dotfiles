return {
   'nvim-treesitter/nvim-treesitter',
   build = ':TSUpdate',
   opts = {
      ensure_installed = { 'lua', 'c' },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
   },
   config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
   end,
}
-- vim: ts=3 sts=3 sw=3 et
