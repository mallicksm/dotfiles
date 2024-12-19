return {
   "mbbill/undotree",
   config = function()
      vim.keymap.set("n", "\\u", function()
            print "Create ~/undotree_debug.log to debug"
            vim.cmd.UndotreeToggle()
         end,
         { desc = "Toggle 'Undotree'" })
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
