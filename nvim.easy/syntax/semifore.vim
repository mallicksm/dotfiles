" Semifore CSR Compiler DSL Syntax Highlighting
" Save as ~/.vim/syntax/semifore.vim

if exists("b:current_syntax")
  finish
endif

syntax keyword semiforeKeyword addressmap register field property block default enum instance

" Highlight type specifiers and ranges
syntax match semiforeRange "\[[0-9]\+:[0-9]\+\]"
syntax match semiforeRange "\[[0-9]\+\]"

" Highlight quoted strings
syntax region semiforeString start=+"+ skip=+\\\\\|\\"+ end=+"+

" Highlight properties and assignment
syntax match semiforeAssignment "=\s*[^;]*;"
syntax match semiforeSemicolon ";"

" Highlight comments
syntax match semiforeComment "//.*$"
syntax region semiforeComment start="/\*" end="\*/"

" Define highlighting groups
highlight link semiforeKeyword Keyword
highlight link semiforeRange Number
highlight link semiforeString String
highlight link semiforeAssignment Statement
highlight link semiforeSemicolon Delimiter
highlight link semiforeComment Comment

let b:current_syntax = "semifore"
