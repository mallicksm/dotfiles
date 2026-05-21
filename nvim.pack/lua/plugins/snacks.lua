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
   terminal = {
      -- Mid-size centered float: 75% editor width, 55% height, rounded border.
      -- Fractions 0-1 = fraction of editor; integers > 1 = absolute row/col.
      win = { style = 'float', border = 'rounded', width = 0.75, height = 0.55, position = 'float' },
   },
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

vim.keymap.set('n', '<leader>gF', function() require('snacks').lazygit.log_file() end, { desc = 'Snacks: Lazygit: log current [F]ile' })
vim.keymap.set('n', '<leader>gL', function() require('snacks').lazygit.log() end,      { desc = 'Snacks: Lazygit: repo [L]og' })
vim.keymap.set('n', '<leader>gl', function() require('snacks').lazygit() end,          { desc = 'Snacks: [l]azygit TUI' })
-- Lives under <leader>v* alongside other "vim utilities" -- moved off bare
-- <leader>T after the toggle family migrated to <leader>T*.
vim.keymap.set('n', '<leader>vt', function() require('snacks').terminal() end, { desc = 'Vim: floating [t]erminal (snacks)' })
-- (snacks.bufdelete moved to <leader>vd in keymaps.lua under the
--  <leader>v* "vim introspection / utilities" family.)

-- vim: ts=3 sts=3 sw=3 et
