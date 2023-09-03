"===============================================================================
" Created: Sep-03-2023
" Author: mallick1
"
" Note:
"
" Description: Description
"
"===============================================================================

"-------------------------------------------------------------------------------
set encoding=utf-8 " vim-devicons
set path+=**
" Nice menu when typing `:find *.py`
set wildmode=longest,list,full
set wildmenu
" Ignore files
set wildignore+=**/.git/*
set wildignore+=*.pyc
set wildignore+=*.a
set wildignore+=*.o
set wildignore+=.svn*
set wildignore+=*.tmp

set splitbelow splitright
set exrc "source local vimrc
set guicursor= "keep insert cursor as block
set number 
if exists('+relativenumber') | set relativenumber | endif
set hidden
set noerrorbells
set tabstop=3 softtabstop=3 shiftwidth=3
set expandtab
set autoindent
set nowrap
set ignorecase smartcase
if v:version > 800
   set termguicolors
   set signcolumn=yes "no jumping
endif

" Undo stack settings
if !isdirectory($HOME . '/.vim/undodir')
   call mkdir($HOME . '/.vim/undodir', 'p')
endif
set noswapfile nobackup undofile
set mouse=a
if has('nvim')
   set undodir=~/.nvim/undodir
   " Preview effects of command incrementally (e.g. :substitute). Neovim only.
   set inccommand=nosplit
else
   set undodir=~/.vim/undodir
   set ttymouse=xterm2
endif

set cursorline cursorlineopt=both
set hlsearch incsearch nowrapscan
set scrolloff=0 sidescrolloff=8 sidescroll=1 "sane scrolling
set noshowmode
set completeopt=menuone,longest
set shortmess+=c
set cmdheight=2
if v:version > 800
   set list
   set listchars=tab:▸\ ,trail:·
endif
set timeoutlen=500 ttimeoutlen=100
set foldmethod=marker
set autoread
set clipboard=unnamed
set redrawtime=10000 " Allow more time for loading syntax on larger files
set exrc
set showmatch
set laststatus=2
set showcmd
set updatetime=50 " Faster sign updates on CursorHold/CursorHold (signify)
set bg=dark " for colormaps
set virtualedit=block
set diffopt+=vertical,iwhite,algorithm:histogram,indent-heuristic
"           +--Disable hlsearch while loading viminfo
"           | +--Remember marks for last 500 files
"           | |    +--Remember up to 10000 lines in each register
"           | |    |      +--Remember up to 1MB in each register
"           | |    |      |     +--Remember last 1000 search patterns
"           | |    |      |     |     +---Remember last 1000 commands
"           | |    |      |     |     |
"           v v    v      v     v     v
set viminfo=h,'500,<10000,s1000,/1000,:1000
let $sets = '$RTP/config/sets.vim'
