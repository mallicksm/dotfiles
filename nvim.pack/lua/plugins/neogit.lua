-- neogit -- git status TUI inside nvim. Pulls in diffview / plenary / telescope
-- (all added in plugins.lua so they're on rtp by the time setup() runs).
require('neogit').setup({
   integrations    = { diffview = true, telescope = true },
   graph_style     = 'unicode',
   console_timeout = 5000,
})

vim.keymap.set('n', '<leader>gn', '<cmd>Neogit kind=auto<cr>', { desc = 'Neogit: Git status CLI' })

-- vim: ts=3 sts=3 sw=3 et
