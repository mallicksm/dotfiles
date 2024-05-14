return {
   'vhda/verilog_systemverilog.vim',
   config = function()
      vim.g.verilog_syntax_fold_lst = "all"
      vim.keymap.set("n", "<leader>z", function()
            print "setting foldmethod=syntax"
            vim.o.foldmethod = 'syntax'
         end,
         { desc = "vlog: foldmethod=syntax" })
   end,
}
