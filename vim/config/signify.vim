"===============================================================================
" Created: Sep-03-2023
" Author: mallick1
"
" Note:
"
" Description: Description
"
"===============================================================================
if exists('g:SIGNIFY_LOADED')
  finish
end
let g:SIGNIFY_LOADED = 1

"-------------------------------------------------------------------------------
" https://github.com/mhinz/vim-signify
Plug 'mhinz/vim-signify'
let g:signify_sign_add               = '+'
let g:signify_sign_delete            = '-'
let g:signify_sign_delete_first_time = '_'
let g:signify_sign_change            = '~'
let g:signify_sign_show_count        = 1
let $signify = '$RTP/config/signify.vim'
