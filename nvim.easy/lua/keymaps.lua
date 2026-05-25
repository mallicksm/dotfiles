-- Basic, plugin-agnostic keymaps. Plugin-specific keys live in each plugin's
-- `keys = { ... }` lazy spec (search the codebase for "keys = {" to find them).
-- See `:help vim.keymap.set()`.

-- Clear search highlight on <Esc> in normal mode.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Re-enable hlsearch on `*` and `#` so the per-match Search highlight comes
-- back after we've used a plugin that explicitly disabled it (kaleidosearch
-- does `set nohlsearch` after every call so its color highlights aren't
-- visually clashed with vim's yellow Search). Without this, after using
-- kaleidosearch once, plain `*` would jump but never highlight again.
vim.keymap.set('n', '*', '*<cmd>set hlsearch<CR>', { desc = 'Search forward for <cword> (with hlsearch)'  })
vim.keymap.set('n', '#', '#<cmd>set hlsearch<CR>', { desc = 'Search backward for <cword> (with hlsearch)' })

-- Quit shortcuts. `q` quits if no changes; `gq` is preserved as the original
-- `q` (start macro) since `q` is overloaded by us.
vim.keymap.set('n', 'gq',         'q',             { desc = 'Nav: Macro' })
vim.keymap.set('n', 'q',          '<cmd>q<CR>',    { desc = 'Nav: Quit if no change' })
vim.keymap.set('n', '<leader>q',  '<cmd>qa<CR>',   { desc = 'Nav: Quit all if no change' })
vim.keymap.set('n', '<leader>x',  '<cmd>wqa!<CR>', { desc = 'Nav: Write quit all' })

-- Window navigation. See `:help wincmd`.
vim.keymap.set('n', '<leader>h', '<C-w><C-h>', { desc = 'Nav: left window' })
vim.keymap.set('n', '<leader>l', '<C-w><C-l>', { desc = 'Nav: right window' })
vim.keymap.set('n', '<leader>j', '<C-w><C-j>', { desc = 'Nav: lower window' })
vim.keymap.set('n', '<leader>k', '<C-w><C-k>', { desc = 'Nav: upper window' })

-- <leader>v* -- option toggles + vim introspection commands.
-- Window-local (vim.wo) toggles only affect the active split; global ones
-- (vim.opt) affect every window.
-- (Moved off <leader>T*: T was rarely the prefix I reached for. v now hosts
--  both toggles and :registers/:marks/:messages/etc. -- see further down.)
vim.keymap.set('n', '<leader>vw', function()
   vim.wo.wrap = not vim.wo.wrap
   vim.notify('wrap = ' .. tostring(vim.wo.wrap), vim.log.levels.INFO)
end, { desc = 'Toggle line wrap (this window)' })

vim.keymap.set('n', '<leader>vl', function()
   vim.wo.cursorline = not vim.wo.cursorline
   vim.notify('cursorline = ' .. tostring(vim.wo.cursorline), vim.log.levels.INFO)
end, { desc = 'Toggle cursor line highlight (this window)' })

-- <leader>vc cycles search case-sensitivity through the 3 useful states:
--   sensitive    /Foo  matches  Foo            ignorecase=off, smartcase=off
--   insensitive  /Foo  matches  Foo / foo / FOO ignorecase=on,  smartcase=off
--   smart        /foo  matches  Foo / foo / FOO ignorecase=on,  smartcase=on
--                /Foo  matches  Foo only       (uppercase => case-sensitive)
-- Default (set in options.lua) is "smart". Pressing <leader>vc walks
-- smart -> sensitive -> insensitive -> smart -> ...
vim.keymap.set('n', '<leader>vc', function()
   local ic = vim.opt.ignorecase:get()
   local sc = vim.opt.smartcase:get()
   local label
   if ic and sc then           -- smart -> sensitive
      vim.opt.ignorecase = false
      vim.opt.smartcase  = false
      label = 'sensitive'
   elseif not ic then          -- sensitive -> insensitive
      vim.opt.ignorecase = true
      vim.opt.smartcase  = false
      label = 'insensitive'
   else                        -- insensitive -> smart
      vim.opt.ignorecase = true
      vim.opt.smartcase  = true
      label = 'smart'
   end
   vim.notify('case: ' .. label, vim.log.levels.INFO)
end, { desc = 'Cycle search case sensitivity (smart -> sensitive -> insensitive)' })

vim.keymap.set('n', '<leader>vr', function()
   vim.wo.relativenumber = not vim.wo.relativenumber
   vim.notify('relativenumber = ' .. tostring(vim.wo.relativenumber), vim.log.levels.INFO)
end, { desc = 'Toggle relative line numbers (this window)' })

