#-------------------------------------------------------------------------------
export RIPGREP_CONFIG_PATH=~/dotfiles/initrc/ripgreprc
# Note: vgrep
function vgrep () {
   declare -A opt
   local args
   while (( $# )); do
      case $1 in
         -i|--ignorecase)
            opt[IGNORECASE]=1
            shift 1
         ;;
         -v|--verilog)
            opt[VERILOG]=1
            shift 1
         ;;
         -r|--rtl)
            opt[RTL]=1
            shift 1
         ;;
         -t|--tcl)
            opt[TCL]=1
            shift 1
         ;;
         -c)
            opt[C_LANG]=1
            shift 1
         ;;
         -h|--header)
            opt[HEADER]=1
            shift 1
         ;;
         -m|--makefile)
            opt[MAKEFILE]=1
            shift 1
         ;;
         --help)
            opt[HELP]=1
            shift 1
         ;;
         -*)
            echo "Attention: Unknown Argument $1" >&2
            return 1
         ;;
         *)
            args+=("$1")
            shift
         ;;
      esac
   done
   if [[ ${opt[HELP]} -eq 1 ]]; then
      echo "Usage: vgrep PATTERN [OPTION]"
      echo "Search for PATTERN recursively in current directory"
      echo "PATTERN is, by default, a basic regular expression."
      echo "Example: vgrep 'hello world' -v"
      echo "Example: vgrep '[hello|world]' -v"
      echo ""
      echo "File selection:"
      echo "-v|--verilog          RTL Files in Verilog and VHDL, .sv .svh and .v "
      echo "-t|--tcl              tcl style files like .tcl .qel"
      echo "-c                    C programming files like .c .S"
      echo "-h|--header           Header files in c and rtl, .h, .svh"
      echo "-m |--makefile        Makefiles like Makefile and .mk"
      return 0
   fi
   ex="--exclude=*svn* --exclude-dir=archive --exclude=tags --exclude-dir=fsdb"
   if [[ $args == "" ]]; then
      echo "Attention: PATTERN not provided" >&2
      echo ""
      vgrep --help
      return 1
   fi
   local v
   ic=""
   if [[ ${opt[IGNORECASE]} -eq 1 ]]; then
      ic="-i"
   fi
   if [[ ${opt[VERILOG]} -eq 1 ]]; then
      v="--include=*.v --include=*.sv --include=*.vhd --include=*.svh"
   fi
   if [[ ${opt[RTL]} -eq 1 ]]; then
      v="--include=*.v --include=*.sv --include=*.vhd --include=*.svh --exclude=postDFT --exclude-dir=guc_libs --exclude-dir=.zfs --exclude-dir=asic_ip"
   fi
   local t
   if [[ ${opt[TCL]} -eq 1 ]]; then
      t="--include=*.tcl --include=*.qel --include=*.fs"
   fi
   local c
   if [[ ${opt[C_LANG]} -eq 1 ]]; then
      c="--include=*.c --include=*.S --include=*.cpp --include=*.h"
   fi
   local h
   if [[ ${opt[HEADER]} -eq 1 ]]; then
      h="--include=*.h --include=*.svh"
   fi
   local m
   if [[ ${opt[MAKEFILE]} -eq 1 ]]; then
      m="--include=*.mk --include=Makefile --include=makefile"
   fi
   str="grep --color=auto $ic "${args[@]}" . -R $v $h $c $t $m $ex"
   echo "Executing: $str"
   command $str
}

#-------------------------------------------------------------------------------
# Note: rgrep -- powerful interactive ripgrep + fzf (replaces vgrep workflow)
#
# Live filter: rg re-runs as you type (no fzf-side fuzzy matching, so the
# results are always accurate ripgrep matches). Filetype filter switches via
# function keys without leaving fzf. Enter opens the chosen line in nvim at
# the matched line number.
#
# Custom type groups defined in ~/dotfiles/initrc/ripgreprc:
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
#                                     microsec speed. F1-F6 reload with new type
#                                     filter + original query.
#   rgrep -t chx struct               ONE-SHOT, restricted to C/C++ files
#   rgrep -t vsv always_ff            ONE-SHOT, verilog+SV files only
#   rgrep -l foo                      LIVE forced (pre-fills "foo" but lets you refine
#                                     interactively -- rg re-runs as you edit query)
#   rgrep --type-list                 dump all available types (rg built-in + custom)
#   rgrep -h                          this help
#
# In-fzf hotkeys (also shown in header):
#   F1   filter to chx (C/C++)        F4  filter to tclqel
#   F2   filter to vsv (V/SV)          F5  filter to mk
#   F3   filter to py                  F6  clear type filter (all files)
#   Enter           open in nvim at matched line
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

__rgrep_open() {
   local item=$1
   if [[ $item =~ ^([^:]+):([0-9]+): ]]; then
      exec vi "${BASH_REMATCH[1]}" +"${BASH_REMATCH[2]}"
   else
      exec vi "$item"
   fi
}
export -f __rgrep_preview __rgrep_open

