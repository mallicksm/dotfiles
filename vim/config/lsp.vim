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
Plug 'mallicksm/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

function! s:on_lsp_buffer_enabled()
   setlocal omnifunc=lsp#complete
endfunction

augroup lsp_install
   autocmd!
   autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled() 
   nmap <buffer> <leader>gi <plug>(lsp-definition)
   nmap <buffer> <leader>gd <plug>(lsp-declaration)
   nmap <buffer> <leader>gr <plug>(lsp-references)
   nmap <buffer> <leader>gl <plug>(lsp-document-diagnostics)
   nmap <buffer> <leader>gg <plug>(lsp-rename)
   nmap <buffer> <leader>gh <plug>(lsp-hover)
augroup end 

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
let $lsp = '$RTP/config/lsp.vim'
