augroup TdfFiletype
	autocmd!
	autocmd BufRead,BufNewFile *.tdf set filetype=tdf
	autocmd BufRead,BufNewFile *.tdf set commentstring=//%s
augroup end
