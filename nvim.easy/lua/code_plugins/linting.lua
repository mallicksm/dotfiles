return {
   'mfussenegger/nvim-lint',
   event = { 'BufReadPre', 'BufNewFile' },
   config = function()
      require('lint').linters_by_ft = {
         c = { 'clangtidy' },
         python = { 'pylint' },
      }
   end,
}
-- vim: ts=3 sts=3 sw=3 et
