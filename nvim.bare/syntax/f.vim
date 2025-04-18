" Vim syntax file
" Language: f
" Maintainer: Soummya Mallick
" Latest Revision: 2020-11-12
if exists("b:f_syntax")
  finish
endif

" Most commands covered
syntax match myComment    "//.*"
syntax match myComment    "#.*"
highlight default link myComment    Comment
" anything between {} is Tag
syntax match myVars       "{.*}"
highlight default link myVars    Tag
" Lets match lines starting with -f/-v
syntax match myFiles      "-f.*"
syntax match myFiles      "-v.*"
highlight default link myFiles   String
