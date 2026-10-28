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
      vim.cmd.colorscheme('gruvbox')
      vim.api.nvim_set_hl(0, 'NoiceVirtualText', { fg = '#8492ad' })
      -- Snacks floats default to NormalFloat (gruvbox bg1 = #3c3836, the
      -- dusty light-gray). For terminal floats (lazygit via <leader>gl,
      -- snacks terminal via <leader>vt) we want them to match the editor
      -- bg (Normal = bg0 = #282828) so they look identical to running
      -- the same TUI directly in kitty. Linking SnacksNormal[NC] -> Normal
      -- keeps other plugins' floats (noice, neogit, etc.) untouched.
      vim.api.nvim_set_hl(0, 'SnacksNormal', { link = 'Normal' })
      vim.api.nvim_set_hl(0, 'SnacksNormalNC', { link = 'Normal' })
      -- gruvbox ships Folded with Comment's exact fg (#928374 + italic), so a
      -- closed fold reads as a comment. Aqua on bg2 (#504945) makes it a
      -- distinct band; bg2 rather than bg1 keeps a fold on the cursor line
      -- readable, since CursorLine is bg1 (#3c3836).
      vim.api.nvim_set_hl(0, 'Folded', {
         fg = '#8ec07c', bg = '#504945', bold = true, italic = false,
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
