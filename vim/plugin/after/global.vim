let $HOME = expand("$HOME")
augroup Global
   autocmd!
   autocmd VimEnter,bufenter * silent! :ColorHighlight
   autocmd VimEnter,bufenter *.py silent! setlocal softtabstop=3
   autocmd VimEnter,bufenter *.json silent! setlocal conceallevel=0
augroup END
