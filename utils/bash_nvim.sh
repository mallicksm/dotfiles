unalias vi 2>/dev/null
function vi () {
   XDG_CONFIG_HOME=~/dotfiles/ NVIM_APPNAME=nvim.easy nvim -p "$@" 
}
function vimdiff () {
   XDG_CONFIG_HOME=~/dotfiles/ NVIM_APPNAME=nvim.easy nvim -d "$@" 
}
function lvim () {
   XDG_CONFIG_HOME=~/dotfiles/ NVIM_APPNAME=nvim.lua nvim -p "$@"
}
function svim () {
   XDG_CONFIG_HOME=~/dotfiles/ NVIM_APPNAME=nvim nvim -p "$@"
}
