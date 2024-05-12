return {
   'folke/which-key.nvim',
   event = 'VimEnter',
   config = function()
      require('which-key').setup()
      require('which-key').register {
         ['<leader>d'] = { name = '[D]ap', _ = 'which_key_ignore' },
         ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
      }
   end,
}
-- vim: ts=3 sts=3 sw=3 et
