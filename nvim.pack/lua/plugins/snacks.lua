-- snacks.nvim -- folke's collection (lazygit, terminal, bufdelete, dim, image).
require('snacks').setup({
   -- snacks.bigfile: replaces the old `nvim.bare` wrapper trick. When a
   -- file's bytes >= `size` OR its average line length is "minified",
   -- snacks attaches a BufReadPre handler that disables treesitter, LSP
   -- attach, syntax sync, matchparen, and other O(N) features *for that
   -- buffer only*. 50-200 MB logs open in tens of ms instead of stalling.
   -- `notify=true` toasts once when triggered so we know we're in degraded
   -- mode. size = 10 MB catches sim logs / waveform dumps without false-
   -- positive on big source files.
   bigfile = {
      enabled     = true,
      notify      = true,
      size        = 10 * 1024 * 1024,
      line_length = 1000,
   },
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
      -- Drop `pdf` from the default formats list. Snacks otherwise registers its
      -- own BufReadCmd for `*.pdf` and tries to render the first page via
      -- `magick`, which (a) fails noisily on this box where ImageMagick isn't
      -- installed and (b) collides with our `*.pdf` BufReadCmd in
      -- lua/autocmds.lua that hands PDFs to evince. Keep `pdf` out so PDFs flow
      -- cleanly through our autocmd. (Videos like mp4/mov/avi/mkv/webm are still
      -- here but `magick` can't render them without ffmpeg -- prune them too if
      -- you start seeing similar warnings on those.)
      formats = {
         'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'tiff', 'heic', 'avif',
         'mp4', 'mov', 'avi', 'mkv', 'webm', 'icns',
      },
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
