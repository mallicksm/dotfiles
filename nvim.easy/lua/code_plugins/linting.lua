return {
   'mfussenegger/nvim-lint',
   event = { 'BufReadPre', 'BufNewFile' },
   keys = {
      { '<leader>ml', function() require('lint').try_lint() end, desc = 'Lnt: Trigger linting' },
   },
   config = function()
      require('lint').linters_by_ft = {
         c      = { 'clangtidy' },
         python = { 'pylint' },
         sh     = { 'shellcheck' },
         bash   = { 'shellcheck' },
         -- zsh: shellcheck does not support zsh; nothing to wire here. Use `zsh -n` for syntax checks.
      }
      -- Linting is manual: <leader>ml triggers `lint.try_lint()`.
      -- (No BufWritePost/InsertLeave autocmd by design -- matches format-on-save policy.)
   end,
}
-- vim: ts=3 sts=3 sw=3 et
