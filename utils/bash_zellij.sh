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
      -s|--create-session <session-name>         -Create a session with <session-name> (Not within zellij)
      -k|--kill-session                          -kill session (Not within zellij)
      -K|--kill-all-sessions                     -kill all sessions (Not within zellij)
      -l|--layout                                -def(default)|pal
"
function zm () {
   declare -A opt=([ZELLIJ_LAYOUT]=pal)
   args=()
   while (( $# )); do
      case $1 in 
         -s|--create-session)
            opt[ZELLIJ_SESSION_NAME]="$2"
            shift 2
         ;;
         -k|--kill-session)
            opt[ZELLIJ_KILL_SESSION]="$2"
            shift 2
         ;;
         -K|--kill-all-sessions)
            opt[ZELLIJ_KILL_ALL_SESSIONS]="yes"
            shift 1
         ;;
         -l|--layout)
            opt[ZELLIJ_LAYOUT]="$2"
            shift 2
         ;;
         *) common_options "$1";shift 1
      esac
   done
   [[ "${opt[HELP]}" ]] && { echo "${helpstr[$FUNCNAME]}";return 0; }
   if [[ ! -z $ZELLIJ ]]; then
      # working within zellij
      zellij action launch-or-focus-plugin zellij:session-manager --floating
      return
   fi
   num_sessions=$(zellij ls 2>/dev/null | wc -l)
   if [[ ${opt[ZELLIJ_KILL_ALL_SESSIONS]} == "yes" ]]; then
      zellij kill-all-sessions -y || true
      zellij delete-all-sessions -y || true
      # if the above does not work, go turbo
      local zj=$(ps aux |grep soummya|grep 'zellij --server' |grep -v grep|head -n 1|awk '{print $2}')
      if [[ $zj != "" ]]; then
         kill -9 $zj
      fi
      rm -rf ~/.cache/zellij/
      return
   fi
   if [[ ! -z ${opt[ZELLIJ_KILL_SESSION]} ]]; then
      zellij kill-session ${opt[ZELLIJ_KILL_SESSION]} 
      zellij delete-session --force ${opt[ZELLIJ_KILL_SESSION]} 
      return
   fi
   if [[ ! -z ${opt[ZELLIJ_SESSION_NAME]} ]]; then
      # user gave a new name, must create session
      zellij --new-session-with-layout ${opt[ZELLIJ_LAYOUT]} --session ${opt[ZELLIJ_SESSION_NAME]} 
      return
   fi
   if [[ ($num_sessions -eq 0) && ( -z ${opt[ZELLIJ_SESSION_NAME]} ) ]]; then
      # no sessions user must provide name
      echo "Attention: no sessions found or new name given"
   elif [[ ($num_sessions -eq 1) && ( ! $(zellij ls) =~ EXITED ) ]]; then
      # Only attach if a single good session exists
      zellij attach --create
   else
      # fzf if >1 session exists (even if EXITED)
      session=$(zellij ls 2>/dev/null | fzf --exit-0 --ansi --height 40% --header 'Enter to open session:') && zellij attach "${session%% *}" || echo "No sessions selected"
   fi
}
function zrf () { 
   zellij run --name "$*" --floating -- bash -ic "$*";
}
function ze () { 
   zellij action edit-scrollback;
}
function zs () { 
   zellij action launch-or-focus-plugin -f "zellij:session-manager"
}
function zt () { 
   zellij action new-tab -l $ZELLIJ_CONFIG_DIR/layouts/pane_${1:-pal}.kdl
}
