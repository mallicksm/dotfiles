return {
   'catppuccin/nvim',
   name = 'catppuccin',
   priority = 1000,
   config = function()
      vim.cmd.colorscheme('catppuccin-mocha')
   end,
}
-- vim: ts=3 sts=3 sw=3 et
