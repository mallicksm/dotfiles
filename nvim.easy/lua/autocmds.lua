-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

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

vim.keymap.set("n", "<leader>K", function()
   local word = vim.fn.expand("<cWORD>") -- Include words with hyphens (like `foo-bar`)
   -- Function to check if the word is a URL
   local function is_url(text)
      return text:match("^https?://") ~= nil
   end
   if is_url(word) then
      -- Open the URL with xdg-open
      local open_command = "xdg-open " .. vim.fn.shellescape(word)
      if vim.fn.executable("xdg-open") == 1 then
         vim.fn.system(open_command)
         vim.notify("Opening URL: " .. word, vim.log.levels.INFO)
      else
         vim.notify("xdg-open not found on your system", vim.log.levels.ERROR)
      end
   else
      -- Try to open a man page for the word
      local man_command = vim.fn.executable("man") == 1 and vim.fn.system("man -w " .. word)
      if man_command and vim.v.shell_error == 0 then
         vim.cmd("Man " .. word)
      else
         -- Fallback to Vim help if no man page exists
         local ok = pcall(function() vim.cmd("help " .. word) end)
         if not ok then
            vim.notify("No man page or help available for: " .. word, vim.log.levels.WARN)
         end
      end
   end
end, { noremap = true, silent = true, desc = "Man page or help for word under cursor" })

-- [[ Basic user functions ]]
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
