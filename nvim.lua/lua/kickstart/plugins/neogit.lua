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
    end
  }
}
