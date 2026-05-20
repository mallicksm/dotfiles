-- telescope.nvim + ui-select + fzf-native (libfzf.so built in plugins.lua).
local telescope = require('telescope')
local actions   = require('telescope.actions')
local themes    = require('telescope.themes')

telescope.setup({
   defaults = {
      mappings = {
         i = { ['<esc>'] = actions.close },
      },
   },
   extensions = {
      ['ui-select'] = { themes.get_dropdown() },
   },
})

pcall(telescope.load_extension, 'ui-select')
pcall(telescope.load_extension, 'fzf')

-- <leader>t* -- [t]elescope family.
-- <leader>tf is plain oldfiles (Vim/Shada recent files) by design: no frecency,
-- no cwd preference, just the files Vim knows you opened before.

vim.keymap.set('n', '<leader>tf', function()
   require('telescope.builtin').oldfiles({ prompt_title = 'Oldfiles (<esc> to quit)' })
end, { desc = 'Telescope: old[f]iles' })

-- <leader>tg prompts for an extension first, then runs live_grep filtered to
-- that file type via ripgrep's --glob. Defaults to the current buffer's
-- extension. Empty + <Enter> = unfiltered grep across all files.
-- Brace expansion works: e.g. {v,vh,sv,svh} for all verilog flavors.
vim.keymap.set('n', '<leader>tg', function()
   local default = vim.fn.expand('%:e')
   vim.ui.input({
      prompt  = 'Live Grep -- extension (empty = all files): ',
      default = default,
   }, function(ext)
      if ext == nil then return end -- user pressed <esc>
      local opts = { prompt_title = 'Live Grep (<esc> to quit)' }
      if ext ~= '' then
         local glob = '*.' .. ext
         opts.additional_args = function() return { '--glob', glob } end
         opts.prompt_title    = 'Live Grep [' .. glob .. ']  (<esc> to quit)'
      end
      require('telescope.builtin').live_grep(opts)
   end)
end, { desc = 'Telescope: live [g]rep (with optional extension filter)' })

vim.keymap.set('n', '<leader>tb', function()
   require('telescope.builtin').buffers({ prompt_title = 'Buffers (<esc> to quit)' })
end, { desc = 'Telescope: open [b]uffers' })

-- <leader>te -- plain find_files. <leader>tf is oldfiles; <leader>te is
-- the dumb-but-fast current-project file explorer.
vim.keymap.set('n', '<leader>te', function()
   require('telescope.builtin').find_files({ prompt_title = 'Find Files (<esc> to quit)' })
end, { desc = 'Telescope: [E]xplorer (find_files)' })

-- <leader>td -- frecency-ranked DIRECTORIES from rupa/z's database (~/.z).
-- Default action lcd's into the picked dir; <C-f> from inside the picker
-- chains into find_files scoped to that dir (z + file pick combo).
-- Implementation: lua/utils/z_picker.lua.
vim.keymap.set('n', '<leader>td', function()
   require('utils.z_picker').open()
end, { desc = 'Telescope: z [d]irectories (frecency from ~/.z)' })

-- Lives under <leader>p* (ls[p] group) since it queries the LSP.
vim.keymap.set('n', '<leader>po', function()
   require('telescope.builtin').lsp_document_symbols({ prompt_title = 'Document Symbols (<esc> to quit)' })
end, { desc = 'ls[p]: [o]utline -- document symbols (telescope)' })

-- vim: ts=3 sts=3 sw=3 et
