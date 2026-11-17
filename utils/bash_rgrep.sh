#-------------------------------------------------------------------------------
# Note: rgrep -- interactive ripgrep + fzf (replaces the old vgrep workflow)
#
# Live filter: rg re-runs as you type (no fzf-side fuzzy matching, so the
# results are always accurate ripgrep matches). CTRL-T opens a picker to
# restrict which files are searched, without leaving fzf. Enter opens the
# chosen line in nvim at the matched line number.
#
# Named type groups defined in ~/dotfiles/initrc/ripgreprc:
#   chx       *.c, *.h, *.cpp, *.hpp, *.S, *.cc, *.cxx, *.hxx, *.cppm, *.ipp
#   vsv       *.v, *.vh, *.sv, *.svh, *.svp, *.vp, *.vhd, *.vhdl
#   tclqel    *.tcl, *.qel, *.fs
#   mk        *.mk, Makefile, makefile, GNUmakefile, *.gmk
# Plus all rg built-in types (`rg --type-list`).
#
# Usage:
# Mode is auto-picked from whether you pass a query:
#
#   rgrep                             LIVE: empty fzf, type to live-search; rg re-runs
#                                     on every keystroke (debounced 150ms).
#   rgrep foo                         ONE-SHOT (default when query is given): rg runs
#                                     once with "foo", fzf filters its output at
#                                     microsec speed.
#   rgrep -l foo                      LIVE forced (pre-fills "foo" but lets you refine
#                                     interactively -- rg re-runs as you edit query)
#   rgrep --type-list                 dump all available types (rg built-in + custom)
#   rgrep -h                          this help
#
# CTRL-T -- the filter picker (works in both modes, and at any point):
#
#   Opens a second fzf listing every known type, your own ripgreprc groups
#   first. TAB marks as many as you like, Enter applies, ESC changes nothing.
#   Two entries sit at the top: <all files> drops the filter, and <launch
#   filter> returns to whatever you started rgrep with.
#
#   You can also just TYPE extensions into the picker and press Enter without
#   marking anything -- `sv,svh` or `sv svh` restricts to those. Same
#   normalisation as -e below.
#
#   A pick sticks: it survives everything you type afterwards, until the next
#   CTRL-T. The header always names the filter in force.
#
# Restrict from the command line instead -- -e takes one or more, repeat it
# or comma-join:
#
#   rgrep -e sv always_ff             only *.sv
#   rgrep -e sv,svh,v always_ff       only *.sv *.svh *.v
#   rgrep -e sv -e svh always_ff      same thing, repeated flag
#   rgrep --ext=py,pyi def            long form with =
#   rgrep -E md,txt TODO              everything EXCEPT *.md and *.txt
#   rgrep -e sv -E svh foo            *.sv but not *.svh
#
#   A token becomes a glob: `sv` and `.sv` both mean `*.sv`. A token with no
#   dot also matches a file of exactly that name, so `-e Makefile` works. A
#   token that already contains * ? [ or / is used verbatim as a glob, so
#   `-e '*_test.py'` and `-e 'src/**'` do what they look like.
#
# Named type groups on the command line -- -t/-T, repeatable, OR'd together:
#
#   rgrep -t chx struct               C/C++ files
#   rgrep -t vsv -t mk CLK            verilog+SV files OR makefiles
#   rgrep -T lock foo                 skip lockfiles
#
# -e and -t compose; mixing them ORs the two sets.
#
# In-fzf keys:
#   CTRL-T          open the filter picker
#   Enter           open the match with the `vi` wrapper, at that line. fzf
#                   just prints the selection and exits; the edit happens back
#                   in your own shell, so vi()'s env and split/tab logic apply.
#   CTRL-/          cycle preview position (right / down / hidden)
#
# Performance notes:
#   - rg dominates the cost; fzf's contribution is microseconds. On local
#     SSDs rg searches a small tree (~/dotfiles) in ~150ms. On NFS work
#     trees (~/sparews/*) it can be 5-30x slower because of network +
#     stat() costs over many small files.
#   - The `change:reload` binding re-runs rg on every keystroke (with
#     150ms debounce). If you're searching deep NFS trees and find this
#     sluggish: cd into the specific IP subdir first to shrink scope.
#     Or use one-shot mode (the DEFAULT when you give a query on the
#     command line): `rgrep PATTERN`. rg runs once and fzf takes over.
#-------------------------------------------------------------------------------
# The chx / vsv / tclqel / mk groups live in rg's config file, so the picker
# and the -t flag only resolve them if rg can find it.
export RIPGREP_CONFIG_PATH=~/dotfiles/initrc/ripgreprc

