-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do
return {
   { -- Adds git related signs to the gutter, as well as utilities for managing changes
      'lewis6991/gitsigns.nvim',
      opts = {
         signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
            untracked = { text = '┆' },
         },
         attach_to_untracked = true,
      },
      config = function(_, opts)
         require('gitsigns').setup(opts)

         -- You can configure highlights by doing something like
         vim.cmd.hi('GitSignsCurrentLineBlame guifg=yellow')
      end,
   },
   vim.keymap.set('n', '\\g', ':Gitsigns toggle_current_line_blame<cr>', { desc = "Toggle 'Git line blame'" }),
   vim.keymap.set('n', '<leader>gs', ':Gitsigns stage_buffer<cr>', { desc = 'GitSigns: Hunk: Stage buffer' }),
   vim.keymap.set('n', '<leader>gj', ':Gitsigns next_hunk<cr>', { desc = 'GitSigns: Hunk: next' }),
   vim.keymap.set('n', '<leader>gk', ':Gitsigns prev_hunk<cr>', { desc = 'GitSigns: Hunk: previous' }),
}
-- vim: ts=3 sts=3 sw=3 et
