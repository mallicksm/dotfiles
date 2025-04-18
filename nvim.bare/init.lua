--[[
   ╭──────────────────────────────────────────────────────────────╮
   │ Soummya Mallick:                                             │
   │                                                              │
   │                                         .-----.              │
   │              .----------------------.   | === |              │
   │              |.-""""""""""""""""""-.|   |-----|              │
   │              ||                    ||   | === |              │
   │              ||                    ||   |-----|              │
   │              ||    LSP NVIM IDE    ||   | === |              │
   │              ||                    ||   |-----|              │
   │              ||                    ||   |:::::|              │
   │              |'-..................-'|   |____o|              │
   │              `"")----------------(""`   ___________          │
   │             /::::::::::|  |::::::::::\  \ no mouse \         │
   │            /:::========|  |==hjkl==:::\  \ required \        │
   │           '""""""""""""'  '""""""""""""'  '""""""""""'       │
   │                                                              │
   │                                                              │
   ╰──────────────────────────────────────────────────────────────╯
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

_G.lua_snippet_dir = "~/dotfiles/snippets/lua_snippets/"
_G.vscode_snippet_dir = "~/dotfiles/snippets/vscode_snippets/"
require('options')
require('autocmds')
require('bootstrap')
require('keymaps')
-- vim: ts=3 sts=3 sw=3 et
