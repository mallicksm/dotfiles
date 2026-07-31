-- ft=sv (see after/ftdetect/filetype.lua). Use Treesitter folds for
-- SystemVerilog: the TS parser has good structural nodes (modules, instances,
-- classes, begin/end blocks) and matches the mini.ai textobjects. Runs in
-- after/ so it wins over any foldmethod the built-in ftplugin might set.
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt_local.foldlevelstart = 99
