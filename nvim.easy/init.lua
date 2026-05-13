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
-- maplocalleader intentionally NOT set: defaults to '\' which is fine since
-- we have zero <localleader> bindings. Reserving , as an active prefix
-- conflicts with treesitter-textobjects' `,` = repeat-last-move-opposite
-- (planned adoption). Restore here if/when ft-local bindings get added.

require('options')
require('autocmds')
require('user_commands')
require('bootstrap')
require('keymaps')
-- vim: ts=3 sts=3 sw=3 et
