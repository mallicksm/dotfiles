return {
   'nvim-telescope/telescope.nvim',
   version = '*',
   -- Eager-load: telescope is a transitive dep for neogit/neo-tree and is
   -- referenced from LspAttach callbacks. Lazy-loading on keys alone risks
   -- nil dereferences before any of our keys are pressed.
   lazy = false,
   cmd = { 'Telescope' },
   keys = {
      {
         '<leader>tf',
         function()
            require('telescope.builtin').oldfiles({ prompt_title = 'Oldfiles (<esc> to quit)' })
         end,
         desc = 'Telescope: old[f]iles',
      },
      {
         '<leader>te',
         function()
            require('telescope.builtin').find_files({ prompt_title = 'Find Files (<esc> to quit)' })
         end,
         desc = 'Telescope: [e]xplorer (find_files)',
      },
      {
         -- <leader>tg prompts for an extension first, then runs live_grep filtered
         -- to that file type via ripgrep's --glob. Defaults to the current
         -- buffer's extension so the common case is just "<leader>tg <Enter>".
         -- Leave the prompt empty + <Enter> for an unfiltered grep across all files.
         -- Brace expansion works: e.g. {v,vh,sv,svh} for all verilog flavors.
         '<leader>tg',
         function()
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
                  opts.prompt_title = 'Live Grep [' .. glob .. ']  (<esc> to quit)'
               end
               require('telescope.builtin').live_grep(opts)
            end)
         end,
         desc = 'Telescope: live [g]rep (with optional extension filter)',
      },
      {
         '<leader>tb',
         function()
            require('telescope.builtin').buffers({ prompt_title = 'Buffers (<esc> to quit)' })
         end,
         desc = 'Telescope: open [b]uffers',
      },
      {
         -- <leader>td -- frecency-ranked DIRECTORIES from rupa/z's database (~/.z).
         -- <CR> lcds into the picked dir; <C-f> chains into find_files scoped to that dir.
         -- Implementation: lua/utils/z_picker.lua.
         '<leader>td',
         function()
            require('utils.z_picker').open()
         end,
         desc = 'Telescope: z [d]irectories (frecency from ~/.z)',
      },
      {
         '<leader>po',
         function()
            require('telescope.builtin').lsp_document_symbols({ prompt_title = 'Document Symbols (<esc> to quit)' })
         end,
         desc = 'ls[p]: [o]utline -- document symbols (telescope)',
      },
   },
   dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
   },
   config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local themes = require('telescope.themes')

      -- Telescope setup
      telescope.setup({
         defaults = {
            mappings = {
               i = {
                  ['<esc>'] = actions.close, -- Close Telescope with <esc>
               },
            },
         },
         extensions = {
            ['ui-select'] = {
               themes.get_dropdown(), -- Dropdown theme for `ui-select`
            },
         },
      })

      pcall(telescope.load_extension, 'ui-select')
      pcall(telescope.load_extension, 'fzf')
   end,
}
-- vim: ts=3 sts=3 sw=3 et
