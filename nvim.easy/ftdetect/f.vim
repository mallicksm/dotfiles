augroup FFiletype
	autocmd!
	autocmd BufRead,BufNewFile *.f set filetype=f
	autocmd BufRead,BufNewFile *.f set commentstring=//%s
augroup end
