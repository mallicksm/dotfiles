modpath ~/dotfiles/utils a

# Terminal-aware head: default to ~screen height when no option flags are given.
# Plain `head`, `head file`, and `head -5` / `head -n 5` all behave as expected.
head() {
   if (( $# == 0 )) || [[ $1 != -* ]]; then
      command head -n $((${LINES:-12} - 2)) "$@"
   else
      command head "$@"
   fi
}

# Terminal-aware tail: same rules as head() above.
tail() {
   if (( $# == 0 )) || [[ $1 != -* ]]; then
      command tail -n $((${LINES:-12} - 2)) "$@"
   else
      command tail "$@"
   fi
}

# h: on-demand cross-shell history view.
#
# Two steps:
#   1. `history -n` -- pull only the NEW lines that sibling shells have
#      appended to ~/.bash_history since this shell last read it. Cheaper
#      than `history -r` (which re-reads the whole file every call).
#   2. print the last N lines of the merged in-memory history.
#
# Pairs with set_win_title's per-prompt `history -a` (in bash_starship.sh):
# that flush keeps Up arrow session-local; `h` is the on-demand
# "show me everything across all panes" workflow.
#
# Usage:
#   h          last 60 lines (default)
#   h 100      last 100 lines
#   h 5        last 5 lines
#
# `command tail` bypasses our tail() wrapper above so the count isn't
# silently shrunk to terminal height when called as `h` (no args).
h() {
   history -n
   history | command tail -n "${1:-60}"
}
