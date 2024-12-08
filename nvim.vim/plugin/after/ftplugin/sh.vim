" Define a custom function to check if the line contains the start of a function
function! Folding()
   filetype plugin indent on
   let g:sh_fold_enabled=5
   let g:is_bash=1
   set foldmethod=syntax
   set foldnestmax=1
   syntax enable
endfunction

augroup ShSettings
   autocmd!
   autocmd VimEnter *.sh call Folding()
augroup end
