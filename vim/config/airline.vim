"===============================================================================
" Created: Sep-03-2023
" Author: mallick1
"
" Note:
"
" Description: Description
"
"===============================================================================
if exists('g:AIRLINE_LOADED')
  finish
end
let g:AIRLINE_LOADED = 1

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
let g:airline_skip_empty_sections = 1
let $airline = '$RTP/config/airline.vim'
