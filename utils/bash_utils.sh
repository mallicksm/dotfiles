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
