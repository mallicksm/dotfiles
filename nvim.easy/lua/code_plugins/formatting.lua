return {
   { -- Autoformat
      'stevearc/conform.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      config = function()
         require('conform').setup({
            formatters = {
               clang_format = {
                  command = 'clang-format',
                  args = { '--style=file:' .. vim.fn.expand("$HOME") .. '/dotfiles/formatters/clang-format' },
               },
               verible_verilog_format = {
                  command = 'verible-verilog-format',
                  args = { "--port_declarations_indentation=indent", "--port_declarations_alignment=align", "--indentation_spaces=3", "$FILENAME" },
               },
               black = {
                  command = "black",
                      args = {
                        "--config",
                        vim.fn.expand("$HOME") .. "/dotfiles/formatters/py-format.toml",
                        "--quiet",
                        "-"
                  },
                  stdin = true,
               }
            },
            formatters_by_ft = {
               lua = { 'stylua' },
               json = { 'prettier' },
               python = {"black"},
               c = { 'clang_format' },
               verilog_systemverilog = { 'verible_verilog_format' },
            },
            notify_on_error = false,
         })
      end,
   },
}
-- vim: ts=3 sts=3 sw=3 et
