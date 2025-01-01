return {
   {
      'NeogitOrg/neogit',
      lazy = false,
      branch = 'master',
      dependencies = {
         'nvim-lua/plenary.nvim',
         'sindrets/diffview.nvim',
         'nvim-telescope/telescope.nvim',
      },
      config = function()
         require('neogit').setup({
            integrations = {
               diffview = true,
               telescope = true,
            },
            graph_style = 'unicode',
            console_timeout = 5000,
         })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
