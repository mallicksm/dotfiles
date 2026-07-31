return {
   { -- Autoformat
      'stevearc/conform.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      keys = {
         {
            '<leader>cf',
            function()
               require('conform').format({ async = true, lsp_format = 'fallback', timeout_ms = 1800 })
            end,
            mode = { 'n', 'v' },
            desc = '[c]ode: format file (conform; LSP fallback)',
         },
      },
      config = function()
         require('conform').setup({
            formatters = {
               clang_format = {
                  command = 'clang-format',
                  args = { '--style=file:' .. vim.fn.expand('$HOME') .. '/dotfiles/formatters/clang-format' },
               },
               -- Keep in sync with ~/dotfiles/formatters/verible-format.flagfile (batch: format_verible_sv.sh)
               verible_verilog_format = {
                  command = 'verible-verilog-format',
                  args = {
                     '--port_declarations_indentation=indent',
                     '--port_declarations_alignment=align',
                     '--indentation_spaces=3',
                     '--named_port_indentation=indent',
                     '--named_port_alignment=align',
                     '$FILENAME'
                  },
               },
               black = {
                  command = 'black',
                  args = {
                     '--config',
                     vim.fn.expand('$HOME') .. '/dotfiles/formatters/py-format.toml',
                     '--quiet',
                     '-',
                  },
                  stdin = true,
               },
               semiforefmt = {
                  command = vim.fn.expand("$HOME") .. "/dotfiles/formatters/semifore.py",
                  stdin = true,
               },
               shfmt = {
                  command = 'shfmt',
                  -- -i 3   : 3-space indent (matches house style)
                  -- -ci    : indent switch cases
                  -- -bn    : binary ops at start of line (better diff readability)
                  -- -sr    : redirect operators followed by a space
                  -- (no -ln flag: defaults to -ln=auto, which detects bash/zsh/posix from shebang)
                  args = { '-i', '3', '-ci', '-bn', '-sr' },
                  stdin = true,
               },
               shfmt_zsh = {
                  -- Same shfmt, but force zsh dialect for buffers that nvim
                  -- detects as ft=zsh (which usually lack a #!/bin/zsh shebang
                  -- because they're sourced rcfiles, not standalone scripts).
                  command = 'shfmt',
                  args = { '-ln', 'zsh', '-i', '3', '-ci', '-bn', '-sr' },
                  stdin = true,
               },
               tclfmt = {
                  command = 'tclfmt',
                  args = { '-' }, -- read from stdin, write to stdout
                  stdin = true,
               },
            },
            formatters_by_ft = {
               lua = { 'stylua' },                                   -- brew install stylua
               json = { 'prettier' },                                -- npm install prettier
               python = { 'black' },                                 -- pip install black
               c = { 'clang_format' },                               -- gcc13 + clang11
               cpp = { 'clang_format' },                             -- gcc13 + clang11
               sv = { 'verible_verilog_format' },                    -- https://github.com/chipsalliance/verible/releases
               semifore = { 'semiforefmt' },
               sh = { 'shfmt' },                                     -- mason: shfmt
               bash = { 'shfmt' },                                   -- shebang-detected #!/bin/bash buffers
               zsh = { 'shfmt_zsh' },                                -- forces -ln=zsh; auto-detect can't tell rc-style files
               tcl = { 'tclfmt' },                                   -- mason: tclint (provides tclfmt)
            },
            notify_on_error = true, -- intentional: silent failures cost real time once. Flip to false if popups become annoying.
         })

         -- :FormatAllSV is registered in lua/user_commands.lua; the actual
         -- recursive-format logic lives in lua/utils/format_sv.lua.
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
