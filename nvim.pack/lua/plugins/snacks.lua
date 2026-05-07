-- snacks.nvim -- folke's collection (lazygit, terminal, bufdelete, dim, image).
require('snacks').setup({
   terminal = { win = { style = 'float' } },
   lazygit = {
      -- $LG_CONFIG_FILE points at ~/dotfiles/initrc/lazygit.config.yml in
      -- shell rc; it's the single source of truth for our gruvbox theme,
      -- zvim editor, delta pager flags. configure=false stops snacks from
      -- generating a competing theme YAML.
      configure = false,
      win = { style = 'lazygit', border = 'rounded', width = 0.9, height = 0.9 },
   },
   image = {
      enabled = true,
      doc     = { enabled = true, inline = true, float = true, max_width = 80, max_height = 40 },
      convert = { magick = { 'magick' } },
   },
})

-- Module-level so toggle persists across `\f` presses.
local dim_enabled = false

vim.keymap.set('n', '<leader>gf', function() require('snacks').lazygit.log_file() end, { desc = 'Snacks: git log for current file' })
vim.keymap.set('n', '<leader>gl', function() require('snacks').lazygit.log() end,      { desc = 'Snacks: git log' })
vim.keymap.set('n', '<leader>gg', function() require('snacks').lazygit() end,          { desc = 'Snacks: Lazygit: tui' })
vim.keymap.set('n', '<leader>T',  function() require('snacks').terminal() end,         { desc = 'Snacks: Terminal: bash' })
vim.keymap.set('n', '<leader>bd', function() require('snacks').bufdelete() end,        { desc = 'Delete Buffer' })
vim.keymap.set('n', '\\f', function()
   local snacks = require('snacks')
   if dim_enabled then
      snacks.dim.disable(); dim_enabled = false
      vim.notify('Dimming disabled', vim.log.levels.INFO)
   else
      snacks.dim();         dim_enabled = true
      vim.notify('Dimming enabled', vim.log.levels.INFO)
   end
end, { desc = "Toggle 'focus/dim'" })

-- vim: ts=3 sts=3 sw=3 et
