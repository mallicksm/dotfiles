#-------------------------------------------------------------------------------
export RIPGREP_CONFIG_PATH=~/dotfiles/initrc/ripgreprc
# Note: rgrep
function rgrep() {
   # https://sourcegraph.com/github.com/junegunn/fzf/-/blob/ADVANCED.md
   rg --color=always --line-number --no-heading --smart-case "" |
   fzf --ansi \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --delimiter : \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
      --bind 'enter:become(vim {1} +{2};echo Selected: {1})'
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
         -r|--rtl)
            opt[RTL]=1
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
   ex="--exclude=*svn* --exclude-dir=archive --exclude=tags --exclude-dir=fsdb"
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
   if [[ ${opt[RTL]} -eq 1 ]]; then
      v="--include=*.v --include=*.sv --include=*.vhd --include=*.svh --exclude=postDFT --exclude-dir=guc_libs --exclude-dir=.zfs --exclude-dir=asic_ip"
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
