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
         '<C-r>',
         function()
            require('telescope.builtin').registers({ prompt_title = 'Registers (<CR> paste, <C-e> edit)', layout_config = { height = 0.75 } })
         end,
         mode = 'i',
         desc = 'Telescope: registers (<CR> paste, <C-e> edit)',
      },
      {
         '<leader>tf',
         function()
            require('telescope.builtin').oldfiles({ prompt_title = 'Oldfiles (<esc> to quit)' })
         end,
         desc = 'Telescope: old[f]iles',
      },
      {
         '<leader>tr',
         function()
            require('telescope.builtin').resume()
         end,
         desc = 'Telescope: [r]esume last picker',
      },
      {
         '<leader>te',
         function()
            require('telescope.builtin').find_files({ prompt_title = 'Find Files (<esc> to quit)' })
         end,
         desc = 'Telescope: [e]xplorer (find_files)',
      },
      {
         '<leader>tE',
         function()
            require('telescope.builtin').find_files({
               prompt_title = 'Find Files - all (<esc> to quit)',
               hidden = true,
               no_ignore = true,
            })
         end,
         desc = 'Telescope: [E]xplorer all files (hidden + ignored)',
      },
      {
         -- <leader>tg uses telescope-live-grep-args: pass ripgrep args inline
         -- in the prompt, e.g.  foo -t lua  or  bar -g '*.{sv,svh}'  or
         -- baz --no-ignore . We pre-seed with a -g '*.<current-ext>' filter
         -- so the common case is just "type pattern after the seed". <C-k>
         -- in the prompt quotes the pattern (handy for multi-word search).
         -- Clear the prompt for an unfiltered grep across all files.
         -- NOTE: $VAR / ~ in paths are NOT expanded -- use full paths or :lcd.
         '<leader>tg',
         function()
            local ext = vim.fn.expand('%:e')
            local default_text = (ext ~= '' and string.format("-g '*.%s' ", ext)) or ''
            require('telescope').extensions.live_grep_args.live_grep_args({
               prompt_title = "Live Grep w/ rg args (-g '*.sv', -t lua, ...) -- <esc> to quit",
               default_text = default_text,
            })
         end,
         desc = 'Telescope: live [g]rep w/ rg args',
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
      'nvim-telescope/telescope-live-grep-args.nvim',
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
      pcall(telescope.load_extension, 'live_grep_args')

      -- which-key's registers preset owns cmdline <C-r> and normal/visual ".
      -- Re-assert insert-mode <C-r> after VimEnter so insert uses Telescope.
      vim.api.nvim_create_autocmd('VimEnter', {
         group = vim.api.nvim_create_augroup('user-force-insert-registers-telescope', { clear = true }),
         callback = function()
            vim.keymap.set('i', '<C-r>', function()
               require('telescope.builtin').registers({ prompt_title = 'Registers (<CR> paste, <C-e> edit)', layout_config = { height = 0.75 } })
            end, { desc = 'Telescope: registers (<CR> paste, <C-e> edit)' })
         end,
      })
   end,
}
-- vim: ts=3 sts=3 sw=3 et
