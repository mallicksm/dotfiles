-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
   --  Try it with `yap` in normal mode
   --  See `:help vim.highlight.on_yank()`
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

vim.keymap.set("n", "<leader>K", function()
    local word = vim.fn.expand("<cWORD>") -- Include words with hyphens (like `foo-bar`)

    -- Try to open a man page for the word
    local man_command = vim.fn.executable("man") == 1 and vim.fn.system("man -w " .. word)
    if man_command and vim.v.shell_error == 0 then
        vim.cmd("Man " .. word)
    else
        -- Fallback to Vim help if no man page exists
        local ok = pcall(vim.cmd, "help " .. word)
        if not ok then
            vim.notify("No man page or help available for: " .. word, vim.log.levels.WARN)
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
