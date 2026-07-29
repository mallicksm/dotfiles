#-------------------------------------------------------------------------------
# Note: cd/cd_up/cd_func
# cd up to n dirs
# using:  cd.. 10   cd.. dir
#-------------------------------------------------------------------------------

# CDPATH: directories `cd` searches when given a relative path (no leading /).
# Order matters -- bash searches them in order and stops at the first match.
#   .      -> cwd first (cwd-relative wins)
#   $HOME  -> `cd dotfiles` -> ~/dotfiles
# Site-specific roots (EDA workspaces, etc.) are NOT hardcoded here -- they
# live in ~/corp/corp_settings.sh, which exports $CORP_CDPATH (a colon-list)
# BEFORE this file is sourced (bashrc sources corp_settings.sh first). We
# append it after the portable base so `.` always wins. Unset on non-corp
# boxes -> the append is a no-op and dotfiles stays fully portable.
export CDPATH=".:$HOME"
[[ -n ${CORP_CDPATH:-} ]] && CDPATH+=":$CORP_CDPATH"

function cd () {
   # replace "builtin cd" with cd_func() to enable "cd with history"
   if [ -n "$1" ]; then
      # builtin cd "$@"&& ls
      cd_func "$@" && [ "$1" != "--" ]
   else
      # builtin cd ~&& ls
      cd_func ~
   fi
   rc=$?
# Note: 
#    ~/dotfiles/utils/bash_cd_func.sh writes /tmp/__CWD__ with $CWD after cd
#    This script sources it and executes the prompt_git proc
#    This script is used by zjstatus under in ~/dotfiles/initrc/zellij/layouts/def.kdl
   echo "cd $PWD" > /tmp/___CWD___
   return $rc
}
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
   if [[  -v ${the_new_dir} ]]; then
      the_new_dir=${!the_new_dir};# handle cdable_vars
   fi

   # CDPATH-aware existence check.
   # Plain bash builtin `cd` consults $CDPATH when the argument is a bare
   # name (no leading /, ./, or ../). Our [ -d ] check above defeats that
   # because it tests the literal arg against cwd only -- so without this
   # block, `cd dotfiles` from /tmp would error out before Pushd is ever
   # called. Walk $CDPATH explicitly here, mirroring bash's own semantics.
   if [[ ! -d $the_new_dir ]]; then
      case $the_new_dir in
         /*|./*|../*) ;;     # absolute / relative-with-dot: no CDPATH search
         *)
            local _d _found=""
            local IFS=:
            for _d in $CDPATH; do
               if [[ -d "$_d/$the_new_dir" ]]; then
                  the_new_dir="$_d/$the_new_dir"
                  _found=1
                  break
               fi
            done
            [[ -n $_found ]] || { echo "bash: cd: $1: No such file or directory"; return 1; }
            ;;
      esac
      [[ -d $the_new_dir ]] || { echo "bash: cd: $1: No such file or directory"; return 1; }
   fi
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

