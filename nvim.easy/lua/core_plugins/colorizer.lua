return {
   {
      'norcalli/nvim-colorizer.lua',
      config = function()
         require('colorizer').setup({
            '*',
         })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