#-------------------------------------------------------------------------------
# Helpers for rgrep's dual-format display (file-list mode + content-grep mode).
# rg --line-number output is "path:line:content" -> 3 colon-separated fields.
# rg --files output is just "path"               -> no colon, single field.
# Both formats coexist in the same fzf session because the live mode toggles
# between them based on whether the user has typed anything.

__rgrep_preview() {
   local item=$1
   if [[ $item =~ ^([^:]+):([0-9]+): ]]; then
      bat --color=always "${BASH_REMATCH[1]}" --highlight-line "${BASH_REMATCH[2]}"
   else
      bat --color=always "$item"
   fi
}

# Open what fzf printed. Deliberately NOT exported and deliberately without
# `exec`: this has to run in the caller's interactive shell so the `vi`
# wrapper in bash_nvim.sh applies with its full env and split/tab logic.
# `exec` would skip the function entirely and land on /usr/bin/vi (VIM 8.0),
# and running it inside fzf via become() would get a canned non-interactive
# nvim instead of yours.
__rgrep_edit() {
   local item=$1
   [[ -n $item ]] || return 0
   if [[ $item =~ ^([^:]+):([0-9]+): ]]; then
      vi "${BASH_REMATCH[1]}" +"${BASH_REMATCH[2]}"
   else
      vi "$item"
   fi
}

__rgrep_need() { echo "rgrep: $1 needs a value  (try: rgrep -h)" >&2; }

# Turn -e / -E tokens into globs, one per line. The caller wraps each one in
# its own --type-add, because ripgrep does not split a type spec on commas: a
# single `rgx:*.sv,*.svh` is one glob that matches nothing. Same trap is
# documented in ~/dotfiles/initrc/ripgreprc.
#   sv         -> *.sv and sv   bare word: that extension, or that exact filename
#   .sv        -> *.sv
#   tar.gz     -> *.gz          a dotted token keeps only its last component
#   *_test.py  -> *_test.py     already a glob: verbatim
__rgrep_globs() {
   local tok
   for tok in "$@"; do
      [[ -n $tok ]] || continue
      case "$tok" in
         *[*?\[/]*) printf '%s\n'       "$tok" ;;
         .*)        printf '*%s\n'      "$tok" ;;
         *.*)       printf '*.%s\n'     "${tok##*.}" ;;
         *)         printf '*.%s\n%s\n' "$tok" "$tok" ;;
      esac
   done
}

