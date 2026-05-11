-- diffview.nvim -- side-by-side / merge-mode git diff viewer
-- Loaded transitively by neogit (see neogit.lua dependencies), but we declare
-- it explicitly here so we own the setup() call + the <leader>gd keymap.
return {
   {
      'sindrets/diffview.nvim',
      cmd = {
         'DiffviewOpen',
         'DiffviewClose',
         'DiffviewToggleFiles',
         'DiffviewFocusFiles',
         'DiffviewFileHistory',
         'DiffviewRefresh',
      },
      keys = {
         {
            '<leader>gd',
            function()
               if next(require('diffview.lib').views) == nil then
                  vim.cmd('DiffviewOpen -uno')
               else
                  vim.cmd('DiffviewClose')
               end
            end,
            desc = 'Diffview: toggle',
         },
      },
      opts = {
         -- winbar_info renders a per-window label saying which side of the
         -- diff each pane represents:
         --   default  : 'a/<path>' / 'b/<path>'
         --   merge_tool (during conflicts):
         --     OURS   (Current changes)   <hash> (<refs>)
         --     LOCAL  (Working tree)
         --     THEIRS (Incoming changes)  <hash> (<refs>)
         --     BASE   (Common ancestor)   <hash> (<refs>)
         --   file_history : commit hash + author for each pane
         -- Defaults turn it on only for merge_tool; we enable everywhere.
         view = {
            default = {
               layout              = 'diff2_horizontal',
               disable_diagnostics = false,
               winbar_info         = true,
            },
            merge_tool = {
               -- diff4_mixed = OURS | BASE | THEIRS on top, MERGED full-width
               -- below. Mirrors the in-file zdiff3 conflict markers (which
               -- also show OURS / BASE / THEIRS). Use g<C-x> in a Diffview tab
               -- to cycle layouts at runtime.
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
      },
   },
}
-- vim: ts=3 sts=3 sw=3 et
