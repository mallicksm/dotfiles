" https://github.com/Yggdroot/indentLine
Plug 'Yggdroot/indentLine'
let g:indentLine_char = '|'
let g:indentLine_bufNameExclude = ['_.*', 'NERD_tree.*', '.*\.pdf']
nnoremap <leader>vi :IndentLinesToggle<CR>
let $indentline = '$RTP/config/indentline.vim'
