-- nvim-lint -- on-demand linting (no on-save autocmd by design;
-- matches the format-on-save policy). Trigger via <leader>pl.
require('lint').linters_by_ft = {
   c      = { 'clangtidy' },
   python = { 'pylint' },
   sh     = { 'shellcheck' },
   bash   = { 'shellcheck' },
   -- zsh: shellcheck does not support zsh; use `zsh -n` for syntax checks.
}

vim.keymap.set('n', '<leader>pl', function()
   require('lint').try_lint()
end, { desc = 'ls[p]: trigger linting (nvim-lint)' })

-- vim: ts=3 sts=3 sw=3 et
