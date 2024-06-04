local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
   vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      lazypath,
   })
end
vim.opt.runtimepath:prepend(lazypath)
require('lazy').setup({
   { import = 'plugins' },
   { import = 'core_plugins' },
   { import = 'code_plugins' }
})
-- vim: ts=3 sts=3 sw=3 et
