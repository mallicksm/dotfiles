" https://github.com/voldikss/vim-floaterm
if v:version > 800
   Plug 'voldikss/vim-floaterm'
endif
" floaterm
let g:floaterm_keymap_toggle = '<leader>Tf'
let g:floaterm_wintype = 'float'
let g:floaterm_width = 0.8
let g:floaterm_height = 0.6
let g:floaterm_position = 'topleft'
let g:floaterm_autoclose = 2
let $floaterm = '$RTP/config/floaterm.vim'
