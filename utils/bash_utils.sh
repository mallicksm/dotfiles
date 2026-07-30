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

# _zz_which_func_candidates : emit one TAB-delimited row per shell function and
# alias, as "TYPE<TAB>NAME<TAB>LOCATION".
#   - FUNC  rows: LOCATION = file:line, recovered via `shopt -s extdebug`
#     (the ONLY portable way to get a function's defining file -- it makes
#     `declare -F NAME` print "NAME LINE FILE"). extdebug is restored after.
#   - ALIAS rows: LOCATION = the alias expansion (bash keeps no source file
#     for aliases; zz_which_func greps ~/dotfiles for the definition on demand).
# $1 = "1" to include private, underscore-prefixed helpers (default: hide them).
_zz_which_func_candidates() {
   local all="${1:-0}"
   local had_extdebug=0
   shopt -q extdebug && had_extdebug=1
   shopt -s extdebug

   local name info line file
   while read -r name; do
      [[ $all == 0 && $name == _* ]] && continue   # skip private helpers
      info=$(declare -F "$name") || continue
      read -r _ line file <<<"$info"            # "name line file"
      printf 'FUNC\t%s\t%s:%s\n' "$name" "$file" "$line"
   done < <(compgen -A function | sort)

   (( had_extdebug )) || shopt -u extdebug

   local a val
   while read -r a; do
      [[ $all == 0 && $a == _* ]] && continue
      val=$(alias "$a" 2>/dev/null | sed -E "s/^alias [^=]+='//; s/'$//")
      printf 'ALIAS\t%s\t%s\n' "$a" "$val"
   done < <(compgen -A alias | sort)
}

# zz_which_func : "where does this come from?" for shell functions and aliases.
#
# No args  -> fzf picker (like zz_kill / zz_zellij): fuzzy-type the name, the
#             preview shows the definition, Enter opens it in the editor.
# With args-> direct, scriptable lookup (prints file:line, or `type -a` for
#             non-functions). `-e` opens the match in the editor.
#
#   wf                 # pick from function + alias (private _helpers hidden)
#   wf -a              # picker including private, underscore-prefixed helpers
#   wf num             # -> ~/dotfiles/utils/bash_num.sh:1   num
#   wf -e num          # jump straight into the editor at that line
#   wf ll var_dd       # several at once
zz_which_func() {
   local ed
   ed=$(command -v nvim || command -v vim || command -v vi)

   # ---- flag parse: -e (open in editor, direct mode), -a (show all in picker)
   local edit=0 all=0
   while [[ ${1:-} == -* ]]; do
      case $1 in
         -e) edit=1; shift ;;
         -a) all=1;  shift ;;
         --) shift; break ;;
         *)  break ;;
      esac
   done

   # ---- direct / scriptable mode (names given) -------------------------------
   if (( $# )); then
      local had_extdebug=0
      shopt -q extdebug && had_extdebug=1
      shopt -s extdebug
      local name info line file rc=0
      for name in "$@"; do
         info=$(declare -F "$name")
         if [[ -n $info ]]; then
            read -r _ line file <<<"$info"
            printf '%s:%s\t%s\n' "$file" "$line" "$name"
            (( edit )) && [[ -n $ed ]] && "$ed" "+$line" "$file"
         else
            type -a "$name" 2>/dev/null || { printf '%s: not found\n' "$name" >&2; rc=1; }
         fi
      done
      (( had_extdebug )) || shopt -u extdebug
      return $rc
   fi

   # ---- interactive fzf picker (no args) -------------------------------------
   has fzf || { echo "zz_which_func: fzf not found; pass a name instead (wf NAME)" >&2; return 2; }

   local header preview sel typ nm loc
   header='Find a function / alias   |   Enter = open in editor   |   esc = cancel
type to fuzzy-match the name  ·  preview shows the definition'

   # Preview is a stateless file op (location is embedded in each row), so it
   # needs no exported shell state. {1}=TYPE {2}=NAME {3}=LOCATION (tab-split).
   preview='
      typ={1}; nm={2}; loc={3}
      if [ "$typ" = FUNC ]; then
         f="${loc%:*}"; ln="${loc##*:}"
         s=$(( ln > 3 ? ln - 3 : 1 )); e=$(( ln + 45 ))
         if command -v bat >/dev/null 2>&1; then
            bat --style=numbers --color=always --highlight-line="$ln" --line-range "$s:$e" "$f"
         else
            nl -ba "$f" | sed -n "${s},${e}p"
         fi
      else
         printf "alias %s =\n   %s\n\n-- defined in --\n" "$nm" "$loc"
         grep -rn --color=always "alias $nm=" ~/dotfiles 2>/dev/null
      fi'

   sel=$(_zz_which_func_candidates "$all" \
      | fzf --ansi --delimiter='\t' --with-nth=2,3,1 --nth=2 \
            --header="$header" \
            --preview="$preview" --preview-window='right,60%,wrap') || return
   [[ -n $sel ]] || return

   IFS=$'\t' read -r typ nm loc <<<"$sel"
   if [[ $typ == FUNC ]]; then
      local f="${loc%:*}" ln="${loc##*:}"
      printf '%s\t%s\n' "$loc" "$nm"
      [[ -n $ed ]] && "$ed" "+$ln" "$f"
   else
      # Alias: bash keeps no source file, so grep ~/dotfiles for its definition.
      local hit f ln
      hit=$(grep -rn "alias $nm=" ~/dotfiles 2>/dev/null | head -n1)
      if [[ -n $hit ]]; then
         f="${hit%%:*}"; ln=$(printf '%s' "$hit" | cut -d: -f2)
         printf '%s:%s\t%s (alias -> %s)\n' "$f" "$ln" "$nm" "$loc"
         [[ -n $ed ]] && "$ed" "+$ln" "$f"
      else
         printf '%s -> %s   (alias; no definition found under ~/dotfiles)\n' "$nm" "$loc"
      fi
   fi
}
# zz_* : user-facing command namespace (type `zz_<TAB>` to discover them).
# wf kept as a back-compat alias for muscle memory.
alias wf='zz_which_func'
