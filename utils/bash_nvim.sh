unalias vi 2>/dev/null
# lua based nvim installation (nvim.easy)
function vi () {
   # getopt
   declare -A opt
   local args
   while (( $# )); do
      case $1 in
         -*)
            opt[OPT]="$1"
            shift 1
         ;;
         *)
            args+=("$1")
            shift 1
         ;;
      esac
   done

   # open in a subshell
   (
   export XDG_CONFIG_HOME=~/dotfiles/
   export NVIM_APPNAME=nvim.easy 
   echo "executing: nvim ${opt[OPT]} ${args[@]}"
   nvim ${opt[OPT]} ${args[@]}
   )
}
# vimscript based original nvim installation (nvim.vim)
function vim () {
   # getopt
   declare -A opt
   local args
   while (( $# )); do
      case $1 in
         -*)
            opt[OPT]="$1"
            shift 1
         ;;
         *)
            args+=("$1")
            shift 1
         ;;
      esac
   done

   # open in a subshell
   (
   export XDG_CONFIG_HOME=~/dotfiles/
   export NVIM_APPNAME=nvim.vim 
   echo "executing: nvim ${opt[OPT]} ${args[@]}"
   nvim ${opt[OPT]} ${args[@]}
   )
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
