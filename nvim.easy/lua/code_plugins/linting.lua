return {
   'mfussenegger/nvim-lint',
   event = { 'BufReadPre', 'BufNewFile' },
   config = function()
      require('lint').linters_by_ft = {
         c      = { 'clangtidy' },
         python = { 'pylint' },
         sh     = { 'shellcheck' },
         bash   = { 'shellcheck' },
         -- zsh: shellcheck does not support zsh; nothing to wire here. Use `zsh -n` for syntax checks.
      }
   end,
}
-- vim: ts=3 sts=3 sw=3 et
