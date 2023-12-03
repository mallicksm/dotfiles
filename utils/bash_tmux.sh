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
  search_term="$1"

  tmux_header=$(cat <<'EOF'
---------------------------------------------------------------------------
Mapping   | Command                                     | Role
---------------------------------------------------------------------------
EOF
)
  # Table content
  tmux_table=$(cat <<'EOF'
M-H       | resize-pane -L 4                            | Resize pane toward left
M-J       | resize-pane -D 4                            | Resize pane toward bottom
M-K       | resize-pane -U 4                            | Resize pane toward up
M-L       | resize-pane -R 4                            | Resize pane toward right
M-!       | split-window -f -l 10 -c "#{pane_current_path}" | Bottom popup terminal
M--       | display-popup -E -w 80% -h 80% "lf"         | LF file manager in a popup
M-:       | command-prompt                              | Display command prompt
M-<       | swap-pane -U                                | Move pane to the left
M->       | swap-pane -D                                | Move pane to the right
M-Enter   | new-window                                  | Create a new window
M-=       | choose-buffer                               | Select among paste buffers
M-Down    | swap-window -t +1                           | Move window to the right
M-Up      | swap-window -t -1                           | Move window to the left
M-Left    | previous-window                             | Select next window to the left
M-Right   | next-window                                 | Select next window to the right
M-k       | previous-window                             | Select next window to the left
M-j       | next-window                                 | Select next window to the right
M-O       | switch-client -l                            | Change current Tmux client and session
M-n       | command-prompt -p "New Session:" "new-session -A -s '%%'" | Create new session
M-X       | "kill-session -a"                           | Kill all other sessions
M-x       | kill-session                                | Kill current session
M-h       | choose-window 'join-pane -h -s "%%"'        | Attach pane to another window
M-V       | select-layout even-horizontal               | Arrange panes using horizontal layout
M-S       | select-layout even-vertical                 | Arrange panes using vertical layout
M-l       | last-window                                 | Go to the last window
M-m       | command-prompt -p "Search man pages for:" "new-window 'exec man %%'" | Query man page in a temporary window
M-o       | selectp -t :.+                              | Go to the other split
M-p       | run-shell -b ~/bin/tmux-fzf                 | Select picker for window
M-s       | split-window -v -c "#{pane_current_path}"   | Create horizontal split
M-v       | split-window -v -c "#{pane_current_path}"   | Create vertical split
M-t       | break-pane                                  | Convert pane to a proper window
M-w       | choose-window                               | Show a list of sessions and windows
M-y       | copy-mode                                   | Activate copy mode
M-z       | resize-pane -Z                              | Maximize the current pane
C-b C-g   | setw synchronize-panes                      | Synchronize panes
C-b C-m   | if -F '#{s/off//:mouse}' 'set -g mouse off; display-message "mouse: off"' 'set -g mouse on; display-message "mouse: on"' | Toggle mouse mode on/off
C-b C-p   | run "tmux capture-pane; tmux save-buffer ~/tmp/tmux-\"$(date +%FT%T)\"" | Save buffer to a file
C-b C-r   | source-file ~/.tmux.conf \; display-message "Config reloaded" | Reload Tmux config
C-b C-s   | if -F '#{s/off//:status}' 'set status off' 'set status on' | Toggle status bar on/off
EOF
)

  # Perform fuzzy search and print matching rows
   echo "$tmux_header"
   if [[ -z $search_term ]]; then
      echo "$tmux_table"
   else
      echo "$tmux_table" | grep -i "$search_term"
   fi
}
