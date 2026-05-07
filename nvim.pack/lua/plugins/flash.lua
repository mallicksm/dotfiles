-- flash.nvim -- label-based jump motions, treesitter node selection,
-- multi-line f/F/t/T enhancement.
--
-- Uses upstream defaults `s`/`S`/`r`/`R`/`<C-s>`. mini.surround was moved to
-- `gs*` (see plugins/mini.lua) to free `s`/`S`. `r` in operator-pending is
-- flash.remote(); normal-mode `r{char}` (vim's "replace char") is preserved
-- because we only register `r` for operator mode.
--
-- Defaults left ON intentionally:
--   * search integration: typing in `/` or `?` shows jump labels for matches
--   * char mode (f/F/t/T) enhancement: cross-line jumps + labels for repeats
require('flash').setup({
   modes = {
      char = {
         jump_labels = true, -- f<char> -> label-pick (default false = ;/, walk)
         autohide    = true, -- hide overlay after jump so dim doesn't linger
      },
   },
})

-- Visual-mode `s`/`S`/`R` deliberately excluded so vim defaults (substitute
-- selection / substitute lines / replace) still work there.
vim.keymap.set({ 'n', 'o' },      's',     function() require('flash').jump() end,             { desc = 'Flash: jump (label search)' })
vim.keymap.set({ 'n', 'o' },      'S',     function() require('flash').treesitter() end,       { desc = 'Flash: treesitter node select' })
vim.keymap.set('o',               'r',     function() require('flash').remote() end,           { desc = 'Flash: remote (operator only, e.g. dr)' })
vim.keymap.set('o',               'R',     function() require('flash').treesitter_search() end, { desc = 'Flash: treesitter search (operator only)' })
vim.keymap.set('c',               '<C-s>', function() require('flash').toggle() end,            { desc = 'Flash: toggle labels while in / search' })

-- vim: ts=3 sts=3 sw=3 et
