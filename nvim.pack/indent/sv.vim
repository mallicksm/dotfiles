" ft=sv indent bridge (see after/ftdetect/filetype.lua).
"
" Treesitter has no SystemVerilog indents.scm, so reuse Neovim's built-in
" SystemVerilog indenter. Vim auto-loads indent/{ft}.vim by filetype name; the
" built-in file is indent/systemverilog.vim, which won't fire for ft=sv. Source
" it here -- it sets indentexpr=SystemVerilogIndent() and guards on b:did_indent
" (unset at this point, so it runs).
runtime! indent/systemverilog.vim

" Upstream SystemVerilogIndent() bug: on a `elsif/`else/`endif line it reads
" b:systemverilog_open_statement, which it never initializes -> E121. Our RTL is
" full of `ifdef, so seed it to avoid the crash (keeps ifdef indenting on).
let b:systemverilog_open_statement = 0
