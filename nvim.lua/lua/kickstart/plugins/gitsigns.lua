-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do
return {
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' }, topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        attach_to_untracked = true,
      }
    end,
  },
  vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<cr>", { desc = "GitSigns: Setup: Toggle Blame" }),
  vim.keymap.set("n", "<leader>gW", ":Gitsigns toggle_word_diff<cr>", { desc = "GitSigns: Setup: Toggle Word diff" }),
  vim.keymap.set("n", "<leader>gN", ":Gitsigns toggle_numhl<cr>", { desc = "GitSigns: Setup: Toggle number highlight" }),
  vim.keymap.set("n", "<leader>gB", ":Gitsigns blame_line<cr>", { desc = "GitSigns: Setup: Blame line" }),
  vim.keymap.set("n", "<leader>gD", ":Gitsigns toggle_deleted<cr>", { desc = "GitSigns: Setup: Toggle deleted lines" }),
  vim.keymap.set("n", "<leader>gd", ":Gitsigns diffthis master<cr>", { desc = "GitSigns: Setup: Git Diff file" }),
  vim.keymap.set("n", "<leader>gn", ":Gitsigns next_hunk<cr>", { desc = "GitSigns: Hunk: next" }),
  vim.keymap.set("n", "<leader>gp", ":Gitsigns prev_hunk<cr>", { desc = "GitSigns: Hunk: previous" }),
  vim.keymap.set("n", "<leader>gs", ":Gitsigns stage_hunk<cr>", { desc = "GitSigns: Hunk: stage" }),
  vim.keymap.set("n", "<leader>gU", ":Gitsigns undo_stage_hunk<cr>", { desc = "GitSigns: Hunk: Unstage" }),
  vim.keymap.set("n", "<leader>gR", ":Gitsigns reset_hunk<cr>", { desc = "GitSigns: Hunk: Reset" }),
}
-- vim: ts=2 sts=2 sw=2 et
