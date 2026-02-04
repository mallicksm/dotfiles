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
      -l|--layout                                -def(default)|def
"
function zm () {
   # Preserve DISPLAY at function entry to restore if it gets cleared
   local saved_display="${DISPLAY:-}"
   declare -A opt=([ZELLIJ_LAYOUT]=def)
   args=()
   while (( $# )); do
      case $1 in 
         -s|--create-session)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
               echo "Error: -s|--create-session requires a session name"
               echo "Usage: zm -s <session-name>"
               return 1
            fi
            opt[ZELLIJ_SESSION_NAME]="$2"
            shift 2
         ;;
         -k|--kill-session)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
               echo "Error: -k|--kill-session requires a session name"
               echo "Usage: zm -k <session-name>"
               return 1
            fi
            opt[ZELLIJ_KILL_SESSION]="$2"
            shift 2
         ;;
         -K|--kill-all-sessions)
            opt[ZELLIJ_KILL_ALL_SESSIONS]="yes"
            shift 1
         ;;
         -l|--layout)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
               echo "Error: -l|--layout requires a layout name"
               echo "Usage: zm -l <layout-name>"
               return 1
            fi
            opt[ZELLIJ_LAYOUT]="$2"
            shift 2
         ;;
         *) common_options "$1";shift 1
      esac
   done
   [[ "${opt[HELP]}" ]] && { echo "${helpstr[$FUNCNAME]}";return 0; }
   if [[ (! -z $ZELLIJ) && ($ZELLIJ -ne 0) ]]; then
      # working within zellij
      zellij action launch-or-focus-plugin zellij:session-manager --floating
      # Restore DISPLAY before returning
      [[ -n "$saved_display" ]] && export DISPLAY="$saved_display" || unset DISPLAY
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
      # Restore DISPLAY after killing all sessions
      [[ -n "$saved_display" ]] && export DISPLAY="$saved_display" || unset DISPLAY
      return
   fi
   if [[ ! -z ${opt[ZELLIJ_KILL_SESSION]} ]]; then
      session_name="${opt[ZELLIJ_KILL_SESSION]}"
      # Check if session exists before trying to kill it
      # Use --no-formatting to get clean output without ANSI color codes
      session_list=$(zellij ls --no-formatting 2>/dev/null)
      if [[ -z "$session_list" ]]; then
         echo "Error: No sessions found"
         # Restore DISPLAY before returning
         [[ -n "$saved_display" ]] && export DISPLAY="$saved_display" || unset DISPLAY
         return 1
      fi
      # Extract session names (first word of each line)
      session_names=$(echo "$session_list" | awk '{print $1}')
      session_exists=$(echo "$session_names" | grep -Fx "${session_name}")
      if [[ -z "$session_exists" ]]; then
         echo "Error: Session '${session_name}' not found"
         echo "Available sessions:"
         echo "$session_list"
         # Restore DISPLAY before returning
         [[ -n "$saved_display" ]] && export DISPLAY="$saved_display" || unset DISPLAY
         return 1
      fi
      echo "Killing session: ${session_name}"
      zellij kill-session "${session_name}" 2>/dev/null || true
      zellij delete-session --force "${session_name}" 2>/dev/null || true
      echo "Session '${session_name}' killed and deleted"
      # Restore DISPLAY after killing session (zellij might have cleared it)
      [[ -n "$saved_display" ]] && export DISPLAY="$saved_display" || unset DISPLAY
      return
   fi
   if [[ ! -z ${opt[ZELLIJ_SESSION_NAME]} ]]; then
      # user gave a new name, must create session
      zellij --new-session-with-layout ${opt[ZELLIJ_LAYOUT]} --session ${opt[ZELLIJ_SESSION_NAME]} 
      # Restore DISPLAY after creating session (zellij might have cleared it)
      [[ -n "$saved_display" ]] && export DISPLAY="$saved_display" || unset DISPLAY
      return
   fi
   if [[ ($num_sessions -eq 0) && ( -z ${opt[ZELLIJ_SESSION_NAME]} ) ]]; then
      # no sessions user must provide name
      echo "Attention: no sessions found or new name given"
      # Restore DISPLAY before returning
      [[ -n "$saved_display" ]] && export DISPLAY="$saved_display" || unset DISPLAY
   elif [[ ($num_sessions -eq 1) && ( ! $(zellij ls) =~ EXITED ) ]]; then
      # Only attach if a single good session exists
      zellij attach --create
      # Restore DISPLAY after attach (zellij might have cleared it)
      [[ -n "$saved_display" ]] && export DISPLAY="$saved_display" || unset DISPLAY
   else
      # fzf if >1 session exists (even if EXITED)
      # Preserve original DISPLAY value to restore if needed
      local original_display="${DISPLAY:-}"
      local display_modified=0
      if [[ -n "${VNCDESKTOP:-}" ]]; then
         export DISPLAY="${VNCDESKTOP%% *}"
         display_modified=1
      elif [[ -n "${DISPLAY:-}" ]]; then
         # Only modify DISPLAY if it's already set, extract just the :N part
         # Handle cases like "hostname:1.0" -> ":1.0" or ":0" -> ":0"
         if [[ "$DISPLAY" =~ ^: ]]; then
            # Already in :N format (e.g., ":0", ":1"), keep it as-is
            :
         else
            # Extract the display number from formats like "hostname:1.0" or "hostname:1"
            display_num="${DISPLAY##*:}"
            if [[ -n "$display_num" ]]; then
               export DISPLAY=":$display_num"
               display_modified=1
            fi
            # If extraction failed, leave DISPLAY as-is
         fi
      fi
      # If DISPLAY is still not set after above, fzf will handle it or fail gracefully
      session=$(zellij ls 2>/dev/null | fzf --exit-0 --ansi --height 40% --header 'Enter to open session:') && {
         # Session selected, attach to it
         zellij attach "${session%% *}"
         # Restore DISPLAY after attach completes (in case zellij modified it)
         if [[ $display_modified -eq 1 && -n "$original_display" ]]; then
            export DISPLAY="$original_display"
         fi
      } || {
         # fzf was cancelled or failed, restore original DISPLAY
         if [[ $display_modified -eq 1 ]]; then
            if [[ -n "$original_display" ]]; then
               export DISPLAY="$original_display"
            else
               unset DISPLAY
            fi
         fi
         # Also restore saved_display if it was different
         if [[ -n "$saved_display" && "$saved_display" != "${DISPLAY:-}" ]]; then
            export DISPLAY="$saved_display"
         fi
         echo "No sessions selected"
      }
   fi
   # Final safety check: restore DISPLAY if it was cleared
   if [[ -z "${DISPLAY:-}" && -n "$saved_display" ]]; then
      export DISPLAY="$saved_display"
   fi
}
zrf() {
   if [ $# -eq 0 ]; then
      # No args: open a plain interactive shell that closes the pane on exit
      zellij action new-pane \
         --floating \
         --close-on-exit \
         --name "shell" \
	 -- bash -i
   else
      # With args: run the command
      cmd="$*"
      zellij action new-pane \
         --floating \
         --close-on-exit \
         --name "$cmd" \
         -- bash -ic "$cmd; exec bash -i"
   fi
}
function zmv() {
   dir="${1:-right}"

   case "$dir" in
      left|right)
         zellij action move-tab "$dir"
         ;;
      *)
         echo "Invalid direction: $dir"
         echo "Usage: zmv [left|right]"
         return 1
         ;;
   esac
}
function ze () { 
   zellij action edit-scrollback;
}