vim.keymap.set('n', '<leader>vn', function()
   vim.wo.number = not vim.wo.number
   vim.notify('number = ' .. tostring(vim.wo.number), vim.log.levels.INFO)
end, { desc = 'Toggle absolute line numbers (this window)' })

vim.keymap.set('n', '<leader>vs', function()
   vim.wo.list = not vim.wo.list
   vim.notify('list = ' .. tostring(vim.wo.list), vim.log.levels.INFO)
end, { desc = 'Toggle whitespace markers (tabs / EOL / trailing)' })

-- `vv` (cursorcolumn) is the duplicate-letter mnemonic for `v` itself.
vim.keymap.set('n', '<leader>vv', function()
   vim.wo.cursorcolumn = not vim.wo.cursorcolumn
   vim.notify('cursorcolumn = ' .. tostring(vim.wo.cursorcolumn), vim.log.levels.INFO)
end, { desc = 'Toggle vertical cursor column ruler (this window)' })

-- Diagnostics toggle is buffer-local via vim.diagnostic.{is_enabled,enable}.
-- The 0.10+ API takes a boolean as the first arg; passing `not enabled`
-- flips the state. bufnr=0 means "current buffer".
vim.keymap.set('n', '<leader>pD', function()
   local enabled = vim.diagnostic.is_enabled({ bufnr = 0 })
   vim.diagnostic.enable(not enabled, { bufnr = 0 })
   vim.notify('diagnostic = ' .. tostring(not enabled) .. ' (this buffer)', vim.log.levels.INFO)
end, { desc = 'Toggle all LSP diagnostics (this buffer)' })

-- LSP inlay hints (clangd, lua_ls, etc. emit these). Buffer-local.
-- nvim 0.10+ API: vim.lsp.inlay_hint.{is_enabled, enable}.
vim.keymap.set('n', '<leader>pi', function()
   local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
   vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
   vim.notify('inlay hints = ' .. tostring(not enabled) .. ' (this buffer)', vim.log.levels.INFO)
end, { desc = 'Toggle LSP inlay hints (this buffer)' })

-- Render-markdown.nvim on/off. After :RenderMarkdown toggle we read the
-- updated state.enabled to print the new value (instead of guessing).
vim.keymap.set('n', '<leader>Vm', function()
   vim.cmd('RenderMarkdown toggle')
   vim.notify('render-markdown = ' .. tostring(require('render-markdown.state').enabled), vim.log.levels.INFO)
end, { desc = 'Toggle render-markdown preview rendering' })

-- Treesitter highlight on/off (current buffer). Useful when TS highlight
-- is misbehaving and you want to compare against vim's regex syntax.
-- vim.treesitter.highlighter.active[buf] is the canonical "is TS attached"
-- check; cheaper than tracking our own per-buf flag.
vim.keymap.set('n', '<leader>vt', function()
   local buf = vim.api.nvim_get_current_buf()
   if vim.treesitter.highlighter.active[buf] then
      vim.treesitter.stop(buf)
      vim.notify('treesitter highlight = false (this buffer)', vim.log.levels.INFO)
   else
      local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
      if not lang then
         vim.notify('treesitter: no parser for ft=' .. vim.bo[buf].filetype, vim.log.levels.WARN)
         return
      end
      local ok, err = pcall(vim.treesitter.start, buf, lang)
      if ok then
         vim.notify('treesitter highlight = true (this buffer)', vim.log.levels.INFO)
      else
         vim.notify('treesitter start failed: ' .. tostring(err), vim.log.levels.ERROR)
      end
   end
end, { desc = 'Toggle Treesitter highlight (compare vs regex syntax)' })

-- LSP virtual_text on/off (global). Different from <leader>td which kills
-- ALL diagnostics in the buffer; this only hides the inline `●` text and
-- keeps signs / underlines so you still know where issues are. We snapshot
-- the previous virtual_text config in a closure-local var so subsequent
-- "on" restores your custom prefix/spacing instead of nvim's default.
do
   local prev_vt
   vim.keymap.set('n', '<leader>pv', function()
      local cur = vim.diagnostic.config().virtual_text
      if cur then
         prev_vt = cur
         vim.diagnostic.config({ virtual_text = false })
         vim.notify('LSP virtual_text = false', vim.log.levels.INFO)
      else
         vim.diagnostic.config({ virtual_text = prev_vt or { prefix = '●', spacing = 2 } })
         vim.notify('LSP virtual_text = true', vim.log.levels.INFO)
      end
   end, { desc = 'Toggle LSP inline diagnostic text (signs/underlines stay)' })
