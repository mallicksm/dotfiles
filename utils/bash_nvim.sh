#-------------------------------------------------------------------------------
# vi alias
#-------------------------------------------------------------------------------
unalias vi 2>/dev/null

function vi () {
   # getopt
   declare -A opt
   local args=()
   local nfiles=0
   local use_split=0

   while (( $# )); do
      case $1 in
         -x)
            opt[XTERM]="xterm -geom 110x50-100-200 -e"
            shift 1
         ;;
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

   # count real files only
   for f in "${args[@]}"; do
      [[ -f "$f" ]] && ((nfiles++))
   done

   # decide split
   if (( nfiles > 0 && nfiles <= 3 )); then
      use_split=1
   fi

   # open in a subshell
   (
   export XDG_CONFIG_HOME=~/dotfiles/
   export NVIM_APPNAME=nvim.easy 

   # preserve your large-file logic
   if [[ -n "${args[0]}" && -f "${args[0]}" ]]; then
      if [[ $(wc -l < "${args[0]}") -gt 1000000 ]]; then
         export NVIM_APPNAME=nvim.bare 
      fi
   fi

   # build command (respect user-provided -O)
   local cmd
   if (( use_split )) && [[ "${opt[OPT]}" != "-O" ]]; then
      cmd=(nvim -O ${opt[OPT]} "${args[@]}")
      echo "Note: nvim -O ${opt[OPT]} ${args[@]}"
   else
      cmd=(nvim ${opt[OPT]} "${args[@]}")
      echo "Note: nvim ${opt[OPT]} ${args[@]}"
   fi

   if [[ -n "${opt[XTERM]:-}" ]]; then
      ${opt[XTERM]} "${cmd[@]}" &
   else
      "${cmd[@]}"
   fi
   )
}

export -f vi
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
   echo "Note: nvim ${opt[OPT]} ${args[@]}"
   nvim ${opt[OPT]} ${args[@]}
   )
}
# make available to subshells
export -f vim
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
