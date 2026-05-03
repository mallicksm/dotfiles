-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Rapid quit keymap
vim.keymap.set('n', 'gq', 'q', { desc = 'Nav: Macro' })
vim.keymap.set('n', 'q', '<cmd>q<CR>', { desc = 'Nav: Quit if no change' })
vim.keymap.set('n', '<leader>q', '<cmd>qa<CR>', { desc = 'Nav: Quit all if no change' })
vim.keymap.set('n', '<leader>x', '<cmd>wqa!<CR>', { desc = 'Nav: Write quit all' })

-- Keybinds to make split navigation easier.
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<leader>h', '<C-w><C-h>', { desc = 'Nav: left window' })
vim.keymap.set('n', '<leader>l', '<C-w><C-l>', { desc = 'Nav: right window' })
vim.keymap.set('n', '<leader>j', '<C-w><C-j>', { desc = 'Nav: lower window' })
vim.keymap.set('n', '<leader>k', '<C-w><C-k>', { desc = 'Nav: upper window' })

--------------------------------------------------------------------------------
-- dap shortcuts
--------------------------------------------------------------------------------
-- Wrap require()s in functions so this file doesn't break if dap is ever lazy-loaded.
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'DAP: toggle breakpoint' })
vim.keymap.set('n', '<leader>dc', function() require('dap').continue() end, { desc = 'DAP: continue' })
vim.keymap.set('n', '<leader>dr', function() require('dap').restart() end, { desc = 'DAP: restart' })

--------------------------------------------------------------------------------
-- formatting shortcuts
--------------------------------------------------------------------------------
vim.keymap.set({ 'n', 'v' }, '<leader>mp', function()
   require('conform').format({
      async = true,
      lsp_format = 'fallback',
      timeout_ms = 1800,
   })
end, { desc = 'Fmt: Format file' })

--------------------------------------------------------------------------------
-- linting shortcuts
--------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>ml', function()
   require('lint').try_lint()
end, { desc = 'Lnt: Trigger linting' })

--------------------------------------------------------------------------------
-- gitsigns shortcuts
--------------------------------------------------------------------------------
vim.keymap.set('n', '\\b', ':Gitsigns toggle_current_line_blame<cr>', { desc = "Toggle 'Git line blame'" })
vim.keymap.set('n', '<leader>gs', ':Gitsigns stage_buffer<cr>', { desc = 'GitSigns: Stage entire buffer' })
vim.keymap.set('n', '<leader>gu', function()
   local bufname = vim.api.nvim_buf_get_name(0)
   vim.cmd('!git restore --staged ' .. bufname)
end, { desc = 'Git: Unstage buffer' })
vim.keymap.set('n', '<leader>gj', ':Gitsigns next_hunk<cr>', { desc = 'GitSigns: Hunk: next' })
vim.keymap.set('n', '<leader>gk', ':Gitsigns prev_hunk<cr>', { desc = 'GitSigns: Hunk: previous' })

--------------------------------------------------------------------------------
-- harpoon shortcuts
--------------------------------------------------------------------------------
-- harpoon management edit(e) and add(a)
-- All harpoon requires are deferred so this file doesn't break if harpoon ever lazy-loads.
vim.keymap.set('n', '<leader>a', function()
   require('harpoon'):list():add()
   print('Harpoon: added ' .. vim.fn.expand('%:t'))
end, { desc = 'Harpoon: Mark add' })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set('n', '<C-p>', function()
   require('harpoon'):list():prev()
end, { desc = 'Harpoon: previous' })
vim.keymap.set('n', '<C-n>', function()
   require('harpoon'):list():next()
end, { desc = 'Harpoon: next' })

