-- Real autocmds only. User commands moved to lua/user_commands.lua.
-- See `:help lua-guide-autocommands` for the API.

-- Read PDFs through pdftotext.py and present the extracted text in a scratch buffer.
vim.api.nvim_create_autocmd('BufReadCmd', {
   pattern = '*.pdf',
   callback = function()
      local fname = vim.fn.expand('<afile>')
      local cmd = 'pdftotext.py ' .. vim.fn.shellescape(fname)

      vim.cmd('enew')
      vim.cmd('setlocal buftype=nofile')
      vim.cmd('setlocal bufhidden=wipe')
      vim.cmd('setlocal noswapfile')
      vim.cmd('setlocal readonly')

      vim.cmd('0read !' .. cmd)
      vim.api.nvim_buf_set_name(0, fname .. '.txt')
   end,
})

-- Restore the cursor to its last position when re-opening a buffer.
vim.api.nvim_create_autocmd('BufReadPost', {
   group = vim.api.nvim_create_augroup('last_loc', { clear = true }),
   callback = function(event)
      local exclude = { 'gitcommit' }
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

-- vim: ts=3 sts=3 sw=3 et