end

-- Format-on-save (conform.nvim) -- session-local opt-in.
-- Strategy: register the BufWritePre autocmd ONCE here (always present),
-- and gate it on vim.g.format_on_save. The toggle just flips the flag --
-- no add/remove of the autocmd, so behavior is consistent and idempotent.
-- Default is OFF, matching your existing manual <leader>pf policy.
vim.api.nvim_create_autocmd('BufWritePre', {
   group = vim.api.nvim_create_augroup('user-format-on-save', { clear = true }),
   callback = function(args)
      if vim.g.format_on_save then
         require('conform').format({ bufnr = args.buf, lsp_format = 'fallback', timeout_ms = 1800 })
      end
   end,
})
vim.keymap.set('n', '<leader>Vf', function()
   vim.g.format_on_save = not vim.g.format_on_save
   vim.notify('format-on-save = ' .. tostring(vim.g.format_on_save), vim.log.levels.INFO)
end, { desc = 'Toggle format-on-save (conform; default off)' })

-- Noice on/off. We track via vim.g.noice_disabled (a string flag, since
-- noice itself doesn't expose a queryable enabled state). Useful when
-- noice is hiding raw :messages output you want to inspect, or for
-- isolating a UI bug.
vim.keymap.set('n', '<leader>Vn', function()
   if vim.g.noice_disabled then
      vim.cmd('Noice enable')
      vim.g.noice_disabled = false
      vim.notify('noice = true', vim.log.levels.INFO)
   else
      vim.cmd('Noice disable')
      vim.g.noice_disabled = true
      vim.notify('noice = false', vim.log.levels.INFO)
   end
end, { desc = 'Toggle Noice cmdline/messages UI' })

-- <leader>v* -- vim introspection commands. None of these are bound by
-- default in vim; this gives the "show me current state" family a
-- discoverable keybind home (and gets you out of typing `:registers<CR>`
-- a hundred times a day). Most open as native vim listings; command/search
-- history use Telescope because fuzzy filtering is useful there.
vim.keymap.set('n', '<leader>v:', function()
   require('utils.telescope_history').command_history({ prompt_title = 'Command History (<CR> run, <esc> to quit)' })
end, { desc = 'Telescope: command history (:)' })

vim.keymap.set('n', '<leader>v/', function()
   require('utils.telescope_history').search_history({ prompt_title = 'Search History (<CR> use, <esc> to quit)' })
end, { desc = 'Telescope: search history (/ and ?)' })

vim.keymap.set('n', '<leader>vm', function()
   local out = vim.fn.execute('messages'):gsub('^%s+', ''):gsub('%s+$', '')
   if out == '' then
      vim.notify('No :messages', vim.log.levels.INFO)
   else
      vim.cmd('messages')
   end
end, { desc = 'Show :messages (raw, bypasses Noice; notify if empty)' })
-- snacks.bufdelete is preferred over raw :bdelete -- prompts on unsaved
-- buffers, preserves window layout, drops the buffer cleanly.
vim.keymap.set('n', '<leader>vd', function() require('snacks').bufdelete() end, { desc = 'Delete current buffer (snacks: prompts on unsaved)' })

-- Window resize via Ctrl+Arrow. v:count1 lets `5<C-Right>` widen by 5.
vim.keymap.set('n', '<C-Left>',  '"<Cmd>vertical resize -" . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', '"<Cmd>vertical resize +" . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Increase window width' })
vim.keymap.set('n', '<C-Down>',  '"<Cmd>resize -"          . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Up>',    '"<Cmd>resize +"          . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Increase window height' })

-- <leader>K: man / :help / xdg-open dispatch on <cWORD>. Logic in utils/.
vim.keymap.set('n', '<leader>K', function()
   require('utils.smart_open').open()
end, { noremap = true, silent = true, desc = 'Man page or help for word under cursor' })

-- <C-g>: yank full path into the unnamed register """ and drop a quiet
-- INFO notify so noice routes it to the bottom-right mini view (see
-- core_plugins/noice.lua "notify -> mini" route). Plain `p` pastes the
-- path; "*"/"+" stay untouched. Push to clipboard explicitly with
-- :let @* = @"   (or paste from "" via `""p`).
vim.keymap.set('n', '<C-g>', function()
   local p = vim.fn.expand('%:p')
   if p == '' then
      vim.notify('[No Name]', vim.log.levels.INFO)
      return
   end
   vim.fn.setreg('"', p)
   vim.notify(p, vim.log.levels.INFO)
end, { desc = 'CTRL-G: full path -> noice (bot-right) + yank to ""' })

-- vim: ts=3 sts=3 sw=3 et
