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
          add          = { text = '+' },
          change       = { text = '~' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
      }
    end,
  },
  vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<cr>", { desc = "GitSigns: Toggle Blame" }),
  vim.keymap.set("n", "<leader>gB", ":Gitsigns blame_line<cr>", { desc = "GitSigns: Blame line" })
}
-- vim: ts=2 sts=2 sw=2 et
