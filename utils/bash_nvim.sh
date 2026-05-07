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
   local appname='nvim.easy'   # default config (lazy.nvim-based)

   while (( $# )); do
      case $1 in
         -x)
            opt[XTERM]="xterm -geom 110x50-100-200 -e"
            shift 1
         ;;
         -p)
            # -p selects nvim.pack -- the parallel config powered by nvim's
            # built-in vim.pack package manager (see ~/dotfiles/nvim.pack/).
            # Plugins/state are isolated under ~/.local/{share,state,cache}/nvim.pack/
            # so toggling between vi and `vi -p` will not touch the .easy data dir.
            appname='nvim.pack'
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
   export NVIM_APPNAME=$appname

   # (huge-file fallback removed -- snacks.bigfile in the active config now
   # disables expensive features at BufReadPre on a per-buffer basis. See
   # snacks.lua's `bigfile = { size = 10 MB }`. No need to swap NVIM_APPNAME.)

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
