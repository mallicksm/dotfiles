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
" https://github.com/voldikss/vim-floaterm
if v:version > 800
   Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': { -> fzf#install() } }
   Plug 'junegunn/fzf.vim'
endif
" ------------------------------------------------------------------------------
" https://github.com/junegunn/vim-peekaboo
Plug 'junegunn/vim-peekaboo'
let g:peekaboo_window = "vertical bot 40new"
let g:peekaboo_delay = 100
let g:peekaboo_compact = 0
" ------------------------------------------------------------------------------
Plug 'junegunn/gv.vim'

"Auto-clean fugitive buffers
autocmd BufReadPost fugitive://* set bufhidden=delete 
" Files with preview
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}), <bang>0)
let g:fzf_preview_window = ['up,65%', 'ctrl-/']
let $junegunn = '$RTP/config/junegunn.vim'
