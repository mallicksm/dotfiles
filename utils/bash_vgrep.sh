#-------------------------------------------------------------------------------
export RIPGREP_CONFIG_PATH=~/dotfiles/initrc/ripgrep
function rgrep() {
   # https://sourcegraph.com/github.com/junegunn/fzf/-/blob/ADVANCED.md
   arg=
   FILE_GLOB=
   for arg in "$@"; do
      FILE_GLOB+="--glob=$arg "
   done
   # Switch between Ripgrep launcher mode (CTRL-R) and fzf filtering mode (CTRL-F)
   rm -f /tmp/rg-fzf-{r,f}
   RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case $FILE_GLOB"
   : | fzf --ansi --disabled --query "" \
      --bind "start:reload($RG_PREFIX {q})+unbind(ctrl-r)" \
      --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(2. fzf> )+enable-search+rebind(ctrl-r)+transform-query(echo {q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f)" \
      --bind "ctrl-r:unbind(ctrl-r)+change-prompt(1. ripgrep> )+disable-search+reload($RG_PREFIX {q} || true)+rebind(change,ctrl-f)+transform-query(echo {q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r)" \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --prompt '1. ripgrep> ' \
      --delimiter : \
      --header '╱ CTRL-R (ripgrep mode) ╱ CTRL-F (fzf mode) ╱' \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'left,50%,border-bottom,+{2}+3/3,~3' \
      --bind 'enter:become(vim {1} +{2})'
}
#-------------------------------------------------------------------------------
# Note: vgrep
function vgrep () {
   declare -A opt
   local args
   while (( $# )); do
      case $1 in
         -i|--ignorecase)
            opt[IGNORECASE]=1
            shift 1
         ;;
         -v|--verilog)
            opt[VERILOG]=1
            shift 1
         ;;
         -t|--tcl)
            opt[TCL]=1
            shift 1
         ;;
         -c)
            opt[C_LANG]=1
            shift 1
         ;;
         -h|--header)
            opt[HEADER]=1
            shift 1
         ;;
         -m|--makefile)
            opt[MAKEFILE]=1
            shift 1
         ;;
         --help)
            opt[HELP]=1
            shift 1
         ;;
         -*)
            echo "Attention: Unknown Argument $1" >&2
            return 1
         ;;
         *)
            args+=("$1")
            shift
         ;;
      esac
   done
   if [[ ${opt[HELP]} -eq 1 ]]; then
      echo "Usage: vgrep PATTERN [OPTION]"
      echo "Search for PATTERN recursively in current directory"
      echo "PATTERN is, by default, a basic regular expression."
      echo "Example: vgrep 'hello world' -v"
      echo "Example: vgrep '[hello|world]' -v"
      echo ""
      echo "File selection:"
      echo "-v|--verilog          RTL Files in Verilog and VHDL, .sv .svh and .v "
      echo "-t|--tcl              tcl style files like .tcl .qel"
      echo "-c                    C programming files like .c .S"
      echo "-h|--header           Header files in c and rtl, .h, .svh"
      echo "-m |--makefile        Makefiles like Makefile and .mk"
      return 0
   fi
   ex="--exclude=*svn* --exclude-dir=archive --exclude=tags"
   if [[ $args == "" ]]; then
      echo "Attention: PATTERN not provided" >&2
      echo ""
      vgrep --help
      return 1
   fi
   local v
   ic=""
   if [[ ${opt[IGNORECASE]} -eq 1 ]]; then
      ic="-i"
   fi
   if [[ ${opt[VERILOG]} -eq 1 ]]; then
      v="--include=*.v --include=*.sv --include=*.vhd --include=*.svh"
   fi
   local t
   if [[ ${opt[TCL]} -eq 1 ]]; then
      t="--include=*.tcl --include=*.qel --include=*.fs"
   fi
   local c
   if [[ ${opt[C_LANG]} -eq 1 ]]; then
      c="--include=*.c --include=*.S --include=*.cpp"
   fi
   local h
   if [[ ${opt[HEADER]} -eq 1 ]]; then
      h="--include=*.h --include=*.svh"
   fi
   local m
   if [[ ${opt[MAKEFILE]} -eq 1 ]]; then
      m="--include=*.mk --include=Makefile --include=makefile"
   fi
   str="grep --color=auto $ic "${args[@]}" . -R $v $h $c $t $m $ex"
   echo "Executing: $str"
   command $str
}
