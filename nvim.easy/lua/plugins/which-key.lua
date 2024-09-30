return {
   'folke/which-key.nvim',
   event = 'VimEnter',
   opts = {
      icons = {
         mappings = true,
         keys = {}
      }

   },
   -- Document existing key chains
   spec = {
      {"<leader>d", group = "[D]ap"},
      {"<leader>d", hidden = true},
      {"<leader>g", group = "[G]it"},
      {"<leader>g", hidden = true},

   }
}
-- vim: ts=3 sts=3 sw=3 et
