-- Buffer-local extras for Jira wiki markup files (.jira).
--
-- Snippets live in ~/dotfiles/snippets/vscode_snippets/jira.json (VS Code
-- format, registered in that directory's package.json). Loaded by
-- garymjr/nvim-snippets and surfaced via blink.cmp's `snippets` source.
-- Type a prefix in insert mode (e.g. `h2`, `bul`, `code`, `jt`) and accept
-- the completion (<C-y>) to expand. <C-l>/<C-h> jump between placeholders.
-- See lua/code_plugins/{snippets,completions}.lua for wiring.

vim.opt_local.wrap         = false
vim.opt_local.linebreak    = true
vim.opt_local.breakindent  = true
vim.opt_local.textwidth    = 0   -- jira renders prose unconstrained; don't auto-wrap on save
vim.opt_local.conceallevel = 0   -- show wiki markup ({code}, !img!, h2., etc.) literally

----------------------------------------------------------------------------
-- <leader>jp = "jira post": send the current buffer's contents as a comment
-- to a Jira issue you'll be prompted for. Wraps ~/.local/bin/jira-comment.
-- The buffer is :w'd first if dirty so we always post what's on disk.
----------------------------------------------------------------------------
vim.keymap.set('n', '<leader>jp', function()
   local key = vim.fn.input('Jira issue key (e.g. BUGATTI-2617): ')
   if key == '' then
      vim.notify('cancelled (empty issue key)', vim.log.levels.INFO)
      return
   end
   if vim.bo.modified then vim.cmd.write() end
   local file = vim.fn.expand('%:p')
   if file == '' then
      vim.notify('buffer has no file; :w it first', vim.log.levels.ERROR)
      return
   end
   local cmd = string.format('jira-comment %s < %s 2>&1',
      vim.fn.shellescape(key), vim.fn.shellescape(file))
   local result = vim.fn.system(cmd)
   if vim.v.shell_error == 0 then
      vim.notify(result, vim.log.levels.INFO,  { title = 'Jira: posted to ' .. key })
   else
      vim.notify(result, vim.log.levels.ERROR, { title = 'Jira: post failed' })
   end
end, { buffer = true, desc = 'Jira: [P]ost buffer as comment to issue' })

-- vim: ts=3 sts=3 sw=3 et
