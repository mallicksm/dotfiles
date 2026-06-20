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

# var_dd [VAR ...]   -- "var dedup": companion to bash_snippets.sh::var().
#
# Remove duplicate and empty entries from a colon-separated PATH-style variable,
# preserving the order of the FIRST occurrence of each entry. Designed for
# environments where idempotent `source setup_proj` (or `module load`, or any
# script that blindly prepends to PATH) keeps inflating the variable on every
# call -- a common foot-gun on EDA flow shells. Once PATH grows long enough,
# LSF's profile.lsf (and other PATH-walking probes) can fail in subtle ways.
# Periodic `var_dd PATH` keeps the variable sane.
#
# Default: dedups PATH if no arg is given.
#
# Usage:
#   var_dd                   # dedup PATH (default)
#   var_dd PATH              # explicit
#   var_dd LD_LIBRARY_PATH   # any colon-separated path-style var
#   var_dd MANPATH PYTHONPATH PERL5LIB   # multiple at once
#
#   var PATH      # inspect (from bash_snippets.sh) -- one entry per line
#   var_dd PATH   # dedup in place
#   var PATH      # inspect again to verify
#
# Mechanism:
#   Walk the colon-split entries left-to-right. Track which entries we've
#   already emitted via a bash associative array (fast O(N), no awk/perl
#   fork -- safe to run from PROMPT_COMMAND if you want).
#   Empty entries (from leading/trailing/double colons) are silently dropped.
#
# Caveats:
#   - Bash 4+ (associative arrays). Refuses to run otherwise.
#   - Operates on values as-is -- no symlink resolution, no whitespace trim
#     beyond the explicit empty case. `/foo/` and `/foo` are NOT treated as
#     dups (intentional: trailing slash can matter for some tools).
#   - Preserves the `export` attribute if the var was exported before.
var_dd() {
   if (( ${BASH_VERSINFO[0]:-0} < 4 )); then
      echo "var_dd: requires bash 4+ (associative arrays); have ${BASH_VERSION}" >&2
      return 1
   fi

   # Default to PATH if no arg given.
   local -a vars=("${@:-PATH}")

   local var orig new entry first
   for var in "${vars[@]}"; do
      # Snapshot the value via indirect expansion. ${!var} returns "" for
      # unset, which is fine -- the loop body emits "" and we exit cleanly.
      orig="${!var-}"
      if [[ -z "$orig" ]]; then
         continue
      fi

      local -A seen=()
      new=""
      first=1

      # IFS=':' read into array is the cleanest split for this. -r prevents
      # backslash mangling; -a fills the array.
      local -a parts=()
      IFS=':' read -r -a parts <<<"$orig"

      for entry in "${parts[@]}"; do
         # Drop empty (leading/trailing/double colons).
         [[ -z "$entry" ]] && continue
         # Drop dup.
         if [[ -n "${seen[$entry]+set}" ]]; then
            continue
         fi
         seen[$entry]=1
         if (( first )); then
            new="$entry"
            first=0
         else
            new+=":$entry"
         fi
      done

      # Re-assign, preserving export status if it was exported.
      if declare -p "$var" 2>/dev/null | grep -q '^declare -x'; then
         export "$var=$new"
      else
         printf -v "$var" '%s' "$new"
      fi

      unset seen
   done
}
