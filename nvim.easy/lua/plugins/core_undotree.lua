return {
   "mbbill/undotree",
   config = function()
      vim.keymap.set("n", "<leader>u", function()
            print "Create ~/undotree_debug.log to debug"
            vim.cmd.UndotreeToggle()
         end,
         { desc = "Undotree toggle" })
      local undodir = vim.fn.expand('~/.undodir')
      if not (vim.uv or vim.loop).fs_stat(undodir) then
         vim.fn.mkdir(undodir, "p")
      end
      vim.g.undotree_SplitWidth = 50
      vim.g.undotree_WindowLayout = 2
      vim.opt.undodir = undodir
   end,
}
