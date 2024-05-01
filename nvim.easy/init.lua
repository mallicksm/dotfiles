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

require('options')
require('keymaps')
require('autocmds')
require('bootstrap')
-- vim: ts=3 sts=3 sw=3 et
