Plug 'mallicksm/vim-lsp'
Plug 'mattn/vim-lsp-settings'

function! s:on_lsp_buffer_enabled()
   setlocal omnifunc=lsp#complete
endfunction

augroup lsp_install
   autocmd!
   autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled() 
augroup end 
let $init = '$RTP/lsp.vim'
