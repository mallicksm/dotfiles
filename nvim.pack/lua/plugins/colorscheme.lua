-- gruvbox + a couple of overrides used elsewhere:
--   * NoiceVirtualText  -- muted blue for noice's virtual text
--   * SnacksNormal[NC]  -- terminal/lazygit floats inherit Normal so they
--                          look identical to TUIs running directly in kitty.
--   * Folded            -- gruvbox ships Folded with Comment's exact fg
--                          (#928374 + italic), so closed folds read as
--                          comments; aqua on bg2 makes them a distinct band.
require('gruvbox').setup({
   terminal_colors  = true,
   dim_inactive     = false,
   transparent_mode = false,
})
vim.cmd.colorscheme('gruvbox')

vim.api.nvim_set_hl(0, 'NoiceVirtualText', { fg = '#8492ad' })
vim.api.nvim_set_hl(0, 'SnacksNormal',     { link = 'Normal' })
vim.api.nvim_set_hl(0, 'SnacksNormalNC',   { link = 'Normal' })

-- bg2 (#504945) rather than bg1, so a fold sitting on the cursor line is still
-- distinguishable -- CursorLine is bg1 (#3c3836).
vim.api.nvim_set_hl(0, 'Folded', {
   fg = '#8ec07c', bg = '#504945', bold = true, italic = false,
})

-- vim: ts=3 sts=3 sw=3 et
