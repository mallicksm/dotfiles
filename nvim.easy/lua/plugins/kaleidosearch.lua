-- kaleidosearch.nvim: highlight multiple search terms with DISTINCT colors
-- per term. Useful for chasing several signals through a log file at once
-- (e.g. WARNING vs ERROR vs my_signal_name in a sim log), or for visually
-- diffing where N tokens occur in a buffer.
--
-- Why <leader>s* and not the plugin's <leader>c* defaults: <leader>ca is the
-- LSP code action (see code_plugins/lspconfig.lua) and the entire <leader>c
-- namespace is documented in which-key as "[C]ode action". <leader>s
-- ("[S]earch") was free, so we route there and disable the plugin's
-- keymaps.enabled. Group label is added in plugins/which-key.lua.
--
-- Optional dep: tpope/vim-repeat -> dot-repeat for AddCursorWord, so after
-- <leader>sa on one word you can `.` on the next word and it picks the next
-- color automatically.
return {
   'hamidi-dev/kaleidosearch.nvim',
   dependencies = {
      'tpope/vim-repeat',
   },
   keys = {
      { '<leader>ss', '<cmd>Kaleidosearch<cr>',              mode = 'n',          desc = 'Kaleido[s]earch: prompt for words to color' },
      { '<leader>sn', '<cmd>KaleidosearchAddWord<cr>',       mode = 'n',          desc = 'Kaleidosearch: add [n]ew word to highlights' },
      { '<leader>sa', '<cmd>KaleidosearchAddCursorWord<cr>', mode = { 'n', 'x' }, desc = 'Kaleidosearch: [a]dd cursor word / visual selection (.-repeatable)' },
      { '<leader>sc', '<cmd>KaleidosearchClear<cr>',         mode = 'n',          desc = 'Kaleidosearch: [c]lear all highlights' },
      { '<leader>sl', '<cmd>KaleidosearchColorLines<cr>',    mode = 'n',          desc = 'Kaleidosearch: color all [l]ines (identical lines share a color)' },
   },
   cmd = {
      'Kaleidosearch',
      'KaleidosearchClear',
      'KaleidosearchAddWord',
      'KaleidosearchAddCursorWord',
      'KaleidosearchColorLines',
   },
   opts = {
      keymaps          = { enabled = false }, -- we wire our own under <leader>s* (above)
      case_sensitive   = false,
      whole_word_match = false,               -- substring matches; flip to true if you want only \<word\> hits
   },
}
-- vim: ts=3 sts=3 sw=3 et
