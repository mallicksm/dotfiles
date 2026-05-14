-- danielfalk/smart-open.nvim (branch 0.2.x) -- frecency-based file picker.
-- DB at ~/.local/share/nvim.pack/smart_open.sqlite3 (auto-created).
-- Requires libsqlite3 on the system (RHEL 8: /usr/lib64/libsqlite3.so.0).
--
-- Custom weights kill cwd preference: project=0, proximity=0, frecency
-- bumped to 30. Effect is "rank by what I touched most recently/often,
-- anywhere", not "what's near me right now". See lua/plugins/smart-open.lua
-- in nvim.easy for the full algorithm rationale.
require('telescope').load_extension('smart_open')

-- <leader>tf -- canonical "find files" (smart_open is a strict superset of
-- telescope's bare find_files; the latter was dropped).
vim.keymap.set('n', '<leader>tf', function()
   require('telescope').extensions.smart_open.smart_open({
      cwd_only       = false,                              -- show files outside cwd
      filename_first = true,                               -- "name  /path/to/" rendering
      prompt_title   = 'smart_open (frecency, no cwd boost)',
      weights = {
         project          = 0,
         proximity        = 0,
         frecency         = 30,
         recency          = 9,
         open             = 3,
         alt              = 4,
         path_fzy         = 140,
         virtual_name_fzy = 131,
         path_fzf         = 140,
         virtual_name_fzf = 131,
      },
   })
end, { desc = 'Telescope: smart_open ([f]recency-ranked file picker, no cwd preference)' })

-- vim: ts=3 sts=3 sw=3 et
