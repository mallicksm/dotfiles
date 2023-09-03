"===============================================================================
" Created: Sep-03-2023
" Author: mallick1
"
" Note:
"
" Description: Description
"
"===============================================================================
if exists('g:INDENTLINE_LOADED')
  finish
end
let g:INDENTLINE_LOADED = 1

"-------------------------------------------------------------------------------
" https://github.com/Yggdroot/indentLine
Plug 'Yggdroot/indentLine'
let g:indentLine_char = '|'
let g:indentLine_bufNameExclude = ['_.*', 'NERD_tree.*', '.*\.pdf']
let $indentline = '$RTP/config/indentline.vim'
