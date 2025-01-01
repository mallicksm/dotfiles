--------------------------------------------------------------------------------
--- Basic Autocommands
--------------------------------------------------------------------------------
-- <leader>K for more info on cWORD lua-guide-autocommands`
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

--------------------------------------------------------------------------------
--- Basic user functions
--------------------------------------------------------------------------------
-- The first argument is the name of the command (which must start with an uppercase letter).
vim.api.nvim_create_user_command("Filename",
   function()
      vim.print("User: " .. vim.fn.expand('%:p'))
   end, { nargs = 0 })

vim.api.nvim_create_user_command("Explorer",
   function()
      local builtin = require 'telescope.builtin'
      builtin.find_files({
         prompt_title = 'Find Files (<esc> to quit)'
      })
   end, { nargs = 0 })

vim.api.nvim_create_user_command("Rg",
   function()
      local builtin = require 'telescope.builtin'
      builtin.live_grep({
         prompt_title = 'Live Grep in Open Files <ESC> to quit',
      })
   end, { nargs = 0 })

vim.api.nvim_create_user_command("Git",
   function()
      vim.cmd('Neogit kind=auto')
   end, { nargs = 0 })
-- vim: ts=3 sts=3 sw=3 et
