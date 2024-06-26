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
" Ripgrep
command! -bang -nargs=* Rgg
   \ call fzf#vim#grep(
   \ "rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
   \ {'options': '--delimiter : --nth 4..'},
   \ <bang>0)
" Files with preview
command! -bang -nargs=? -complete=dir Files
   \ call fzf#vim#files(
   \ <q-args>, 
   \ fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}), <bang>0)

let g:fzf_layout = {'window': {'width': 0.9, 'height': 0.9}}
let g:fzf_preview_window = ['left,50%', '?']

let $junegunn = '$RTP/config/junegunn.vim'
