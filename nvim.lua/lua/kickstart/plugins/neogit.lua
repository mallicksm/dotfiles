return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('neogit').setup(
        {
          integrations = {
            diffview = true,
            telescope = true,
          },
          graph_style = "unicode",
          console_timeout = 5000,
        })
      vim.keymap.set("n", "<leader>gs", ":Neogit kind=auto<cr>", { desc = "Neogit: Git status CLI" })
      -- vim.keymap.set("n", "<leader>Do", ":DiffviewOpen -uno<cr>", { desc = "Diffview: open" })
      -- vim.keymap.set("n", "<leader>Dc", ":DiffviewClose<cr>", { desc = "Diffview: close" })
    end
  }
}