# The CTRL-T picker. Runs inside the main fzf via execute(), so it owns the
# terminal while it is up and talks to its caller only through files in $1:
#   $1/flags   rg type flags, raw and space-separated -- what the reload reads
#   $1/launch  the filter rgrep was started with, offered as <launch filter>
#   $1/tpl     header text with a %FILTER% placeholder
#   $1/hdr     that template filled in -- what transform-header reads
# ESC leaves every one of them untouched.
__rgrep_pick() {
   local dir=$1
   local out rc query desc="" s name g
   local -a lines=() sels=() flags=() toks=() globs=() mine=()

   # List the groups from ripgreprc first: those are the ones worth picking.
   mapfile -t mine < <(sed -n 's/^\([a-zA-Z0-9_]\{1,\}\):.*/\1/p' "${RIPGREP_CONFIG_PATH:-/dev/null}" 2>/dev/null | sort -u)
   local re=""
   (( ${#mine[@]} )) && { local IFS='|'; re="^(${mine[*]}):"; }

   out=$(
      {
         echo '<all files>'
         [[ -s $dir/launch ]] && echo '<launch filter>'
         if [[ -n $re ]]; then
            rg --type-list 2>/dev/null | grep -E  "$re"
            rg --type-list 2>/dev/null | grep -vE "$re"
         else
            rg --type-list 2>/dev/null
         fi
      } | fzf --multi --print-query --height 60% --border=rounded --reverse \
              --prompt 'restrict to > ' \
              --header 'TAB marks several | or type extensions (sv,svh) and press Enter | ESC cancels'
   )
   rc=$?
   (( rc == 130 )) && return 0          # ESC: leave the current filter alone

   mapfile -t lines <<<"$out"
   query=${lines[0]}
   sels=("${lines[@]:1}")

   if (( ${#sels[@]} )); then
      for s in "${sels[@]}"; do
         case "$s" in
            '<all files>')     : >"$dir/flags"; __rgrep_hdr "$dir" 'all files'; return 0 ;;
            '<launch filter>') cp "$dir/launch" "$dir/flags"
                               __rgrep_hdr "$dir" "$(cat "$dir/launchdesc" 2>/dev/null)"; return 0 ;;
         esac
      done
      for s in "${sels[@]}"; do
         name=${s%%:*}
         flags+=(--type "$name")
         desc+="${desc:+ }$name"
      done
   elif [[ -n $query ]]; then
      IFS=', ' read -r -a toks <<<"$query"
      mapfile -t globs < <(__rgrep_globs "${toks[@]}")
      (( ${#globs[@]} )) || return 0
      for g in "${globs[@]}"; do flags+=(--type-add "rgxp:$g"); done
      flags+=(--type rgxp)
      desc="ext $query"
   else
      return 0                          # nothing marked, nothing typed
   fi

   printf '%s ' "${flags[@]}" >"$dir/flags"
   __rgrep_hdr "$dir" "$desc"
}

# Fill $dir/tpl's %FILTER% placeholder with $2 and park it in $dir/hdr.
__rgrep_hdr() {
   local tpl; tpl=$(cat "$1/tpl" 2>/dev/null)
   printf '%s' "${tpl//%FILTER%/${2:-all files}}" >"$1/hdr"
}

export -f __rgrep_preview __rgrep_globs __rgrep_pick __rgrep_hdr

#-------------------------------------------------------------------------------
function rgrep () {
   local force_live=0 query=""
   local -a t_inc=() t_exc=() ext_inc=() ext_exc=() split=()

   # `-e sv,svh` and `-e sv -e svh` both have to land in the same array, hence
   # the comma split on every extension flag.
   while (( $# )); do
      case "$1" in
         -l|--live)     force_live=1; shift ;;
         --type-list)   rg --type-list | bat --color=always --paging=always; return 0 ;;
         -h|--help)
            sed -n '/^# Note: rgrep/,/^#---/p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
            return 0
            ;;

         -t|--type)     [[ ${2:-} ]] || { __rgrep_need "$1"; return 2; }
                        t_inc+=("$2"); shift 2 ;;
         -T|--type-not) [[ ${2:-} ]] || { __rgrep_need "$1"; return 2; }
                        t_exc+=("$2"); shift 2 ;;
         -e|--ext)      [[ ${2:-} ]] || { __rgrep_need "$1"; return 2; }
                        IFS=',' read -r -a split <<<"$2"; ext_inc+=("${split[@]}"); shift 2 ;;
         -E|--ext-not)  [[ ${2:-} ]] || { __rgrep_need "$1"; return 2; }
                        IFS=',' read -r -a split <<<"$2"; ext_exc+=("${split[@]}"); shift 2 ;;

         --type=*)      t_inc+=("${1#*=}"); shift ;;
         --type-not=*)  t_exc+=("${1#*=}"); shift ;;
         --ext=*)       IFS=',' read -r -a split <<<"${1#*=}"; ext_inc+=("${split[@]}"); shift ;;
         --ext-not=*)   IFS=',' read -r -a split <<<"${1#*=}"; ext_exc+=("${split[@]}"); shift ;;

         --)            shift; query="${query:+$query }$*"; break ;;
         -*)            echo "rgrep: unknown option: $1  (try: rgrep -h)" >&2; return 2 ;;
         *)             query="${query:+$query }$1"; shift ;;
      esac
   done

   # -e/-E become throwaway rg types. One --type-add per glob (see
   # __rgrep_globs), then one --type to select the lot.
   local -a launch=() globs=()
   local n
   for n in "${t_inc[@]}"; do launch+=(--type     "$n"); done
   for n in "${t_exc[@]}"; do launch+=(--type-not "$n"); done
   if (( ${#ext_inc[@]} )); then
      mapfile -t globs < <(__rgrep_globs "${ext_inc[@]}")
      for n in "${globs[@]}"; do launch+=(--type-add "rgx:$n"); done
      (( ${#globs[@]} )) && launch+=(--type rgx)
   fi
   if (( ${#ext_exc[@]} )); then
      mapfile -t globs < <(__rgrep_globs "${ext_exc[@]}")
      for n in "${globs[@]}"; do launch+=(--type-add "rgxn:$n"); done
      (( ${#globs[@]} )) && launch+=(--type-not rgxn)
   fi

   # Human-readable name for that filter, for the header.
   local scope="" s
   local -a sc=()
   (( ${#ext_inc[@]} )) && sc+=("ext ${ext_inc[*]}")
   (( ${#ext_exc[@]} )) && sc+=("no-ext ${ext_exc[*]}")
   (( ${#t_inc[@]}   )) && sc+=("type ${t_inc[*]}")
   (( ${#t_exc[@]}   )) && sc+=("no-type ${t_exc[*]}")
   for s in "${sc[@]}"; do scope+="${scope:+, }$s"; done
   : "${scope:=all files}"

   # Scratch dir shared with the picker. fzf binds are fixed strings, so the
   # active filter has to live outside them -- otherwise the next keystroke
   # would fire change:reload and silently undo the pick.
   local dir
   dir=$(mktemp -d "${TMPDIR:-/tmp}/rgrep.XXXXXXXX") || return 1
   : >"$dir/flags"
   if (( ${#launch[@]} )); then
      printf '%s ' "${launch[@]}" >"$dir/flags"
      cp "$dir/flags" "$dir/launch"
      printf '%s' "$scope" >"$dir/launchdesc"
   fi
   local dq; printf -v dq '%q' "$dir"

   # rg itself carries no type flags: they all come from $dir/flags at run
   # time. `set -f` keeps the shell from expanding the globs inside them on
   # the way to rg.
   local rg_base="rg --line-number --no-heading --color=always --smart-case"
   local rg_files="rg --files --color=always --max-depth 3"
   local read_flags="set -f; tf=\$(cat $dq/flags 2>/dev/null)"
   local hdr="transform-header(cat $dq/hdr 2>/dev/null)"
   local keys='CTRL-T=filter  Enter=open  CTRL-/=preview  (esc quits)'
   local tpl run initial rc

   # MODE DECISION:
   #   query empty                -> LIVE  (need typing to search)
   #   query given                -> ONE-SHOT (the search is decided)
   #   query given AND --live     -> LIVE forced
   if [[ -n $query && $force_live -eq 0 ]]; then
      # ----- one-shot mode: rg once, fzf filters its output -----
      # CTRL-T re-runs rg with the ORIGINAL query, not {q} -- in one-shot {q}
      # is fzf's local fuzzy filter, not the rg pattern.
      tpl="ripgrep [one-shot '$query' | %FILTER%] | $keys"
      printf '%s' "$tpl" >"$dir/tpl"
      printf '%s' "${tpl//%FILTER%/$scope}" >"$dir/hdr"

      local q; printf -v q '%q' "$query"
      run="$read_flags; $rg_base \$tf -- $q || true"

      # The first run needs no quoting games -- call rg directly with arrays.
      # Enter is left at fzf's default (accept), so the match comes back here
      # and gets opened by the caller's shell rather than by fzf's child.
      local sel
      sel=$(
         rg --line-number --no-heading --color=always --smart-case \
            "${launch[@]}" -- "$query" |
         fzf --ansi \
             --delimiter ':' \
             --color "hl:-1:underline,hl+:-1:underline:reverse" \
             --preview 'bat --color=always {1} --highlight-line {2}' \
             --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
             --bind "ctrl-t:execute(__rgrep_pick $dq)+reload($run)+$hdr" \
             --bind 'ctrl-/:change-preview-window(down|hidden|)' \
             --color header:italic \
             --header-first \
             --header "${tpl//%FILTER%/$scope}"
      )
      rc=$?
      rm -rf "$dir"
      (( rc == 0 )) && __rgrep_edit "$sel"
      return $rc
   fi

   # ----- live mode: file-list when empty, content-grep when typing -----
   # When fzf's query is empty, show a shallow file list (rg --files
   # --max-depth 3). The moment the user types a non-empty query, switch to
   # full content grep. Deleting the query back to empty restores the file
   # list. The filter applies to whichever mode is current.
   tpl="ripgrep [live | %FILTER% | type to grep] | $keys"
   printf '%s' "$tpl" >"$dir/tpl"
   printf '%s' "${tpl//%FILTER%/$scope}" >"$dir/hdr"

   run="$read_flags; if [[ -z {q} ]]; then $rg_files \$tf; else sleep 0.15; $rg_base \$tf -- {q}; fi || true"

   # Initial display: shallow file list (or pre-grep result if -l was used).
   initial="$read_flags; $rg_files \$tf"
   [[ -n $query ]] && initial="$read_flags; $rg_base \$tf -- $(printf '%q' "$query")"

   local sel
   sel=$(
      FZF_DEFAULT_COMMAND="$initial" \
      fzf --ansi \
          --disabled \
          --query "$query" \
          --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --preview '__rgrep_preview {}' \
          --preview-window 'up,60%,border-bottom' \
          --bind "ctrl-t:execute(__rgrep_pick $dq)+reload($run)+$hdr" \
          --bind "change:reload:$run" \
          --bind 'ctrl-/:change-preview-window(down|hidden|)' \
          --color header:italic \
          --header-first \
          --header "${tpl//%FILTER%/$scope}"
   )
   rc=$?
   rm -rf "$dir"
   (( rc == 0 )) && __rgrep_edit "$sel"
   return $rc
}
