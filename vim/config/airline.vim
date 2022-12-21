" https://github.com/vim-airline/vim-airline/blob/master/doc/airline.txt
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
let g:airline_powerline_fonts = 1
let g:airline_theme='molokai' " base16,gruvbox ..
" +---------------------------------------------------------------+
" |~                VIM - Vi IMproved                             |
" |~                  version 8.2                                 |
" +---------------------------------------------------------------+
" | A | B |                C                 | X | Y | Z |  [...] |
" +---------------------------------------------------------------+
let g:airline_section_b = ''
let g:airline_section_c = '%<%F%m %#__accent_red#%{airline#util#wrap(airline#parts#readonly(),0)}%#__restore__#' " used to use %{getcwd()}/%t
let g:airline_section_y = ''
let g:airline_section_error = ''
let g:airline_section_warning = ''
let g:webdevicons_enable_airline_statusline_fileformat_symbols = 0
"TABLINE:
let g:airline#extensions#tabline#enabled = 1           " enable airline tabline
let g:airline#extensions#tabline#show_buffers = 0      " dont show buffers in the tabline
let g:airline#extensions#tabline#fnamemod = ':t'       " disable file paths in the tab
let g:airline#extensions#tabline#show_tab_nr = 0       " disable tab numbers
let g:airline#extensions#tabline#show_close_button = 0 " remove 'X' at the end of the tabline
let g:airline#extensions#tabline#show_tab_count = 0    " dont show tab numbers on the right
let g:airline#extensions#tabline#tab_min_count = 2     " minimum of 2 tabs needed to display the tabline
let g:airline#extensions#tabline#show_splits = 0       " disables the buffer name that displays on the right of the tabline

let $airline = '$RTP/config/airline.vim'
