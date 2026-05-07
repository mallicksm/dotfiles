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

vim.keymap.set('n', '<leader>E', function()
   require('telescope.builtin').find_files({ prompt_title = 'Find Files (<esc> to quit)' })
end, { desc = 'Telescope: [E]xplorer' })

vim.keymap.set('n', '<leader>R', function()
   require('telescope.builtin').oldfiles({ prompt_title = 'Recent Files (<esc> to quit)' })
end, { desc = 'Telescope: [R]ecent files' })

-- <leader>G prompts for an extension first, then runs live_grep filtered to
-- that file type via ripgrep's --glob. Defaults to the current buffer's
-- extension. Empty + <Enter> = unfiltered grep across all files.
-- Brace expansion works: e.g. {v,vh,sv,svh} for all verilog flavors.
vim.keymap.set('n', '<leader>G', function()
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
end, { desc = 'Telescope: live [G]rep (with optional extension filter)' })

vim.keymap.set('n', '<leader>B', function()
   require('telescope.builtin').buffers({ prompt_title = 'Buffers (<esc> to quit)' })
end, { desc = 'Telescope: Open [B]uffers' })

vim.keymap.set('n', '<leader>oo', function()
   require('telescope.builtin').lsp_document_symbols({ prompt_title = 'Document Symbols (<esc> to quit)' })
end, { desc = 'Outline: LSP document symbols' })

-- vim: ts=3 sts=3 sw=3 et
