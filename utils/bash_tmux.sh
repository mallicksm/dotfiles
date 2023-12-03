# tmux settings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#-------------------------------------------------------------------------------
function tm() {
   [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
   if [ $1 ]; then
      tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
   fi
   session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}
#-------------------------------------------------------------------------------
# Note: Works in conjunction with ~/dotfiles/utils/tmux_status-right.sh.
# This prompt locks up the git repo for long commands, 
function prompt() {
   rm -rf /tmp/no_prompt
}
function noprompt() {
   echo "export __NO_PROMPT__=1" > /tmp/no_prompt
}
tmux-help() {
   cat ~/dotfiles/utils/help_tmux.txt | fzf --header-lines 2
}
