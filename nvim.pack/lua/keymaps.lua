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

-- <leader>t* -- option toggles, scoped to current window when sensible.
-- Window-local (vim.wo) toggles only affect the active split; global ones
-- (vim.opt) affect every window.
vim.keymap.set('n', '<leader>tw', function()
   vim.wo.wrap = not vim.wo.wrap
   vim.notify('wrap = ' .. tostring(vim.wo.wrap), vim.log.levels.INFO)
end, { desc = '[T]oggle: [w]rap (current window)' })

vim.keymap.set('n', '<leader>th', function()
   vim.opt.hlsearch = not vim.opt.hlsearch:get()
   vim.notify('hlsearch = ' .. tostring(vim.opt.hlsearch:get()), vim.log.levels.INFO)
end, { desc = '[T]oggle: [h]lsearch (global)' })

vim.keymap.set('n', '<leader>tC', function()
   vim.wo.cursorline = not vim.wo.cursorline
   vim.notify('cursorline = ' .. tostring(vim.wo.cursorline), vim.log.levels.INFO)
end, { desc = '[T]oggle: [C]ursorline (current window)' })

-- <leader>tc cycles search case-sensitivity through the 3 useful states:
--   sensitive    /Foo  matches  Foo            ignorecase=off, smartcase=off
--   insensitive  /Foo  matches  Foo / foo / FOO ignorecase=on,  smartcase=off
--   smart        /foo  matches  Foo / foo / FOO ignorecase=on,  smartcase=on
--                /Foo  matches  Foo only       (uppercase => case-sensitive)
-- Default (set in options.lua) is "smart". Pressing <leader>tc walks
-- smart -> sensitive -> insensitive -> smart -> ...
vim.keymap.set('n', '<leader>tc', function()
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
end, { desc = '[T]oggle: [c]ase  sensitive -> insensitive -> smart' })

vim.keymap.set('n', '<leader>tr', function()
   vim.wo.relativenumber = not vim.wo.relativenumber
   vim.notify('relativenumber = ' .. tostring(vim.wo.relativenumber), vim.log.levels.INFO)
end, { desc = '[T]oggle: [r]elativenumber (current window)' })

vim.keymap.set('n', '<leader>tn', function()
   vim.wo.number = not vim.wo.number
   vim.notify('number = ' .. tostring(vim.wo.number), vim.log.levels.INFO)
end, { desc = '[T]oggle: line [n]umber (current window)' })

vim.keymap.set('n', '<leader>tl', function()
   vim.wo.list = not vim.wo.list
   vim.notify('list = ' .. tostring(vim.wo.list), vim.log.levels.INFO)
end, { desc = '[T]oggle: [l]ist chars (tabs/trailing/eol -- current window)' })

-- `tv` not `tc` (case=tc) and not `tC` (cursorline=tC). v = vertical bar.
vim.keymap.set('n', '<leader>tv', function()
   vim.wo.cursorcolumn = not vim.wo.cursorcolumn
   vim.notify('cursorcolumn = ' .. tostring(vim.wo.cursorcolumn), vim.log.levels.INFO)
end, { desc = '[T]oggle: cursorcolumn ([v]ertical bar -- current window)' })

-- Diagnostics toggle is buffer-local via vim.diagnostic.{is_enabled,enable}.
-- The 0.10+ API takes a boolean as the first arg; passing `not enabled`
-- flips the state. bufnr=0 means "current buffer".
vim.keymap.set('n', '<leader>td', function()
   local enabled = vim.diagnostic.is_enabled({ bufnr = 0 })
   vim.diagnostic.enable(not enabled, { bufnr = 0 })
   vim.notify('diagnostic = ' .. tostring(not enabled) .. ' (this buffer)', vim.log.levels.INFO)
end, { desc = '[T]oggle: [d]iagnostics (current buffer)' })

-- Window resize via Ctrl+Arrow. v:count1 lets `5<C-Right>` widen by 5.
vim.keymap.set('n', '<C-Left>',  '"<Cmd>vertical resize -" . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', '"<Cmd>vertical resize +" . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Increase window width' })
vim.keymap.set('n', '<C-Down>',  '"<Cmd>resize -"          . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Up>',    '"<Cmd>resize +"          . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Increase window height' })

-- <leader>K: man / :help / xdg-open dispatch on <cWORD>. Logic in utils/.
vim.keymap.set('n', '<leader>K', function()
   require('utils.smart_open').open()
end, { noremap = true, silent = true, desc = 'Man page or help for word under cursor' })

-- vim: ts=3 sts=3 sw=3 et
