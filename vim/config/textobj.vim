"===============================================================================
" Created: Sep-03-2023
" Author: mallick1
"
" Note:
"
" Description: Description
"
"===============================================================================

"-------------------------------------------------------------------------------
"Supported textobjects
"                i  Indent
"                c  Comment
"                l  Current Line
"                e  Entire file
"                z  Fold
"                q  Column
"                F  'C' Function
"-------------------------------------------------------------------------------
" https://github.com/wellle/targets.vim
Plug 'wellle/targets.vim'
"-------------------------------------------------------------------------------
" https://github.com/kana/vim-textobj-user
" https://github.com/thinca/vim-textobj-between
Plug 'kana/vim-textobj-user'
Plug 'thinca/vim-textobj-between'
" in between {char}
" {lhs}   {rhs}
" -----   ----------------------
" af      <Plug>(textobj-between-a)
" if      <Plug>(textobj-between-i)
"-------------------------------------------------------------------------------
" https://github.com/Julian/vim-textobj-brace'
Plug 'kana/vim-textobj-indent'
" {lhs}   {rhs}
" -----   ----------------------
" ai      <Plug>(textobj-indent-a)
" ii      <Plug>(textobj-indent-i)
" aI      <Plug>(textobj-indent-same-a)
" iI      <Plug>(textobj-indent-same-i)
"-------------------------------------------------------------------------------
" https://github.com/glts/vim-textobj-comment'
Plug 'glts/vim-textobj-comment'
" ac   <Plug>(textobj-comment-a)
" ic   <Plug>(textobj-comment-i)
" aC   <Plug>(textobj-comment-big-a)
"-------------------------------------------------------------------------------
" https://github.com/kana/vim-textobj-line'
Plug 'kana/vim-textobj-line'
" {lhs}  {rhs}
" -----  ----------------------
" al     <Plug>(textobj-line-a)
" il     <Plug>(textobj-line-i)
"-------------------------------------------------------------------------------
" https://github.com/kana/vim-textobj-entire'
Plug 'kana/vim-textobj-entire'
" {lhs}  {rhs}
" -----  ----------------------
" ae     <Plug>(textobj-entire-a)
" ie     <Plug>(textobj-entire-i)
"-------------------------------------------------------------------------------
" https://github.com/kana/vim-textobj-fold'
Plug 'kana/vim-textobj-fold'
" {lhs}  {rhs}
" -----  ----------------------
" az     <Plug>(textobj-fold-a)
" iz     <Plug>(textobj-fold-i)
"-------------------------------------------------------------------------------
" https://github.com/idbrii/textobj-word-column.vim
Plug 'idbrii/textobj-word-column.vim'
let g:textobj_wordcolumn_no_default_key_mappings = 1
autocmd VimEnter * call textobj#user#map('wordcolumn', {
            \ 'word' : {
            \   'select-i' : 'iq',
            \   'select-a' : 'aq',
            \   },
            \ 'WORD' : {
            \   'select-i' : 'iQ',
            \   'select-a' : 'aQ',
            \   },
            \ })
"-------------------------------------------------------------------------------
" https://github.com/kana/vim-textobj-function
Plug 'kana/vim-textobj-function'
" {lhs}   {rhs}
" -----   -----
"  af     <Plug>(textobj-function-A)
"  if     <Plug>(textobj-function-I)
"-------------------------------------------------------------------------------
let g:textobj_function_no_default_key_mappings=0
omap if <Plug>(textobj-function-i)
omap af <Plug>(textobj-function-a)

let $textobj = '$RTP/config/textobj.vim'
