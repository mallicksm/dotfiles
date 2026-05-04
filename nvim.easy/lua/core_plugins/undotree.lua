return {
   'mbbill/undotree',
   cmd = { 'UndotreeToggle', 'UndotreeShow', 'UndotreeHide', 'UndotreeFocus' },
   keys = {
      {
         '<leader>ou',
         function()
            vim.notify('Create ~/undotree_debug.log to debug', vim.log.levels.INFO)
            vim.cmd.UndotreeToggle()
         end,
         desc = 'Undotree: toggle',
      },
   },
   config = function()
      local undodir = vim.fn.expand("$HOME") .. "/.undodir"
      if not (vim.uv or vim.loop).fs_stat(undodir) then
         vim.fn.mkdir(undodir, "p")
      end
      vim.g.undotree_SplitWidth = 50
      vim.g.undotree_WindowLayout = 2
      vim.opt.undodir = undodir
   end,
}
-- vim: ts=3 sts=3 sw=3 et
