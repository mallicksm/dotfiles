" Loaded after vhda/verilog_systemverilog.vim/indent/verilog_systemverilog.vim,
" which does `setlocal indentkeys+=;`. Re-indent on ';' often returns 0 for
" finished statements like `assign a = b;` and snaps the line to column 1.
if exists('b:did_after_indent')
  finish
endif
let b:did_after_indent = 1

setlocal indentkeys-=;
