"===============================================================================
" Created: Sep-03-2023
" Author: mallick1
"
" Note:
"
" Description: Description
"
"===============================================================================

" ------------------------------------------------------------------------------
" https://github.com/rhysd/vim-clang-format
" https://github.com/kana/vim-operator-user
Plug 'kana/vim-operator-user'
Plug 'rhysd/vim-clang-format'
let g:clang_format#code_style = "Google"
let g:clang_format#style_options = {
         \ "UseTab" : "Never",
         \ "IndentWidth" : 3,
         \ "SortIncludes" : "false",
         \ "AlignConsecutiveBitFields" : "true", 
         \ "AlignConsecutiveMacros" : "false", 
         \ "AlwaysBreakAfterReturnType" : "None", 
         \ "ConstructorInitializerIndentWidth" : 3, 
         \ "ContinuationIndentWidth" : 3, 
         \ "BreakConstructorInitializers" : "BeforeComma", 
         \ "ColumnLimit" : 0 }
let g:clang_format#auto_format = 1
let g:clang_format#auto_format_on_insert_leave = 1
let $clangFormat = '$RTP/config/clang-format.vim'

