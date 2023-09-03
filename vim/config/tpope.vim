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
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-repeat'        " .
" ------------------------------------------------------------------------------
"  https://github.com/tpope/vim-fugitive/blob/master/doc/fugitive.txt
Plug 'tpope/vim-fugitive'      " :G
" ------------------------------------------------------------------------------
"  https://github.com/tpope/vim-commentary/blob/master/doc/commentary.txt
Plug 'tpope/vim-commentary'    " gc
" ------------------------------------------------------------------------------
" https://github.com/tpope/vim-surround/blob/master/doc/surround.txt
Plug 'tpope/vim-surround'
" Surround your text
" # NORMAL
"    ds     - delete surround
"    cs     - change surround
"    ys*    - you surround                    * textobj
"    yss    - line, you surround
"    yS*    - you surround -your own line-    * textobj
"    ySS    - line, you surround -your own line-
"    ys*f   - you surround function           * textobj
" # VISUAL
"    S      - Add surround
" ------------------------------------------------------------------------------
let $tpope = '$RTP/config/tpope.vim'
