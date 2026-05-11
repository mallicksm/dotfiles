-- diffview.nvim -- side-by-side / merge-mode git diff viewer
-- Plugin is added in plugins.lua. We own setup() + the <leader>gd keymap here
-- (moved out of neogit.lua so each plugin's config stays self-contained).
--
-- winbar_info renders a per-window label saying which side of the diff each
-- pane represents:
--   default  : 'a/<path>' / 'b/<path>'
--   merge_tool (during conflicts):
--     OURS   (Current changes)   <hash> (<refs>)
--     LOCAL  (Working tree)
--     THEIRS (Incoming changes)  <hash> (<refs>)
--     BASE   (Common ancestor)   <hash> (<refs>)
--   file_history : commit hash + author for each pane
-- Defaults turn it on only for merge_tool; we enable everywhere.
require('diffview').setup({
   view = {
      default = {
         layout              = 'diff2_horizontal',
         disable_diagnostics = false,
         winbar_info         = true,
      },
      merge_tool = {
         -- diff4_mixed = OURS | BASE | THEIRS on top, MERGED full-width
         -- below. Mirrors the in-file zdiff3 conflict markers (which also
         -- show OURS / BASE / THEIRS). Use g<C-x> in a Diffview tab to cycle
         -- layouts at runtime.
         layout              = 'diff4_mixed',
         disable_diagnostics = true,
         winbar_info         = true,
      },
      file_history = {
         layout              = 'diff2_horizontal',
         disable_diagnostics = false,
         winbar_info         = true,
      },
   },
})

vim.keymap.set('n', '<leader>gd', function()
   if next(require('diffview.lib').views) == nil then
      vim.cmd('DiffviewOpen -uno')
   else
      vim.cmd('DiffviewClose')
   end
end, { desc = 'Diffview: toggle' })

-- vim: ts=3 sts=3 sw=3 et
