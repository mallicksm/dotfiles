return {
   { -- Add indentation guides even on blank lines
      'lukas-reineke/indent-blankline.nvim',
      -- Enable `lukas-reineke/indent-blankline.nvim`
      -- See `:help ibl`
      main = 'ibl',
      opts = {},
      config = function()
         local highlight = {
            'RainbowRed',
            'RainbowYellow',
            'RainbowBlue',
            'RainbowOrange',
            'RainbowGreen',
            'RainbowViolet',
            'RainbowCyan',
         }
         local hooks = require('ibl.hooks')
         -- create the highlight groups in the highlight setup hook, so they are reset
         -- every time the colorscheme changes
         -- Gruvbox-tuned rainbow indents (swap to catppuccin/onedark hexes if you
         -- ever change the colorscheme). HIGHLIGHT_SETUP fires on every ColorScheme
         -- so these survive `:Telescope colorscheme` previews.
         hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, 'RainbowRed',    { fg = '#fb4934' }) -- gruvbox red
            vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#fabd2f' }) -- gruvbox yellow
            vim.api.nvim_set_hl(0, 'RainbowBlue',   { fg = '#83a598' }) -- gruvbox blue
            vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#fe8019' }) -- gruvbox orange
            vim.api.nvim_set_hl(0, 'RainbowGreen',  { fg = '#b8bb26' }) -- gruvbox green
            vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#d3869b' }) -- gruvbox purple
            vim.api.nvim_set_hl(0, 'RainbowCyan',   { fg = '#8ec07c' }) -- gruvbox aqua
         end)

         local opt = {
            indent = {
               highlight = highlight,
               char = '│',
            },
         }
         require('ibl').setup(opt)
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
