-- flash.nvim: label-based jump motions, treesitter node selection, and
-- multi-line f/F/t/T. Most useful for darting around a buffer without
-- thinking about line numbers, and for selecting a treesitter node from
-- 30 lines away with two keystrokes.
--
-- Flash uses the upstream defaults `s`/`S`/`r`/`R`/`<C-s>`. mini.surround
-- has been moved to the `gs*` prefix (see core_plugins/mini.lua) so bare
-- `s`/`S` are free here.
--
-- `r` in operator-pending mode is flash.remote(); normal-mode `r{char}`
-- (vim's "replace char") is preserved because we only register `r` for
-- operator mode.
--
-- Defaults left ON intentionally (no opts override needed):
--   * search integration: typing in `/` or `?` shows jump labels for matches
--   * char mode (f/F/t/T) enhancement: cross-line jumps + labels for repeats
return {
   'folke/flash.nvim',
   event = 'VeryLazy',
   ---@type Flash.Config
   opts = {
      modes = {
         char = {
            -- Show jump labels after the target char, so f<char> -> label = jump
            -- to a specific occurrence. Default is false (just dim + ;/, to walk).
            -- Labels are auto-suppressed when a count is given (e.g. 3fa still
            -- works as "jump to 3rd a") or when recording/executing a macro.
            jump_labels = true,
            -- Hide flash overlay after the jump so the dim doesn't linger.
            autohide    = true,
         },
      },
   },
   keys = {
      -- Label-based jump. Type chars; flash shows labels at every match;
      -- press the label to jump. Visual mode is intentionally excluded so
      -- vim's `s` (substitute selection) still works there. operator-pending
      -- IS included so `dsfoo<label>` deletes from cursor to a flashed `foo`.
      { 's', mode = { 'n', 'o' },      function() require('flash').jump() end,             desc = 'Flash: jump (label search)' },

      -- Treesitter node select. Excluded from visual for the same reason
      -- as `s` above (visual `S` substitutes selection lines).
      { 'S', mode = { 'n', 'o' },      function() require('flash').treesitter() end,       desc = 'Flash: treesitter node select' },

      -- Remote operator: `dr<jump>` deletes at a flashed location WITHOUT
      -- moving the cursor. operator-pending only so normal-mode `r{char}`
      -- (replace char) still works.
      { 'r', mode = 'o',               function() require('flash').remote() end,           desc = 'Flash: remote (operator only, e.g. dr)' },

      -- Treesitter search: same as S but driven by a search prompt.
      -- operator-pending only; excluded from visual (same rationale as s/S).
      { 'R', mode = 'o',               function() require('flash').treesitter_search() end, desc = 'Flash: treesitter search (operator only)' },

      -- While in cmdline search (after `/` or `?`), <C-s> toggles flash labels
      -- on/off so you can fall back to plain incsearch when desired.
      { '<C-s>', mode = 'c',           function() require('flash').toggle() end,            desc = 'Flash: toggle labels while in / search' },
   },
}
-- vim: ts=3 sts=3 sw=3 et
