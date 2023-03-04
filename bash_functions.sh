#-------------------------------------------------------------------------------
# Functions
#===============================================================================
#{{{ modpath
function modpath () {
   loc=$1
   cmd=${2:-"d"}
   var=${3:-PATH}
   eval PATHv=\$$var    # set PATHv to the var reference (double indirection)
   NEW_PATH=${PATHv/#"$loc:"}         #    Begining
   NEW_PATH=${NEW_PATH/#"$loc"}       #    Solo
   NEW_PATH=${NEW_PATH/%":$loc"}      #    Ending
   NEW_PATH=${NEW_PATH//":$loc:"/:}   #    Multiple middles

   if [ $cmd = "d" ]; then
      export ${var}=$NEW_PATH
   elif [ $cmd = "b" ]; then
      if [ -z $NEW_PATH ]; then
         export ${var}=$loc   # old PATH empty
      else
         export ${var}=$loc:$NEW_PATH
      fi
   elif [ $cmd = "a" ]; then
      if [ -z $NEW_PATH ]; then
         export ${var}=$loc   # old PATH empty
      else
         export ${var}=$NEW_PATH:$loc
      fi
   else
      echo "usage: modpath [location] [d elete|b efore|a fter] [VARIABLE]"
   fi
}
#}}}

#-------------------------------------------------------------------------------
#{{{ Pushd/Popd
function Pushd () {
   command pushd "$@" > /dev/null
}
# Popd (pair)
function Popd () {
   command popd "$@" > /dev/null
}
#}}}

#-------------------------------------------------------------------------------
#{{{ var
function var () {
   VAR=${1:-PATH}
   DOLLARVAR=${!VAR}
   echo -e ${DOLLARVAR//:/\\n}
}
#}}}

#-------------------------------------------------------------------------------
#{{{ xpushd/xpopd
function xpushd () {
   dir=${1:-.}
   cd $dir
   echo "pushing: $proj/.x_push_pop_stack"
   mkdir -p $proj
   echo "$PWD" > "$proj/.x_push_pop_stack"
}
# xpopd (pair)
function xpopd () {
   echo "popping: $proj/.x_push_pop_stack"
   if [[ -f $proj/.x_push_pop_stack ]]; then
      cd $(command cat "$proj/.x_push_pop_stack")
   else
      echo "Note: xpushd first"
   fi
}
#}}}

#-------------------------------------------------------------------------------
#{{{ list -long ls filechange last minute
function list () {
   declare -A opt
   while (( $# )) ; do
      case "$1" in
         -h|help)
            opt[HELP]=1
            shift 1
            ;;
         -t|time)
            opt[TIME]=$2
            shift 2
            ;;
         *)
            args+=("$1")
            shift 1
            ;;
      esac
   done
   if [[ "${opt[HELP]}" ]]; then
      print "blue" "Command:"
      print "blue" "   Usage: $(basename $0) ${FUNCNAME[0]} [-help|-time] [path]"
      return 0
   fi
   dir=${args[@]:-.}
   str="find $dir -type f -mmin -${opt[TIME]:-2} -exec ls -ltr {} +"
   echo "Executing: $str"
   command $str
}
#}}}

#-------------------------------------------------------------------------------
#{{{ cd/cd_up/cd_func
# cd up to n dirs
# using:  cd.. 10   cd.. dir
function cd () {
   # replace "builtin cd" with cd_func() to enable "cd with history"
   if [ -n "$1" ]; then
      # builtin cd "$@"&& ls
      cd_func "$@" && [ "$1" != "--" ]
   else
      # builtin cd ~&& ls
      cd_func ~
   fi
}

function cd_up () {
  case $1 in
    *[!0-9]*)                                          # if not a number ..
      cd $( pwd | sed -r "s|(.*/$1[^/]*/).*|\1|" )     # search dir_name in current path, if found - cd to it
      ;;                                               # if not found - not cd
    *)
      cd $(printf "%0.0s../" $(seq 1 $1));             # cd ../../../../  (N dirs)
    ;;
  esac
}
alias 'cd..'='cd_up'                                   # because can not name function 'cd..'

function cd_func () {
   local x2 the_new_dir adir index
   local -i cnt

   if [[ $1 ==  "--" ]]; then
      dirs -v
      return 0
   fi

   the_new_dir=$1
   [[ -z $1 ]] && the_new_dir=$HOME

   if [[ ${the_new_dir:0:1} == '-' ]]; then
      # Extract dir N from dirs
      index=${the_new_dir:1}
      [[ -z $index ]] && index=1
      adir=$(dirs +$index)
      [[ -z $adir ]] && return 1
      the_new_dir=$adir
   fi

   #
   # '~' has to be substituted by ${HOME}
   [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

   #
   # Now change to the new dir and add to the top of the stack
   Pushd "${the_new_dir}"
   [[ $? -ne 0 ]] && return 1
   the_new_dir=$(pwd)

   #
   # Trim down everything beyond 11th entry
   popd -n +11 2>/dev/null 1>/dev/null

   #
   # Remove any other occurence of this dir, skipping the top of the stack
   for ((cnt=1; cnt <= 10; cnt++)); do
      x2=$(dirs +${cnt} 2>/dev/null)
      [[ $? -ne 0 ]] && return 0
      [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
      if [[ "${x2}" == "${the_new_dir}" ]]; then
         popd -n +$cnt 2>/dev/null 1>/dev/null
         cnt=cnt-1
      fi
   done

   return 0
}
#}}}

#-------------------------------------------------------------------------------
#{{{ vgrep
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
#}}}

#-------------------------------------------------------------------------------
#{{{ fzf
# Configuration
# -------------
export FZF_DEFAULT_COMMAND="fd --type f --follow --exclude '.git'"
export FZF_DEFAULT_OPTS='--height 100% --layout=reverse --border=double --margin=1 --padding=1 --multi --info=inline'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--height 100% --preview 'bat --color=always {}'"

export FZF_ALT_C_COMMAND="fd --type d . --color=never --hidden --exclude '.git'"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -50'"

export FZF_TMUX=1
# for more info see fzf/shell/completion.zsh
_fzf_compgen_path() {
    fd . "$1"
}
_fzf_compgen_dir() {
    fd --type d . "$1"
}

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    *)            fzf "$@" ;;
  esac
}
# }}}

#-------------------------------------------------------------------------------
#{{{ fzf-functions
function rgrep() {
rg --color=always --line-number --no-heading --smart-case "${*:-}" |
   fzf --ansi \
       --delimiter : \
       --preview 'bat --color=always {1} --highlight-line {2}' \
       --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
       --bind 'enter:become(vim {1} +{2})'
}
is_in_git_repo() {
   git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
   fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

# file explorer
alias ,f=,e
,e() {
  command ls |
  fzf-down \
      --header 'Press CTRL-/ to toggle preview' \
      --bind 'ctrl-/:toggle-preview' \
      --height 100% \
      --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
}

# find-in-file
,rg() {
   rg --files-with-matches --no-messages "$1" |
   fzf-down \
      --preview "rg --ignore-case --pretty --context 10 '$1' {}"
}

,gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
  cut -c4- | sed 's/.* -> //'
}

,gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

,gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {}'
}

,gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

,gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
  cut -d$'\t' -f1
}

,gs() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}
#}}}

#-------------------------------------------------------------------------------
#{{{ tm
function tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}
#}}}

#-------------------------------------------------------------------------------
#{{{ cat ll la and lt aliases
unalias cat 2> /dev/null # blow away any previous aliases if any
function cat() {
   if command -v bat >/dev/null ; then
      command bat --theme=ansi "$@"
   else
      command cat "$@"
   fi
}
unalias ll 2> /dev/null
function ll() {
   if command -v exa >/dev/null ; then
      command exa --long --header -s modified "$@"
   else
      command ls -Fslr --color=auto "$@"
   fi
}
unalias la 2> /dev/null
function la() {
   if command -v exa >/dev/null ; then
      command exa --long --header -s modified -a "$@"
   else
      command ls -Fslra --color=auto "$@"
   fi
}
unalias lt 2> /dev/null
function lt() {
   if command -v exa >/dev/null ; then
      command exa --tree "$@"
   else
      command tree
   fi
}
unalias du 2> /dev/null
function du() {
   if command -v ncdu >/dev/null ; then
      command ncdu "$@"
   else
      command du -k "$@"
   fi
}
unalias df 2> /dev/null
function df() {
   if command -v pydf >/dev/null ; then
      command pydf "$@"
   else
      command df -k "$@"
   fi
}
#}}}

#-------------------------------------------------------------------------------
#{{{ clip from gvim
# My workaround for not having xsel or xclip
#   Ex: clipboard=$( get_clip )
function get_clip() {
   mkdir -p /tmp/$USER
   file=/tmp/$USER/clipboard_contents.txt
   /bin/rm -f $file
   # Help from:  http://stackoverflow.com/a/23237529/120681
   command gvim $file -T dumb --noplugin -n -es -c 'set nomore' +'normal "*P' +'wq'
   cat $file
}
#}}}

#-------------------------------------------------------------------------------
#{{{ install nerdfonts
function ifont() {
   # Install font
   echo "Note: Installing FiraCode font"
   mkdir -p ~/.fonts && pushd ~/.fonts >> /dev/null
   wget --no-verbose https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip -O /tmp/FiraCode.zip 2>/dev/null
   unzip -q /tmp/FiraCode.zip
   popd >> /dev/null
   # Now set font@gnome-terminal
   GNOME_TERMINAL_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}')
   gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ font 'FiraCode Nerd Font Mono 12'
}
#}}}

#-------------------------------------------------------------------------------
#{{{ xvim
function xvim() {
   dbus-launch gnome-terminal --title="gvim: $@" --hide-menubar --geometry=130x50 -- vim "$@" >/dev/null
}
#}}}

#-------------------------------------------------------------------------------
#{{{ utils
function print() {
   nc='\033[0m'
   black="\033[0;30m";        dark_gray="\033[1;30m"
   red="\033[0;31m";          light_red="\033[1;31m"
   green="\033[0;32m";        light_green="\033[1;32m"
   brown_orange="\033[0;33m"; yellow="\033[1;33m"
   blue="\033[0;34m";         light_blue="\033[1;34m"
   purple="\033[0;35m";       light_purple="\033[1;35m"
   cyan="\033[0;36m";         light_cyan="\033[1;36m"
   light_gray="\033[0;37m";   white="\033[1;37m"

   color=$1
   str="${@:2}"
   printf "${!color}$str${nc}\n"
}
#}}}
