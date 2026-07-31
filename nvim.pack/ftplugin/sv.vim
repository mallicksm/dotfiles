" ft=sv ftplugin bridge (see after/ftdetect/filetype.lua).
"
" Reuse Neovim's built-in SystemVerilog ftplugin, which sources ftplugin/
" verilog.vim (commentstring '// %s', comments, include=) and adds the full SV
" matchit b:match_words (begin/end, module, class, interface, program,
" covergroup, property, sequence, clocking, checker, fork/join*). Vim auto-loads
" ftplugin/{ft}.vim by filetype name; the built-in file is systemverilog.vim,
" which won't fire for ft=sv, so source it here. It guards on b:did_ftplugin.
runtime! ftplugin/systemverilog.vim
