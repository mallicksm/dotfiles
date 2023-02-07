let $HOME = expand("$HOME")
augroup Global
   autocmd!
   autocmd VimEnter,bufenter * silent! :ColorHighlight
   autocmd VimEnter,bufenter *.py silent! setlocal tabstop=4 softtabstop=4 shiftwidth=4
   autocmd VimEnter,bufenter *.json silent! setlocal conceallevel=0
augroup END
