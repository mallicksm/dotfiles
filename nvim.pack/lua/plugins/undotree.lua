-- undotree -- mbbill/undotree visualization. Persistent undo dir under ~/.undodir.
local undodir = vim.fn.expand('$HOME') .. '/.undodir'
if not vim.uv.fs_stat(undodir) then
   vim.fn.mkdir(undodir, 'p')
end
vim.g.undotree_SplitWidth   = 50
vim.g.undotree_WindowLayout = 2
vim.opt.undodir             = undodir

vim.keymap.set('n', '<leader>ou', function()
   vim.notify('Create ~/undotree_debug.log to debug', vim.log.levels.INFO)
   vim.cmd.UndotreeToggle()
end, { desc = 'Undotree: toggle' })

-- vim: ts=3 sts=3 sw=3 et
