-- conform.nvim -- format on demand (no on-save by design).
-- Trigger via <leader>cf; the recursive `:FormatAllSV` user command lives
-- in lua/user_commands.lua and delegates to lua/utils/format_sv.lua.
require('conform').setup({
   formatters = {
      clang_format = {
         command = 'clang-format',
         args    = { '--style=file:' .. vim.fn.expand('$HOME') .. '/dotfiles/formatters/clang-format' },
      },
      -- Keep in sync with ~/dotfiles/formatters/verible-format.flagfile
      verible_verilog_format = {
         command = 'verible-verilog-format',
         args    = {
            '--port_declarations_indentation=indent',
            '--port_declarations_alignment=align',
            '--indentation_spaces=3',
            '--named_port_indentation=indent',
            '--named_port_alignment=align',
            '$FILENAME',
         },
      },
      black = {
         command = 'black',
         args    = { '--config', vim.fn.expand('$HOME') .. '/dotfiles/formatters/py-format.toml', '--quiet', '-' },
         stdin   = true,
      },
      semiforefmt = {
         command = 'semifore.py',
         stdin   = true,
      },
      shfmt = {
         -- -i 3 -ci -bn -sr   3-space indent, indent switch cases, binary
         --                    ops at SOL, redirects followed by space.
         -- (no -ln: defaults to auto-detect from shebang)
         command = 'shfmt',
         args    = { '-i', '3', '-ci', '-bn', '-sr' },
         stdin   = true,
      },
      shfmt_zsh = {
         -- Force zsh dialect for ft=zsh buffers (rcfiles usually lack a shebang).
         command = 'shfmt',
         args    = { '-ln', 'zsh', '-i', '3', '-ci', '-bn', '-sr' },
         stdin   = true,
      },
      tclfmt = {
         command = 'tclfmt',
         args    = { '-' },
         stdin   = true,
      },
   },
   formatters_by_ft = {
      lua      = { 'stylua' },
      json     = { 'prettier' },
      python   = { 'black' },
      c        = { 'clang_format' },
      cpp      = { 'clang_format' },
      sv       = { 'verible_verilog_format' },
      semifore = { 'semiforefmt' },
      sh       = { 'shfmt' },
      bash     = { 'shfmt' },
      zsh      = { 'shfmt_zsh' },
      tcl      = { 'tclfmt' },
   },
   notify_on_error = true,
})

vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
   require('conform').format({ async = true, lsp_format = 'fallback', timeout_ms = 1800 })
end, { desc = '[c]ode: format file (conform; LSP fallback)' })

-- vim: ts=3 sts=3 sw=3 et
