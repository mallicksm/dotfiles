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
        })
      vim.cmd([[nnoremap g\ :Neogit kind=auto<cr>]])
      vim.cmd([[nnoremap d\ :DiffviewOpen<cr>]])
      vim.cmd([[nnoremap \d :DiffviewClose<cr>]])
    end
  }
}
