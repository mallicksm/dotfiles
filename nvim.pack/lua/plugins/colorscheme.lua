-- gruvbox + a couple of overrides used elsewhere:
--   * NoiceVirtualText  -- muted blue for noice's virtual text
--   * SnacksNormal[NC]  -- terminal/lazygit floats inherit Normal so they
--                          look identical to TUIs running directly in kitty.
require('gruvbox').setup({
   terminal_colors  = true,
   dim_inactive     = false,
   transparent_mode = false,
})
vim.cmd.colorscheme('gruvbox')

vim.api.nvim_set_hl(0, 'NoiceVirtualText', { fg = '#8492ad' })
vim.api.nvim_set_hl(0, 'SnacksNormal',     { link = 'Normal' })
vim.api.nvim_set_hl(0, 'SnacksNormalNC',   { link = 'Normal' })

-- vim: ts=3 sts=3 sw=3 et
