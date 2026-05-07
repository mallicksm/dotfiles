-- danielfalk/smart-open.nvim (branch 0.2.x) -- frecency-based file picker.
-- DB at ~/.local/share/nvim.pack/smart_open.sqlite3 (auto-created).
-- Requires libsqlite3 on the system (RHEL 8: /usr/lib64/libsqlite3.so.0).
require('telescope').load_extension('smart_open')

vim.keymap.set('n', '<leader>F', function()
   require('telescope').extensions.smart_open.smart_open({
      cwd_only       = false,    -- show files outside cwd, but boost in-cwd matches
      filename_first = true,     -- "name  /path/to/" -- faster fuzzy
      prompt_title   = 'smart_open (<esc> to quit)',
   })
end, { desc = 'Telescope: smart_open ([F]recency + project)' })

-- vim: ts=3 sts=3 sw=3 et
