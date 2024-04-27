-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Rapid quit keymap
vim.keymap.set('n', 'gq', 'q', { desc = 'Record a macro' })
vim.keymap.set('n', 'q', '<cmd>q<CR>', { desc = 'Quit if no change' })
vim.keymap.set('n', '<leader>q', '<cmd>qa<CR>', { desc = 'Quit all if no change' })
vim.keymap.set('n', '<leader>x', '<cmd>wqa!<CR>', { desc = 'Write quit all and all changes saved' })

-- Keybinds to make split navigation easier.
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<leader>h', '<C-w><C-h>', { desc = 'Nav: left window' })
vim.keymap.set('n', '<leader>l', '<C-w><C-l>', { desc = 'Nav: right window' })
vim.keymap.set('n', '<leader>j', '<C-w><C-j>', { desc = 'Nav: lower window' })
vim.keymap.set('n', '<leader>k', '<C-w><C-k>', { desc = 'Nav: upper window' })

-- [[ Basic Filetypes ]]
-- add custom similar filetypes
vim.filetype.add({
  extension = {
    qel = "tcl",
  }
})
-- vim: ts=2 sts=2 sw=2 et
