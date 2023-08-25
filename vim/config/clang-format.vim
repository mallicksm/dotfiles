" ------------------------------------------------------------------------------
"  https://github.com/rhysd/vim-clang-format
" https://github.com/kana/vim-operator-user
Plug 'kana/vim-operator-user'
Plug 'rhysd/vim-clang-format'
let g:clang_format#code_style = "Google"
let g:clang_format#style_options = {
         \ "UseTab" : "Never",
         \ "IndentWidth" : 3,
         \ "SortIncludes" : "false",
         \ "AlignConsecutiveBitFields" : "true", 
         \ "AlignConsecutiveMacros" : "true", 
         \ "AlwaysBreakAfterReturnType" : "None", 
         \ "ColumnLimit" : 0 }
let g:clang_format#auto_format = 1
let g:clang_format#auto_format_on_insert_leave = 1

