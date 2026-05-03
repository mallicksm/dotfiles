-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true

-- You can also add relative line numbers, for help with jumping.
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
-- vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }
   -- vim.opt.clipboard = 'unnamedplus'
   vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
-- `extends` / `precedes` only render when wrap=false, so they're invisible noise
-- on wrap=true buffers and helpful breadcrumbs (line continues left/right) on
-- nowrap buffers (e.g. markdown via after/ftplugin/markdown.lua).
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', extends = '›', precedes = '‹' }

-- Side-scroll one column at a time and keep 5 columns of context around the
-- cursor. No effect when wrap=true; quality-of-life when wrap=false.
vim.opt.sidescroll = 1
vim.opt.sidescrolloff = 5

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
-- vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 0

vim.opt.hlsearch = true
-- vim: ts=3 sts=3 sw=3 et
