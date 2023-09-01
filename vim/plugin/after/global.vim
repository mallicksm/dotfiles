let $HOME = expand("$HOME")
augroup Global
   autocmd!
   autocmd VimEnter,bufenter * silent! :ColorHighlight
   autocmd VimEnter,bufenter *.json silent! setlocal conceallevel=0
augroup end
