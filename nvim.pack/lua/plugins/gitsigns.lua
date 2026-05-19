-- gitsigns.nvim -- gutter signs for git changes + per-buffer hunk ops.
require('gitsigns').setup({
   signs = {
      add          = { text = '+' },
      change       = { text = '~' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
   },
   attach_to_untracked = true,
})

vim.cmd.hi('GitSignsCurrentLineBlame guifg=yellow')

vim.keymap.set('n', '<leader>gs', '<cmd>Gitsigns stage_buffer<cr>',              { desc = 'GitSigns: Stage entire buffer' })
vim.keymap.set('n', '<leader>gj', '<cmd>Gitsigns next_hunk<cr>',                 { desc = 'GitSigns: Hunk: next' })
vim.keymap.set('n', '<leader>gk', '<cmd>Gitsigns prev_hunk<cr>',                 { desc = 'GitSigns: Hunk: previous' })
vim.keymap.set('n', '<leader>gu', function()
   local bufname = vim.api.nvim_buf_get_name(0)
   vim.cmd('!git restore --staged ' .. bufname)
end, { desc = 'Git: Unstage buffer' })

-- vim: ts=3 sts=3 sw=3 et
