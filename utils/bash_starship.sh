# Starship configuration
export STARSHIP_CONFIG=$HOME/corp/starship.toml
export STARSHIP_LOG=error
function set_win_title(){
   # set title
   echo -ne "\033]0; [$SHLVL] $USER@$(hostname -s)  $PWD\007"
   # sync history across windows via a single $HISTFILE (~/.bash_history).
   # 1. append this shell's new in-memory lines to $HISTFILE
   # 2. clear in-memory list
   # 3. re-read $HISTFILE into memory so we see lines from sibling panes
   #
   # Previous implementation used per-PID files ($HISTFILE.$$) and an O(N)
   # ls+read of every $HISTFILE.[0-9]* on each prompt. That sprawled to
   # 2,000+ files in $HOME and lost commands whenever a shell died abruptly
   # before its precmd ran. Single-file mode is cheaper and survives any
   # shell that flushes once with `history -a`.
   history -a
   history -c
   history -r
}
# shellcheck disable=SC2034  # consumed by `starship init bash` below, not by this file
starship_precmd_user_func="set_win_title"
eval "$(starship init bash)"

