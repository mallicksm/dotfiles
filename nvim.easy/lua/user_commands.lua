-- All user commands live here. Real autocmds are in lua/autocmds.lua.
-- Implementations live under lua/utils/ when they're more than 1-2 lines.

vim.api.nvim_create_user_command('Utilities', function()
   require('utils.utilities_picker').open()
end, { nargs = 0, desc = 'Multi-choice telescope picker (options/registers/colorscheme/...)' })

-- (`:MdViewer` user command removed -- markview was uninstalled, so the only
--  previewer left is render-markdown.nvim. Toggle it with <leader>vP or use
--  `:RenderMarkdown {toggle,enable,disable,buf_toggle}` directly.)

vim.api.nvim_create_user_command('FormatAllSV', function()
   require('utils.format_sv').format_all_in_cwd()
end, { nargs = 0, desc = 'Recursively format all *.sv, *.svh, *.v under cwd' })

-- :AsciiDiagram [boxart|ascii] -- render Graph::Easy DSL (whole buffer, or a
-- range) into a preview split. With ! the art is inserted below the source
-- lines instead. Needs the CPAN Graph::Easy under ~/perl5 (see utils module).
vim.api.nvim_create_user_command('AsciiDiagram', function(opts)
   require('utils.ascii_diagram').run(opts)
end, {
   range    = '%',
   bang     = true,
   nargs    = '?',
   complete = function()
      return require('utils.ascii_diagram').charsets
   end,
   desc = 'Render Graph::Easy DSL as ASCII (! inserts below instead of previewing)',
})

-- vim: ts=3 sts=3 sw=3 et
