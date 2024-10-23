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
      vim.keymap.set({ 'n', 'v' }, '<leader>mp', function()
         require('conform').format({
            async = true,
            lsp_format = 'fallback',
            timeout_ms = 1800,
         })
      end, { desc = 'Fmt: Format file' }),
   },
}
-- vim: ts=3 sts=3 sw=3 et
