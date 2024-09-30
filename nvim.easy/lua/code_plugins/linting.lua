return {
   'mfussenegger/nvim-lint',
   event = { 'BufReadPre', 'BufNewFile' },
   config = function()
      require('lint').linters_by_ft = {
         c = { 'clangtidy' },
         python = { 'pylint' },
      }
      vim.keymap.set('n', '<leader>ml', function()
         require('lint').try_lint()
      end, { desc = 'Lnt: Trigger linting' })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
