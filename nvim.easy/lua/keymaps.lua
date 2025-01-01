-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.opt.hlsearch = true
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
-- Completion keymaps
--------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>se", function()
   -- Shortcut edit snippet file for the current filetype
   -- Get the current filetype
   local boilerplate = vim.fn.expand(lua_snippet_dir .. "boilerplate.lua")
   local filetype = vim.bo.filetype
   -- Construct the path to the snippet file based on the filetype
   local snippet = vim.fn.expand(lua_snippet_dir .. filetype .. ".lua")
   -- Check if the file exists
   if vim.fn.filereadable(snippet) == 1 then
      vim.cmd("split " .. snippet)
   else
      -- Notify the user and create a new snippet file
      vim.notify("No snippet file found for filetype: " .. filetype .. ". Creating a new one.",
         vim.log.levels.INFO)
      -- Ensure the directory exists
      vim.fn.mkdir(vim.fn.expand(lua_snippet_dir), "p")
      -- Copy the boilerplate file to the new snippet file if boilerplate exists
      if vim.fn.filereadable(boilerplate) == 1 then
         vim.fn.system({ "cp", boilerplate, snippet })
         vim.notify("Copied boilerplate to " .. snippet, vim.log.levels.INFO)
      else
         vim.notify("Boilerplate file not found: " .. boilerplate, vim.log.levels.ERROR)
      end

      vim.cmd("split " .. snippet)
   end
end, { noremap = true, silent = true, desc = "Edit LuaSnip snippets for current filetype" })

vim.keymap.set("n", "<leader>ss", function()
   -- Shortcut to reload snippets for the current filetype
   local ft = vim.bo.filetype
   local snippet = vim.fn.expand(lua_snippet_dir .. ft .. ".lua")
   if vim.fn.filereadable(snippet) == 1 then
      loadfile(snippet)()
      vim.notify(string.format("Snippets reloaded for filetype: %s", ft), vim.log.levels.INFO)
   else
      vim.notify(string.format("No snippets found for filetype: %s", ft), vim.log.levels.WARN)
   end
end, { noremap = true, silent = true, desc = "Reload snippets for current filetype" })

vim.keymap.set("v", "<Tab>",
   -- shortcut to capture selected text for TM_SELECTED_TEXT snippet
   [[<Esc><cmd>lua require("luasnip.util.select").pre_yank("z")<Cr>gv"zy<cmd>lua require('luasnip.util.select').post_yank("z")<Cr>]])

--------------------------------------------------------------------------------
-- dap shortcuts
--------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>db', require('dap').toggle_breakpoint, { desc = 'DAP: toggle breakpoint' })
vim.keymap.set('n', '<leader>dc', require('dap').continue, { desc = 'DAP: continue' })

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
-- gitsigns shortcuts
--------------------------------------------------------------------------------
-- harpoon management edit(e) and add(a)
local harpoon = require('harpoon')
vim.keymap.set('n', '<leader>a', function()
   harpoon:list():append()
   print('Harpoon: appended ' .. vim.fn.expand('%:t'))
end, { desc = 'Harpoon: Mark add' })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set('n', '<C-p>', function()
   harpoon:list():prev()
end, { desc = 'Harpoon: previous' })
vim.keymap.set('n', '<C-n>', function()
   harpoon:list():next()
end, { desc = 'Harpoon: next' })

-- harpoon list
vim.keymap.set('n', '<leader><C-h>', function()
   harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Harpoon: Marks list' })

-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
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

vim.keymap.set("n", "<leader>H", function() toggle_telescope(harpoon:list()) end,
   { desc = "Telescope: [H]arpoon list" })

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
vim.keymap.set('n', '<leader>gg', ':Neogit kind=auto<cr>', { desc = 'Neogit: Git status CLI' })
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
-- symbols-outline keymaps
--------------------------------------------------------------------------------
-- Keybinding to toggle the Symbols Outline
vim.keymap.set("n", "<leader>oo", "<cmd>SymbolsOutline<CR>", { desc = "Outline: file outline" })

--------------------------------------------------------------------------------
-- undotree keymaps
--------------------------------------------------------------------------------
vim.keymap.set("n", "\\u", function()
      print "Create ~/undotree_debug.log to debug"
      vim.cmd.UndotreeToggle()
   end,
   { desc = "Toggle 'Undotree'" })

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
-- Keymaps for common Telescope commands
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>E', function()
   builtin.find_files({
      prompt_title = 'Find Files (<esc> to quit)',
   })
end, { desc = 'Telescope: [E]xplorer' })

vim.keymap.set('n', '<leader>R', function()
   builtin.oldfiles({
      prompt_title = 'Recent Files (<esc> to quit)',
   })
end, { desc = 'Telescope: [R]ecent files' })

vim.keymap.set('n', '<leader>G', function()
   builtin.live_grep({
      prompt_title = 'Liverep Files (<esc> to quit)',
   })
end, { desc = 'Telescope: live [G]rep live' })
--------------------------------------------------------------------------------
-- neo-tree keymaps
--------------------------------------------------------------------------------
-- <leader>K for more info on cWORD snacks-lazygit-table-of-contents
vim.keymap.set('n', '<leader>gf', function()
   Snacks.lazygit.log_file()
end, { desc = "Snacks: git log for current file" })

vim.keymap.set('n', '<leader>gl', function()
   Snacks.lazygit.log()
end, { desc = "Snacks: git log" })

vim.keymap.set('n', '<leader>ol', function()
   Snacks.lazygit()
end, { desc = "Snacks: Lazygit: tui" })

-- <leader>K for more info on cWORD snacks-terminal-table-of-contents
vim.keymap.set('n', '<leader>ot', function()
   Snacks.terminal()
end, { desc = "Snacks: Terminal: bash" })

-- <leader>K for more info on cWORD snacks-bufdelete-table-of-contents
vim.keymap.set('n', '<leader>bd', function()
   Snacks.bufdelete()
end, { desc = "Delete Buffer" })

-- <leader>K for more info on cWORD snacks-dim-table-of-contents
local dim_enabled = false
vim.keymap.set('n', '\\f', function()
   if dim_enabled then
      Snacks.dim.disable()
      dim_enabled = false
      vim.notify("Dimming disabled", vim.log.levels.INFO)
   else
      Snacks.dim()
      dim_enabled = true
      vim.notify("Dimming enabled", vim.log.levels.INFO)
   end
end, { desc = "Toggle 'focus/dim'" })
-- vim: ts=3 sts=3 sw=3 et
