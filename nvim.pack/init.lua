--[[
   ╭──────────────────────────────────────────────────────────────╮
   │ nvim.pack -- the same config as nvim.easy, but powered by    │
   │ Neovim's built-in `vim.pack` package manager (0.12+) instead │
   │ of lazy.nvim. Modern, minimal, no external bootstrap.        │
   │                                                              │
   │ Activate with:                                               │
   │   XDG_CONFIG_HOME=~/dotfiles NVIM_APPNAME=nvim.pack nvim     │
   │                                                              │
   │ Layout:                                                      │
   │   init.lua                this file -- entry point           │
   │   lua/options.lua         vim.opt.* (verbatim from nvim.easy)│
   │   lua/autocmds.lua        real autocmds                      │
   │   lua/user_commands.lua   :Filename / :Utilities / :MdViewer │
   │   lua/plugins.lua         vim.pack.add() of every repo       │
   │   lua/plugins/<name>.lua  per-plugin setup (one file each)   │
   │   lua/keymaps.lua         basic, plugin-agnostic keymaps     │
   │   lua/{utils,markdown,user_plugins}/  unchanged from .easy   │
   │   after/, syntax/         unchanged from .easy               │
   ╰──────────────────────────────────────────────────────────────╯
--]]

-- Leader keys MUST be set before any plugin spec or keymap binds them.
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Order matters:
--   1. options       -- vim.opt.* before plugins read them
--   2. autocmds      -- real autocmds (PDF reader, last-loc restore)
--   3. user_commands -- :Filename, :Utilities, :MdViewer, :FormatAllSV
--   4. plugins       -- vim.pack.add(...) + per-plugin setup files
--   5. keymaps       -- basic plugin-agnostic keymaps
require('options')
require('autocmds')
require('user_commands')
require('plugins')
require('keymaps')

-- vim: ts=3 sts=3 sw=3 et
