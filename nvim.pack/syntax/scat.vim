" Vim syntax file
" Language: f
" Maintainer: Soummya Mallick
" Latest Revision: 2023-03-31
if exists("b:scat_syntax")
  finish
endif

" Most commands covered
syntax match scatComment    ";.*"
syntax match scatTag        "^#.*"
syntax match scatStatement  "^#!.*"
highlight default link scatComment    Comment
highlight default link scatStatement  Statement
highlight default link scatTag        Tag


