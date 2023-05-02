"Textobj articles
   "https://ctoomey.com/
   "https://blog.carbonfive.com/vim-text-objects-the-definitive-guide/
   "https://benmccormick.org/2014/07/02/learning-vim-in-2014-vim-as-language
"Usefull plugins
   "https://github.com/vim-scripts/ReplaceWithRegister
   "https://github.com/christoomey/vim-system-copy
"Additional textobjects
   "Plug 'beloglazov/vim-textobj-quotes'
   "Plug 'kana/vim-textobj-indent'
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
"  aF     <Plug>(textobj-function-A)
"  iF     <Plug>(textobj-function-I)
"-------------------------------------------------------------------------------
let $textobj = '$RTP/config/textobj.vim'
