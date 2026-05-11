-- Basic, plugin-agnostic keymaps. Plugin-specific keys live in each plugin's
-- `keys = { ... }` lazy spec (search the codebase for "keys = {" to find them).
-- See `:help vim.keymap.set()`.

-- Clear search highlight on <Esc> in normal mode.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Re-enable hlsearch on `*` and `#` so the per-match Search highlight comes
-- back after we've used a plugin that explicitly disabled it (kaleidosearch
-- does `set nohlsearch` after every call so its color highlights aren't
-- visually clashed with vim's yellow Search). Without this, after using
-- kaleidosearch once, plain `*` would jump but never highlight again.
vim.keymap.set('n', '*', '*<cmd>set hlsearch<CR>', { desc = 'Search forward for <cword> (with hlsearch)'  })
vim.keymap.set('n', '#', '#<cmd>set hlsearch<CR>', { desc = 'Search backward for <cword> (with hlsearch)' })

-- Quit shortcuts. `q` quits if no changes; `gq` is preserved as the original
-- `q` (start macro) since `q` is overloaded by us.
vim.keymap.set('n', 'gq',         'q',             { desc = 'Nav: Macro' })
vim.keymap.set('n', 'q',          '<cmd>q<CR>',    { desc = 'Nav: Quit if no change' })
vim.keymap.set('n', '<leader>q',  '<cmd>qa<CR>',   { desc = 'Nav: Quit all if no change' })
vim.keymap.set('n', '<leader>x',  '<cmd>wqa!<CR>', { desc = 'Nav: Write quit all' })

-- Window navigation. See `:help wincmd`.
vim.keymap.set('n', '<leader>h', '<C-w><C-h>', { desc = 'Nav: left window' })
vim.keymap.set('n', '<leader>l', '<C-w><C-l>', { desc = 'Nav: right window' })
vim.keymap.set('n', '<leader>j', '<C-w><C-j>', { desc = 'Nav: lower window' })
vim.keymap.set('n', '<leader>k', '<C-w><C-k>', { desc = 'Nav: upper window' })

-- Window resize via Ctrl+Arrow. v:count1 lets `5<C-Right>` widen by 5.
vim.keymap.set('n', '<C-Left>',  '"<Cmd>vertical resize -" . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', '"<Cmd>vertical resize +" . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Increase window width' })
vim.keymap.set('n', '<C-Down>',  '"<Cmd>resize -"          . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Up>',    '"<Cmd>resize +"          . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Increase window height' })

-- <leader>K: man / :help / xdg-open dispatch on <cWORD>. Logic in utils/.
vim.keymap.set('n', '<leader>K', function()
   require('utils.smart_open').open()
end, { noremap = true, silent = true, desc = 'Man page or help for word under cursor' })

-- vim: ts=3 sts=3 sw=3 et
