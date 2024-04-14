function vi () {
   _XDG_CONFIG_HOME=$XDG_CONFIG_HOME
   _NVIM_APPNAME=$NVIM_APPNAME
   export XDG_CONFIG_HOME=~/dotfiles/
   export NVIM_APPNAME=nvim.lua
   nvim -p "$@"
   export XDG_CONFIG_HOME=$_XDG_CONFIG_HOME
   export NVIM_APPNAME=$_NVIM_APPNAME
}
