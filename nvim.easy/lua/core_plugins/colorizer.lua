--[[ Colorizes visually ]]

--red   #ff0000
--green #00ff00
--blue  #0000ff
return {
   {
      'norcalli/nvim-colorizer.lua',
      config = function()
         require('colorizer').setup({
               '*',
            },
            {
               RGB = true,          -- Enable #RGB hex color highlighting
               RRGGBB = true,       -- Enable #RRGGBB hex color highlighting
               names = true,        -- Enable color names like "blue", "red"
               RRGGBBAA = true,     -- Enable #RRGGBBAA hex color highlighting
               rgb_fn = true,       -- Enable CSS functions like rgb(255, 0, 0)
               hsl_fn = true,       -- Enable CSS functions like hsl(120, 100%, 50%)
               css = true,          -- Enable all CSS color properties
               css_fn = true,       -- Enable all CSS functions
               mode = 'background', -- Set the display mode (foreground, background, or virtualtext)
            }
         )
         -- Optional: Add a command to toggle the colorizer
         vim.keymap.set('n', '<leader>tc', '<cmd>ColorizerToggle<CR>',
            { noremap = true, silent = true, desc = 'Toggle Colorizer' })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
