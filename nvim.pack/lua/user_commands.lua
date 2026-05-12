-- All user commands live here. Real autocmds are in lua/autocmds.lua.
-- Implementations live under lua/utils/ when they're more than 1-2 lines.

vim.api.nvim_create_user_command('Filename', function()
   vim.print('User: ' .. vim.fn.expand('%:p'))
end, { nargs = 0, desc = 'Print full path of current file' })

vim.api.nvim_create_user_command('Utilities', function()
   require('utils.utilities_picker').open()
end, { nargs = 0, desc = 'Multi-choice telescope picker (options/registers/colorscheme/...)' })

-- (`:MdViewer` user command removed -- markview was uninstalled, so the only
--  previewer left is render-markdown.nvim. Toggle it with <leader>tm or use
--  `:RenderMarkdown {toggle,enable,disable,buf_toggle}` directly.)

vim.api.nvim_create_user_command('FormatAllSV', function()
   require('utils.format_sv').format_all_in_cwd()
end, { nargs = 0, desc = 'Recursively format all *.sv, *.svh, *.v under cwd' })

-- vim: ts=3 sts=3 sw=3 et
