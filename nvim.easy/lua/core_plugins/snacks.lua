return {
   'folke/snacks.nvim',
   priority = 1000,
   lazy = false,
   opts = {
      terminal = {
         win = {
            style = 'float',
         },
      },
      image = {
         enabled = true,
         doc = {
            enabled = true,
            inline = true,
            float = true,
            max_width = 80,
            max_height = 40,
         },
         convert = {
            magick = { 'magick' },
         },
      },
   },
   config = function(_, opts)
      require('snacks').setup(opts)
      -- (Snacks sets `_G.Snacks` itself in setup(); we don't add another
      -- global here. Callers should `require('snacks')` rather than relying
      -- on the global so this config isn't coupled to that detail.)
   end,
}
-- vim: ts=3 sts=3 sw=3 et
