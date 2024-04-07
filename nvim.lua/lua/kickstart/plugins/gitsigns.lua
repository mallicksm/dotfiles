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
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      attach_to_untracked = true,

    },
    config = function(_, opts)
      require('gitsigns').setup(opts)

      -- You can configure highlights by doing something like
      vim.cmd.hi 'GitSignsCurrentLineBlame gui=bold'
    end,
  },
  vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<cr>", { desc = "GitSigns: Setup: Toggle Blame" }),
  vim.keymap.set("n", "<leader>gn", ":Gitsigns next_hunk<cr>", { desc = "GitSigns: Hunk: next" }),
  vim.keymap.set("n", "<leader>gp", ":Gitsigns prev_hunk<cr>", { desc = "GitSigns: Hunk: previous" }),
  vim.keymap.set("n", "<leader>gs", ":Gitsigns stage_hunk<cr>", { desc = "GitSigns: Hunk: stage" }),
  vim.keymap.set("n", "<leader>gu", ":Gitsigns undo_stage_hunk<cr>", { desc = "GitSigns: Hunk: unstage" }),
  vim.keymap.set("n", "<leader>gS", ":Gitsigns stage_buffer<cr>", { desc = "GitSigns: Hunk: Stage buffer" }),
}
-- vim: ts=2 sts=2 sw=2 et
