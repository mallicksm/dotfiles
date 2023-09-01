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
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'| " expand %% to files directory
nnoremap <CR> :noh<CR><CR>
inoremap <silent> <C-f> <C-X><C-F>

" ==============================================================================
" terminal navigation
tnoremap <leader>j <C-\><C-n><C-w>j
tnoremap <leader>k <C-\><C-n><C-w>k
tnoremap <leader>h <C-\><C-n><C-w>h
tnoremap <leader>l <C-\><C-n><C-w>l
tnoremap <Esc> <C-\><C-n>
tnoremap <leader><leader>h <C-\><C-n>:FloatermToggle<CR>

if has ('nvim')
   nnoremap <leader>Ts  :new<CR>:terminal<CR>
   nnoremap <leader>Tv  :vnew<CR>:terminal<CR>
else
   nnoremap <leader>Ts  :term ++close     <CR>
   nnoremap <leader>Tv  :vert term ++close<CR>
endif

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
   \ if line("'\"") > 0 && line("'\"") <= line("$") |
   \    exe "normal! g`\"zz" |
   \ endif

let $sensible = '$RTP/config/sensible.vim'
