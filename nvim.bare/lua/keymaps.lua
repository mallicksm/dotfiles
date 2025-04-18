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
-- symbols-outline keymaps
--------------------------------------------------------------------------------
-- Keybinding to toggle the Symbols Outline
vim.keymap.set("n", "<leader>oo", "<cmd>SymbolsOutline<CR>", { desc = "Outline: file outline" })

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
-- generic keymaps
--------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>K", function()
   local word = vim.fn.expand("<cWORD>") -- Include words with hyphens (like `foo-bar`)
   -- Function to check if the word is a URL
   local function is_url(text)
      return text:match("^https?://") ~= nil
   end
   if is_url(word) then
      -- Open the URL with xdg-open
      local open_command = "xdg-open " .. vim.fn.shellescape(word)
      if vim.fn.executable("xdg-open") == 1 then
         vim.fn.system(open_command)
         vim.notify("Opening URL: " .. word, vim.log.levels.INFO)
      else
         vim.notify("xdg-open not found on your system", vim.log.levels.ERROR)
      end
   else
      -- Try to open a man page for the word
      local man_command = vim.fn.executable("man") == 1 and vim.fn.system("man -w " .. word)
      if man_command and vim.v.shell_error == 0 then
         vim.cmd("Man " .. word)
      else
         -- Fallback to Vim help if no man page exists
         local ok = pcall(function() vim.cmd("help " .. word) end)
         if not ok then
            vim.notify("No man page or help available for: " .. word, vim.log.levels.WARN)
         end
      end
   end
end, { noremap = true, silent = true, desc = "Man page or help for word under cursor" })

-- vim: ts=3 sts=3 sw=3 et
