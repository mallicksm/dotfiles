-- Use Treesitter folds for SystemVerilog. The vhda syntax plugin defaults to
-- syntax folds, but our TS parser has better structural nodes (modules,
-- instances, classes, begin/end blocks) and matches the mini.ai textobjects.
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt_local.foldlevelstart = 99
