export ZELLIJ_CONFIG_DIR=~/dotfiles/initrc/zellij
function common_options () {
   case $1 in
      -h|--help|-help|help)
         opt[HELP]=1
         ;;
      -*)
         echo "Attention: Unknown Argument $1"
         return 1
         ;;
      *)
         args+=("$1")
         ;;
   esac
}
declare -A helpstr=()
helpstr["zm"]="\
   usage: zm [options|-h]
   create or attach to zellij session

      ------
      Options:
      -s|--create-session <session-name>         -Create a session with <session-name>
      -k|--kill-all-sessions                     -kill all sessions
"
function zm () {
   if [[ ! -z $ZELLIJ ]]; then
      echo "Attention: cannot be run from within zellij"
      return
   fi
   declare -A opt=()
   args=()
   while (( $# )); do
      case $1 in 
         -s|--create-session)
            opt[ZELLIJ_SESSION_NAME]="$2"
            shift 2
         ;;
         -k|--kill-all-sessions)
            opt[ZELLIJ_KILL_ALL_SESSIONS]="yes"
            shift 1
         ;;
         *) common_options "$1";shift 1
      esac
   done
   [[ "${opt[HELP]}" ]] && { echo "${helpstr[$FUNCNAME]}";return 0; }
   num_sessions=$(zellij ls 2>/dev/null | wc -l)
   if [[ ${opt[ZELLIJ_KILL_ALL_SESSIONS]} == "yes" ]]; then
      zellij ka -y
      zellij da -y
      rm -rf ~/.cache/zellij/
      echo "Note: check if zellij process exists and kill it"
      return
   fi
   if [[ ! -z ${opt[ZELLIJ_SESSION_NAME]} ]]; then
      zellij --session ${opt[ZELLIJ_SESSION_NAME]} 
      return
   fi
   if [[ $num_sessions -eq 0 ]]; then
      if [[ -z ${opt[ZELLIJ_SESSION_NAME]} ]]; then
         echo "Attention: no sessions found or new name given"
      else
         zellij --session ${opt[ZELLIJ_SESSION_NAME]}
      fi
   elif [[ ($num_sessions -eq 1) && ( ! $(zellij ls) =~ EXITED ) ]]; then
      # Only attach if a single good session exists
      zellij attach --create
   else
      # fzf if >1 session exists (even if EXITED)
      session=$(zellij ls 2>/dev/null | fzf --exit-0 --ansi --header 'Enter to open:') && zellij attach "${session%% *}" || echo "No sessions selected"
   fi
}
function zr () { 
   zellij run --name "$*" -- bash -ic "$*";}
function zrf () { 
   zellij run --name "$*" --floating -- bash -ic "$*";
}
function ze () { 
   zellij edit "$*";
}
function zef () { 
   zellij edit --floating "$*";
}
function zsc () { 
   zellij action edit-scrollback;
}

