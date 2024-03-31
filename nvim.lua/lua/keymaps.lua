-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>E', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>Q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Rapid quit keymap
vim.keymap.set('n', '<leader>x', '<cmd>q!<CR>', { desc = 'Quit without any change saved' })
vim.keymap.set('n', 'qq', 'q', { desc = 'macro start (prev q)' })
vim.keymap.set('n', 'q', '<cmd>q<CR>', { desc = 'Quit if no change' })

-- Keybinds to make split navigation easier.
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<leader>h', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<leader>l', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<leader>j', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<leader>k', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Basic Filetypes ]]
-- add custom filetypes
vim.filetype.add({
  extension = {
    qel = "tcl",
    f = "f"
  }
})

-- [[ Basic user functions ]]
-- The first argument is the name of the command (which must start with an uppercase letter).
vim.api.nvim_create_user_command("Filename",
  function()
    vim.print(vim.fn.expand('%:p'))
  end, { nargs = 0 })

vim.api.nvim_create_user_command("Explorer",
  function()
    vim.notify("keymap: ,f")
    local builtin = require 'telescope.builtin'
    builtin.find_files({
      prompt_title = 'Find Files (<esc> to quit)'
    })
  end, { nargs = 0 })

vim.api.nvim_create_user_command("Rg",
  function()
    vim.notify("keymap: ,g")
    local builtin = require 'telescope.builtin'
    builtin.live_grep({
      prompt_title = 'Live Grep in Open Files <ESC> to quit',
    })
  end, { nargs = 0 })

vim.api.nvim_create_user_command("Git",
  function()
    vim.notify("keymap: <leader>gs")
    vim.cmd('Neogit kind=auto')
  end, { nargs = 0 })
-- vim: ts=2 sts=2 sw=2 et
