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
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath("data") .. "/easy-lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
   vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
   })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
   { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
   {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
      dependencies = { 'nvim-lua/plenary.nvim' }
   }
}
local opts = {}
require("lazy").setup(plugins, opts)
require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"
