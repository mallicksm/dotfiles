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

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup('last_loc', { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup('checktime', { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- [[ Basic user functions ]]
-- The first argument is the name of the command (which must start with an uppercase letter).
vim.api.nvim_create_user_command("Filename",
  function()
    vim.print(vim.fn.expand('%:p'))
  end, { nargs = 0 })

vim.api.nvim_create_user_command("Explore",
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
