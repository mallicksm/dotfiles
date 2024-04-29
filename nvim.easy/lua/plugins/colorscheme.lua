return {
   --[[
   'catppuccin/nvim',
   name = 'catppuccin',
   priority = 1000,
   config = function()
      vim.cmd.colorscheme('catppuccin-mocha')
   end,
   --]]
   'ellisonleao/gruvbox.nvim',
   priority = 1000,
   config = function()
      require('gruvbox').setup({
         terminal_colors = true,
      })
      vim.cmd.colorscheme('gruvbox')
   end,
}
-- vim: ts=3 sts=3 sw=3 et
