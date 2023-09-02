" Install vim-plug if not found
set runtimepath+=~/.nvim
if empty(glob('~/.nvim/autoload/plug.vim'))
   silent execute '!curl -fLo ~/.nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
   \| PlugInstall --sync | source $MYVIMRC
   \| endif

let $RTP = expand("$RTP_NVIM_DOTFILE")

call plug#begin('~/.nvim/plugged')
source $RTP/config/functions.vim
source $RTP/config/whichkey.vim    " Central menu control
source $RTP/config/tpope.vim
source $RTP/config/junegunn.vim    " telescope_fzf + :GV[,!,?]
source $RTP/config/floaterm.vim
source $RTP/config/airline.vim
source $RTP/config/nerdtree.vim
source $RTP/config/easymotion.vim
source $RTP/config/signify.vim     " signcolumn git signs and ,d for vdiff
source $RTP/config/indentline.vim  " | for indents
source $RTP/config/utilities.vim   " autopairs, marks, UndoTreeShow, f<CR>=highlight, ColorToggle, RainbowToggle, K=man
source $RTP/config/vimsnip.vim
source $RTP/config/textobj.vim
source $RTP/config/clang-format.vim
if has('mac')
source $RTP/config/lsp.vim
endif
source $RTP/config/telescope.vim
call plug#end()

let &runtimepath .=','.expand("$RTP")

let mapleader = "\<space>"
let maplocalleader = ","
source $RTP/config/sets.vim
source $RTP/config/sensible.vim
let $init = '$RTP/init.vim'