#-------------------------------------------------------------------------------
function rgrep () {
   local type_arg="" query="" force_live=0

   while (( $# )); do
      case "$1" in
         -l|--live)        force_live=1; shift ;;
         -t|--type)        type_arg+="--type $2 ";     shift 2 ;;
         -T|--type-not)    type_arg+="--type-not $2 "; shift 2 ;;
         --type-list)      rg --type-list | bat --color=always --paging=always; return 0 ;;
         --help|-h)
            sed -n '/^# Note: rgrep/,/^#---/p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
            return 0
            ;;
         -*)
            echo "rgrep: unknown option: $1  (try: rgrep -h)" >&2
            return 1
            ;;
         *)
            query="${query:+$query }$1"
            shift
            ;;
      esac
   done

   local rg_base="rg --line-number --no-heading --color=always --smart-case $type_arg"

   # MODE DECISION:
   #   query empty                -> LIVE  (need typing to search)
   #   query given                -> ONE-SHOT (the search is decided)
   #   query given AND --live     -> LIVE forced
   if [[ -n $query && $force_live -eq 0 ]]; then
      # ----- one-shot mode: rg once, fzf filters its output -----
      # F1-F6 reload rg with new type filter + the ORIGINAL query (not {q},
      # which in one-shot is fzf's local fuzzy filter, not the rg pattern).
      local q_quoted; printf -v q_quoted '%q' "$query"
      eval "$rg_base -- $q_quoted" |
      fzf --ansi \
          --delimiter ':' \
          --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --preview 'bat --color=always {1} --highlight-line {2}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
          --bind "f1:reload:$rg_base --type chx    -- $q_quoted || true" \
          --bind "f2:reload:$rg_base --type vsv    -- $q_quoted || true" \
          --bind "f3:reload:$rg_base --type py     -- $q_quoted || true" \
          --bind "f4:reload:$rg_base --type tclqel -- $q_quoted || true" \
          --bind "f5:reload:$rg_base --type mk     -- $q_quoted || true" \
          --bind "f6:reload:$rg_base                -- $q_quoted || true" \
          --bind 'enter:become(vi {1} +{2})' \
          --bind 'ctrl-/:change-preview-window(down|hidden|)' \
          --color header:italic \
          --header-first \
          --header "ripgrep [one-shot: '$query'${type_arg:+, $type_arg}] | F1=chx F2=vsv F3=py F4=tcl F5=mk F6=all | Enter=open | CTRL-/=preview  (<esc> to quit)"
      return
   fi

   # ----- live mode: file-list when empty, content-grep when typing -----
   # When fzf's query is empty, show a shallow file list (rg --files
   # --max-depth 3). The moment the user types a non-empty query, switch
   # to full content grep (rg --line-number ...). Deleting the query back
   # to empty restores the file list. F1-F6 set a type filter that applies
   # to whichever mode is current.
   local rg_files="$rg_base --files --max-depth 3"
   local rg_grep_debounced="sleep 0.15; $rg_base"

   # Build the toggle command for change:reload and each F-key. {q} is fzf's
   # current query; the bash conditional decides between file-list and grep.
   local change_cmd="if [[ -z {q} ]]; then $rg_files; else $rg_grep_debounced -- {q}; fi || true"
   local f1_cmd="if [[ -z {q} ]]; then $rg_files --type chx;    else $rg_grep_debounced --type chx    -- {q}; fi || true"
   local f2_cmd="if [[ -z {q} ]]; then $rg_files --type vsv;    else $rg_grep_debounced --type vsv    -- {q}; fi || true"
   local f3_cmd="if [[ -z {q} ]]; then $rg_files --type py;     else $rg_grep_debounced --type py     -- {q}; fi || true"
   local f4_cmd="if [[ -z {q} ]]; then $rg_files --type tclqel; else $rg_grep_debounced --type tclqel -- {q}; fi || true"
   local f5_cmd="if [[ -z {q} ]]; then $rg_files --type mk;     else $rg_grep_debounced --type mk     -- {q}; fi || true"
   local f6_cmd="if [[ -z {q} ]]; then $rg_files;               else $rg_grep_debounced               -- {q}; fi || true"

   # Initial display: shallow file list (or pre-grep result if -l was used).
   local _initial_cmd
   if [[ -n $query ]]; then
      _initial_cmd="$rg_base -- $query"
   else
      _initial_cmd="$rg_files"
   fi
   FZF_DEFAULT_COMMAND="$_initial_cmd" \
   fzf --ansi \
       --disabled \
       --query "$query" \
       --color "hl:-1:underline,hl+:-1:underline:reverse" \
       --preview '__rgrep_preview {}' \
       --preview-window 'up,60%,border-bottom' \
       --bind "change:reload:$change_cmd" \
       --bind "f1:reload:$f1_cmd" \
       --bind "f2:reload:$f2_cmd" \
       --bind "f3:reload:$f3_cmd" \
       --bind "f4:reload:$f4_cmd" \
       --bind "f5:reload:$f5_cmd" \
       --bind "f6:reload:$f6_cmd" \
       --bind 'enter:become(__rgrep_open {})' \
       --bind 'ctrl-/:change-preview-window(down|hidden|)' \
       --color header:italic \
       --header-first \
       --header 'ripgrep [live: shallow files | type to grep | F1=chx F2=vsv F3=py F4=tcl F5=mk F6=all | Enter=open | CTRL-/=preview]  (<esc> to quit)'
}
