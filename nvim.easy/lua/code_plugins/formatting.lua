return {
   { -- Autoformat
      'stevearc/conform.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      config = function()
         require('conform').setup({
            formatters = {
               clang_format = {
                  command = 'clang-format',
                  args = { '--style=file:' .. os.getenv('HOME') .. '/dotfiles/initrc/clang-format' },
               },
            },
            formatters_by_ft = {
               lua = { 'stylua' },
               json = { 'prettier' },
               c = { 'clang_format' },
            },
            notify_on_error = false,
            format_on_save = function(bufnr)
               local disable_filetypes = { c = true, cpp = true, json = false, lua = false }
               return {
                  async = false,
                  timeout_ms = 1800,
                  lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
               }
            end,
         })
      end,
      vim.keymap.set({ 'n', 'v' }, '<leader>mp', function()
         require('conform').format({
            lsp_fallback = true,
            async = false,
            timeout_ms = 1000,
         })
      end, { desc = 'Fmt: Format file' }),
   },
}
-- vim: ts=3 sts=3 sw=3 et
