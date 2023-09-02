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
   nmap <buffer> gi <plug>(lsp-definition)
   nmap <buffer> gd <plug>(lsp-declaration)
   nmap <buffer> gr <plug>(lsp-references)
   nmap <buffer> gl <plug>(lsp-document-diagnostics)
   nmap <buffer> gg <plug>(lsp-rename)
   nmap <buffer> gh <plug>(lsp-hover)
augroup end 

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
let $lsp = '$RTP/config/lsp.vim'
