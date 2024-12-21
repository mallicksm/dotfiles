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
         vim.keymap.set('n', '<leader>gg', ':Neogit kind=auto<cr>', { desc = 'Neogit: Git status CLI' })
         vim.keymap.set('n', '<leader>gd', function()
            if next(require('diffview.lib').views) == nil then
               vim.cmd('DiffviewOpen -uno')
            else
               vim.cmd('DiffviewClose')
            end
         end, { desc = 'Diffview: toggle' })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
