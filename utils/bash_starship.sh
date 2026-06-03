# Starship configuration
export STARSHIP_CONFIG=$HOME/corp/starship.toml
export STARSHIP_LOG=error
function set_win_title(){
   # set title
   echo -ne "\033]0; [$SHLVL] $USER@$(hostname -s)  $PWD\007"

   # Per-prompt history flush. Only `history -a` -- append this shell's new
   # in-memory lines to $HISTFILE. We intentionally do NOT do `history -c`
   # / `history -r` here: those two steps were rebuilding this shell's
   # in-memory history from the merged file on every prompt, which made
   # Up arrow walk sibling panes' commands instead of this shell's own.
   #
   # End-state:
   #   - This shell's in-memory history = what this shell typed (chronological).
   #   - Up / history-search-backward => only this shell's commands.
   #   - $HISTFILE still gets a steady stream of appends from every shell,
   #     so new shells inherit the full corpus at startup (and ~/.bashrc's
   #     `shopt -s histappend` ensures clean shutdowns also append).
   #   - To search cross-shell history live: Ctrl-F (fzf over $HISTFILE)
   #     or Ctrl-R (atuin, which has its own SQLite DB independent of bash).
   #
   # Previous implementation used per-PID files ($HISTFILE.$$) and an O(N)
   # ls+read of every $HISTFILE.[0-9]* on each prompt. That sprawled to
   # 2,000+ files in $HOME and lost commands whenever a shell died abruptly
   # before its precmd ran. Single-file mode is cheaper and survives any
   # shell that flushes once with `history -a`.
   history -a
}
# shellcheck disable=SC2034  # consumed by `starship init bash` below, not by this file
starship_precmd_user_func="set_win_title"
eval "$(starship init bash)"

