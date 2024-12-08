unalias vi 2>/dev/null
function vi () {
   XDG_CONFIG_HOME=~/dotfiles/ NVIM_APPNAME=nvim.easy nvim -p "$@" 
}
function vimdiff () {
   XDG_CONFIG_HOME=~/dotfiles/ NVIM_APPNAME=nvim.easy nvim -d "$@" 
}

# vimscript based original nvim installation
function svim () {
   XDG_CONFIG_HOME=~/dotfiles/ NVIM_APPNAME=nvim.vim nvim -p "$@"
}
linediff() { 
   if [ -z "$1" ] || [ -z "$2" ]; then 
      return; 
   fi
   f1=$(basename "$1").f1
   f2=$(basename "$2").f2
   nl "$1" > "/tmp/$f1"
   nl "$2" > "/tmp/$f2"
   tkdiff "/tmp/$f1" "/tmp/$f2"
   rm "/tmp/$f1" "/tmp/$f2"
}
dsplinediff() { 
   if [ -z "$1" ] || [ -z "$2" ]; then 
      return; 
   fi
   f1=$(basename "$1").f1
   f2=$(basename "$2").f2
   nl "$1" |sed 's/+//g' > "/tmp/$f1"
   nl "$2" |sed 's/+//g' > "/tmp/$f2"
   tkdiff "/tmp/$f1" "/tmp/$f2"
   rm "/tmp/$f1" "/tmp/$f2"
}
