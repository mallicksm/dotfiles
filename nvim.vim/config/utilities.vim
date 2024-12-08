"===============================================================================
" Created: Sep-03-2023
" Author: mallick1
"
" Note:
"
" Description: Description
"
"===============================================================================

" ------------------------------------------------------------------------------
" https://github.com/jiangmiao/auto-pairs
" System Shortcuts:
Plug 'jiangmiao/auto-pairs'
let g:AutoPairsShortcutToggle     = "<Leader><Down>"  | " <M-p> Toggle Autopairs (I)
let g:AutoPairsShortcutFastWrap   = "<Right>"         | " <M-e> Fast Wrap (I)
let g:AutoPairsShortcutJump       = "<Leader><Right>" | " <M-n> Jump to next closed pair (N+I)
let g:AutoPairsShortcutBackInsert = "<Up>"            | " <M-b> BackInsert (I)
let g:AutoPairsFlyMode = 1
" ------------------------------------------------------------------------------
" https://github.com/kshenoy/vim-signature
Plug 'kshenoy/vim-signature'
" ma       -toggle mark a
" m<Space> -delete all marks
" ------------------------------------------------------------------------------
"  https://github.com/mbbill/undotree
Plug 'mbbill/undotree'  " :Undo<TAB>
" ------------------------------------------------------------------------------
" https://github.com/azabiong/vim-highlighter
" f<cr>    -hi (toggle)
" f<C-L>   -hi clear
" jump key mappings
nnoremap n  :<c-u>call HiSearch('n')<CR>
nnoremap N  :<c-u>call HiSearch('N')<CR>
"
" :ColorToggle to show colors
" #c83964 red blue green yellow
if v:version > 800
   " https://github.com/azabiong/vim-highlighter
   Plug 'azabiong/vim-highlighter'
   if !has('nvim')
      " https://github.com/chrisbra/colorizer
      Plug 'chrisbra/colorizer'
      " Following lets needed for termguicolors and Alacritty
      let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
      let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
   endif
endif
" ------------------------------------------------------------------------------
" https://github.com/tmux-plugins/vim-tmux
" K brings up tmux manpage
" g!! executes current line 
Plug 'tmux-plugins/vim-tmux'
" ------------------------------------------------------------------------------
Plug 'vhda/verilog_systemverilog.vim'
" ------------------------------------------------------------------------------
" https://github.com/ojroques/vim-oscyank
Plug 'ojroques/vim-oscyank'
" ------------------------------------------------------------------------------
" https://github.com/amix/open_file_under_cursor.vim
Plug 'amix/open_file_under_cursor.vim'
" ------------------------------------------------------------------------------
" https://github.com/rhysd/accelerated-jk
Plug 'rhysd/accelerated-jk'
let g:accelerated_jk_enable_deceleration = 1
nmap j <plug>(accelerated_jk_gj)
nmap j <plug>(accelerated_jk_gk)
" ------------------------------------------------------------------------------
" https://github.com/rhysd/git-messenger.vim
Plug 'rhysd/git-messenger.vim'
nmap <localLeader>m <Plug>(git-messenger)
let $utilities = '$RTP/config/utilities.vim'
