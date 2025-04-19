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
         dim_inactive = false,
         transparent_mode = false,
      })
      vim.cmd.colorscheme('koehler')
      vim.api.nvim_set_hl(0, "NoiceVirtualText", { fg = "#8492ad" })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
