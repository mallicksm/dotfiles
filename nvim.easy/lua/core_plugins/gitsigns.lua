-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do
return {
   { -- Adds git related signs to the gutter, as well as utilities for managing changes
      'lewis6991/gitsigns.nvim',
      event = { 'BufReadPre', 'BufNewFile' }, -- attach to buffers as soon as they're opened (gutter signs)
      keys = {
         { '<leader>gs', '<cmd>Gitsigns stage_buffer<cr>',              desc = 'GitSigns: Stage entire buffer' },
         { '<leader>gj', '<cmd>Gitsigns next_hunk<cr>',                 desc = 'GitSigns: Hunk: next' },
         { '<leader>gk', '<cmd>Gitsigns prev_hunk<cr>',                 desc = 'GitSigns: Hunk: previous' },
         {
            '<leader>gu',
            function()
               local bufname = vim.api.nvim_buf_get_name(0)
               vim.cmd('!git restore --staged ' .. bufname)
            end,
            desc = 'Git: Unstage buffer',
         },
      },
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
}
-- vim: ts=3 sts=3 sw=3 et
