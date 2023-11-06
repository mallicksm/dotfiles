augroup MakeSettings
   autocmd!
autocmd BufRead Makefile setlocal noexpandtab
autocmd BufRead makefile setlocal noexpandtab
autocmd BufRead *.mk setlocal noexpandtab
augroup end
