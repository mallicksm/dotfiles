-- indent-blankline.nvim -- gruvbox-tuned rainbow indents per depth.
local highlight = {
   'RainbowRed', 'RainbowYellow', 'RainbowBlue', 'RainbowOrange',
   'RainbowGreen', 'RainbowViolet', 'RainbowCyan',
}

local hooks = require('ibl.hooks')
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
   vim.api.nvim_set_hl(0, 'RainbowRed',    { fg = '#fb4934' })
   vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#fabd2f' })
   vim.api.nvim_set_hl(0, 'RainbowBlue',   { fg = '#83a598' })
   vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#fe8019' })
   vim.api.nvim_set_hl(0, 'RainbowGreen',  { fg = '#b8bb26' })
   vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#d3869b' })
   vim.api.nvim_set_hl(0, 'RainbowCyan',   { fg = '#8ec07c' })
end)

require('ibl').setup({
   indent = { highlight = highlight, char = '│' },
})

-- vim: ts=3 sts=3 sw=3 et
