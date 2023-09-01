let g:Pdf2Txt = 'pdftotext -nopgbrk -layout -q -eol unix %:p:S -'
augroup Pdf2Txt
   autocmd!
   autocmd BufReadCmd *.pdf execute expand('silent read ++edit !' . g:Pdf2Txt)
   autocmd BufReadCmd *.pdf 1delete_
   autocmd BufReadCmd *.pdf setfiletype text
   autocmd BufReadCmd *.pdf setlocal buftype=nowrite
augroup end

" Nuke registers
function! NukeRegs()
   let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
   for r in regs
      call setreg(r, [])
   endfor
endf

function! ConvertNumberBase(base)
    let line = getline('.')
    let col = col('.')
    let word = expand('<cword>')

    if a:base == 16
        if word =~? '^0x[0-9a-fA-F]\+$'
            " Convert hex to decimal
            let hex_number = word[2:]
            let dec_number = str2nr(hex_number, 16)
            let new_number = printf('%d', dec_number)
        else
            " Convert decimal to hex
            let dec_number = str2nr(word)
            let hex_number = printf('0x%x', dec_number)
            let new_number = hex_number
        endif
    elseif a:base == 2
        if word =~? '^0b[01]\+$'
            " Convert binary to decimal
            let bin_number = word[2:]
            let dec_number = 0
            let binary_digits = split(bin_number, '\zs')
            for digit in binary_digits
                let dec_number = dec_number * 2 + str2nr(digit)
            endfor
            let new_number = printf('%d', dec_number)
        else
            " Convert decimal to binary
            let dec_number = str2nr(word)
            let bin_number = ''
            while dec_number > 0
                let bin_number = printf('%s', dec_number % 2) . bin_number
                let dec_number = dec_number / 2
            endwhile
            let new_number = "0b" . bin_number
        endif
    else
        echo "Invalid base. Use 16 for hex or 2 for binary."
        return
    endif

    let line = substitute(line, '\%' . col . 'c\k\+', new_number, '')
    call setline('.', line)
    call cursor('.', col)
endfunction

function! NERDTreeYankFullPath()
   let n = g:NERDTreeFileNode.GetSelected()
   if n != {}
      call setreg('"', n.path.str())
   endif
   call nerdtree#echo("Node full path yanked!")
endfunction

function! FullRefresh()
   :e!
   :NERDTreeRefreshRoot
   :NERDTreeFind
   call webdevicons#refresh()
endfunction

function! CdToFile()
   :lcd %:p:h
   :pwd
endfunction

command! Filename execute ":echo expand('%:p')"
command! Reload   execute "source $RTP/init.vim"

let $functions = '$RTP/config/functions.vim'
