" Initial Essential
autocmd VimEnter * colorscheme gruvbox
" General Settings
" ==============================================================================
" nav
" \K for unix man
runtime! ftplugin/man.vim
" Reselect visual selection after indenting
vnoremap < <gv
vnoremap > >gv
nnoremap >> >>gv
nnoremap << <<gv

" moveit like vscode
vnoremap <S-j> :m '>+1<CR>gv=gv
vnoremap <S-k> :m '<-2<CR>gv=gv

" Convinience maps
nnoremap j gj
nnoremap k gk
nnoremap Q q
nnoremap q :q<CR>
nnoremap <leader>x :qall!<CR>
nnoremap <leader>R :call FullRefresh()<CR>
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'| " expand %% to files directory
nnoremap <silent> <leader>C :lcd %:p:h<CR>:pwd<CR>| " Change to the folder of the current file
nnoremap <CR> :noh<CR><CR>
inoremap <silent> <C-f> <C-X><C-F>
nnoremap <Leader><Leader> <C-^>

" whichkey maps
nnoremap <leader>vw :set wrap!<CR>
nnoremap <leader>vl :set list!<CR>| " Toggle list   
map <leader>v= gg=G<C-o><C-o>|      "format current file

" Windows
" ==============================================================================
nnoremap <silent> <leader>h :wincmd h<CR>
nnoremap <silent> <leader>j :wincmd j<CR>
nnoremap <silent> <leader>k :wincmd k<CR>
nnoremap <silent> <leader>l :wincmd l<CR>

" terminal navigation
tnoremap <leader>j <C-\><C-n><C-w>j
tnoremap <leader>k <C-\><C-n><C-w>k
tnoremap <leader>h <C-\><C-n><C-w>h
tnoremap <leader>l <C-\><C-n><C-w>l
tnoremap <Esc> <C-\><C-n>
tnoremap <leader><leader>h <C-\><C-n>:FloatermToggle<CR>

if has ('nvim')
   nnoremap <leader>ts  :new<CR>:terminal<CR>
   nnoremap <leader>tv  :vnew<CR>:terminal<CR>
else
   nnoremap <leader>ts  :term ++close<CR>
   nnoremap <leader>tv  :vert term ++close<CR>
endif

" Tabs {{{
" ==============================================================================
nnoremap <leader>tc :tabnew<CR>
nnoremap <leader>th :tabprev<CR>
nnoremap <leader>tl :tabnext<CR>
nnoremap <leader>tq :tabclose<CR>
nnoremap <leader>tx :tabclose!<CR>
nnoremap <leader>t1 :tabnext 1<CR>
nnoremap <leader>t2 :tabnext 2<CR>
nnoremap <leader>t3 :tabnext 3<CR>
nnoremap <leader>t4 :tabnext 4<CR>
nnoremap <leader>t5 :tabnext 5<CR>
nnoremap <leader>to :tabonly<CR>
" Opens a new tab with the current buffer's path
" " Super useful when editing files in the same directory
nnoremap <leader>te :tabedit <C-r>=expand("%:p:h")<cr>/
" }}}

" Buffers {{{
nnoremap <leader>bh :bprevious<CR>
nnoremap <leader>bl :bnext<CR>
nnoremap <leader>bq :bdelete<CR>
nnoremap <leader>bx :bdelete!<CR>
nnoremap <leader>b1 :buffer1<CR>
nnoremap <leader>b2 :buffer2<CR>
nnoremap <leader>b3 :buffer3<CR>
nnoremap <leader>b4 :buffer4<CR>
nnoremap <leader>b5 :buffer5<CR>
" }}}

" Convinience commands
" ==============================================================================
" Browse pdf
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

command! Filename execute ":echo expand('%:p')"
command! Reload   execute "source $RTP/init.vim"
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

nnoremap <leader><leader>h :call ConvertNumberBase(16)<CR>
nnoremap <leader><leader>b :call ConvertNumberBase(2)<CR>

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
   \ if line("'\"") > 0 && line("'\"") <= line("$") |
   \    exe "normal! g`\"zz" |
   \ endif

let $sensible = '$RTP/config/sensible.vim'