-- harpoon list
vim.keymap.set('n', '<leader><C-h>', function()
   local harpoon = require('harpoon')
   harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Harpoon: Marks list' })

-- Harpoon-list-as-telescope-picker. Local to this file; used only by <leader>H below.
local function harpoon_telescope_picker(harpoon_files)
   local conf = require("telescope.config").values
   local file_paths = {}
   for _, item in ipairs(harpoon_files.items) do
      table.insert(file_paths, item.value)
   end

   require("telescope.pickers").new({}, {
      prompt_title = "Harpoon (<esc> to quit)",
      finder = require("telescope.finders").new_table({
         results = file_paths,
      }),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
   }):find()
end

vim.keymap.set("n", "<leader>H", function() harpoon_telescope_picker(require('harpoon'):list()) end,
   { desc = "Telescope: [H]arpoon list" })

--------------------------------------------------------------------------------
-- lualine keymaps
--------------------------------------------------------------------------------
-- `:LualineToggle` is registered in lua/core_plugins/lualine.lua.
vim.keymap.set("n", "\\\\", '<cmd>LualineToggle<cr>', { desc = "Toggle 'lualine'" })

--------------------------------------------------------------------------------
-- mini keymaps
--------------------------------------------------------------------------------
vim.keymap.set("n", "\\t", function()
   local lazy_stats = require("lazy").stats()
   local startup_time = lazy_stats.startuptime
   local plugin_count = lazy_stats.count
   vim.notify("Neovim started in " .. startup_time .. "ms with " .. plugin_count .. " plugins.",
      vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Toggle 'startup time'" })

vim.keymap.set('n', '\\B', function()
   if vim.o.background == 'dark' then
      vim.o.background = 'light'
   else
      vim.o.background = 'dark'
   end
end, { desc = "Toggle 'background color'" })
-- only adopt C Arrow for resize
vim.keymap.set('n', '<C-Left>', '"<Cmd>vertical resize -" . v:count1 . "<CR>"',
   { expr = true, replace_keycodes = false, desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Down>', '"<Cmd>resize -"          . v:count1 . "<CR>"',
   { expr = true, replace_keycodes = false, desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Up>', '"<Cmd>resize +"          . v:count1 . "<CR>"',
   { expr = true, replace_keycodes = false, desc = 'Increase window height' })
vim.keymap.set('n', '<C-Right>', '"<Cmd>vertical resize +" . v:count1 . "<CR>"',
   { expr = true, replace_keycodes = false, desc = 'Increase window width' })

--------------------------------------------------------------------------------
-- neogit keymaps
--------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>gG', ':Neogit kind=auto<cr>', { desc = 'Neogit: Git status CLI' })
vim.keymap.set('n', '<leader>gd', function()
   if next(require('diffview.lib').views) == nil then
      vim.cmd('DiffviewOpen -uno')
   else
      vim.cmd('DiffviewClose')
   end
end, { desc = 'Diffview: toggle' })

--------------------------------------------------------------------------------
-- noice keymaps
--------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>nc", function()
   vim.cmd("Noice dismiss")
end, { noremap = true, silent = true, desc = "Clear Noice Messages" })

vim.keymap.set("n", "<leader>nm", function()
   vim.cmd("NoiceAll")
end, { noremap = true, silent = true, desc = "View Noice Messages" })

--------------------------------------------------------------------------------
-- document symbols outline
--------------------------------------------------------------------------------
-- Telescope-powered LSP document outline. Requires an LSP attached to the buffer
-- that supports textDocument/documentSymbol (clangd, pyright, lua_ls, verible all do).
vim.keymap.set('n', '<leader>oo', function()
   require('telescope.builtin').lsp_document_symbols({
      prompt_title = 'Document Symbols (<esc> to quit)',
   })
end, { desc = 'Outline: LSP document symbols' })

--------------------------------------------------------------------------------
-- undotree keymaps
--------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>ou", function()
      print "Create ~/undotree_debug.log to debug"
      vim.cmd.UndotreeToggle()
   end,
   { desc = "Undotree" })

--------------------------------------------------------------------------------
-- neo-tree keymaps
--------------------------------------------------------------------------------
-- Keybinding: Toggle Neo-tree file browser
vim.keymap.set('n', '<leader>e', function()
   require('neo-tree.command').execute({
      action = 'focus',
      source = 'filesystem',
      position = 'left',
      toggle = true,
      reveal_force_cwd = true,
   })
   -- Auto order files by type
   local state = require('neo-tree.sources.manager').get_state("filesystem")
   require('neo-tree.sources.common.commands').order_by_type(state)
end, { desc = 'Neo-tree: File browser toggle' })

-- Keybinding: Toggle Neo-tree buffer browser
vim.keymap.set('n', '<leader>ob', function()
   require('neo-tree.command').execute({
      action = 'show',
      source = 'buffers',
      position = 'right',
      toggle = true,
      reveal_force_cwd = true,
   })
end, { desc = "Neo-Tree: Buffer list" })

--------------------------------------------------------------------------------
-- telescope keymaps
--------------------------------------------------------------------------------
-- Defer telescope.builtin require so this file doesn't break if telescope ever lazy-loads.
vim.keymap.set('n', '<leader>E', function()
   require('telescope.builtin').find_files({
      prompt_title = 'Find Files (<esc> to quit)',
   })
end, { desc = 'Telescope: [E]xplorer' })

vim.keymap.set('n', '<leader>R', function()
   require('telescope.builtin').oldfiles({
      prompt_title = 'Recent Files (<esc> to quit)',
   })
end, { desc = 'Telescope: [R]ecent files' })

vim.keymap.set('n', '<leader>G', function()
   require('telescope.builtin').live_grep({
      prompt_title = 'Liverep Files (<esc> to quit)',
   })
end, { desc = 'Telescope: live [G]rep live' })

vim.keymap.set('n', '<leader>B', function()
   require('telescope.builtin').buffers({
      prompt_title = 'Buffers (<esc> to quit)',
   })
end, { desc = 'Telescope: Open [B]uffers' })

--------------------------------------------------------------------------------
-- Snacks keymaps
--------------------------------------------------------------------------------
-- All callbacks `require('snacks')` directly instead of relying on the global
-- `Snacks` symbol. require() is cached, so the runtime cost is one table
-- lookup per press; the upside is no load-order coupling.
-- <leader>K for more info on cWORD snacks-lazygit-table-of-contents
vim.keymap.set('n', '<leader>gf', function()
   require('snacks').lazygit.log_file()
end, { desc = "Snacks: git log for current file" })

vim.keymap.set('n', '<leader>gl', function()
   require('snacks').lazygit.log()
end, { desc = "Snacks: git log" })

vim.keymap.set('n', '<leader>gg', function()
   require('snacks').lazygit()
end, { desc = "Snacks: Lazygit: tui" })

-- <leader>K for more info on cWORD snacks-terminal-table-of-contents
vim.keymap.set('n', '<leader>T', function()
   require('snacks').terminal()
end, { desc = "Snacks: Terminal: bash" })

-- <leader>K for more info on cWORD snacks-bufdelete-table-of-contents
vim.keymap.set('n', '<leader>bd', function()
   require('snacks').bufdelete()
end, { desc = "Delete Buffer" })

-- <leader>K for more info on cWORD snacks-dim-table-of-contents
local dim_enabled = false
vim.keymap.set('n', '\\f', function()
   local snacks = require('snacks')
   if dim_enabled then
      snacks.dim.disable()
      dim_enabled = false
      vim.notify("Dimming disabled", vim.log.levels.INFO)
   else
      snacks.dim()
      dim_enabled = true
      vim.notify("Dimming enabled", vim.log.levels.INFO)
   end
end, { desc = "Toggle 'focus/dim'" })

--------------------------------------------------------------------------------
-- generic keymaps
--------------------------------------------------------------------------------
-- <leader>K: man / :help / xdg-open dispatch on <cWORD>. Logic in utils/.
vim.keymap.set('n', '<leader>K', function()
   require('utils.smart_open').open()
end, { noremap = true, silent = true, desc = 'Man page or help for word under cursor' })

-- :MdViewer is now registered in lua/user_commands.lua (utils/md_viewer.lua).

-- vim: ts=3 sts=3 sw=3 et
