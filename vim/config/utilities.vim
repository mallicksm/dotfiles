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
" ['       -jump to next mark
" ------------------------------------------------------------------------------
"  https://github.com/mbbill/undotree
Plug 'mbbill/undotree'  " :Undo<TAB>
" ------------------------------------------------------------------------------
" https://github.com/azabiong/vim-highlighter
" f<cr>    -hi (toggle)
" f<C-L>   -hi clear
" jump key mappings
nn n  <Cmd>call HiSearch('n')<CR>
nn N  <Cmd>call HiSearch('N')<CR>
"
" https://github.com/chrisbra/colorizer
" :ColorToggle to show colors
" #c83964 red blue green yellow
if v:version > 800
   Plug 'azabiong/vim-highlighter'
   if !has('nvim')
      Plug 'chrisbra/colorizer'
   endif
" Following lets needed for termguicolors and Alacritty
   let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
   let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
" ------------------------------------------------------------------------------
" https://github.com/tmux-plugins/vim-tmux
" K brings up tmux manpage
" g!! executes current line 
Plug 'tmux-plugins/vim-tmux'
" ------------------------------------------------------------------------------
" https://github.com/glts/vim-radical
Plug 'glts/vim-magnum'
Plug 'glts/vim-radical'     " gA + [crd crx crb] 0x1000f3
let g:radical_bases = {16: {'format': '0x%08s'}}| " 0x0000007b
" ------------------------------------------------------------------------------
Plug 'vhda/verilog_systemverilog.vim'
" ------------------------------------------------------------------------------
" https://github.com/ojroques/vim-oscyank
Plug 'ojroques/vim-oscyank'
noremap <leader>c <Plug>OSCYankOperator
let $utilities = '$RTP/config/utilities.vim'
