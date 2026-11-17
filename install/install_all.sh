#!/usr/bin/env bash
#===============================================================================
# install_all.sh -- orchestrator for ~/dotfiles/install/<tool>_local_install.sh
#
# Runs the per-tool installers in a sensible order: quick prebuilt binaries
# first, RPM-extracted and app-style installs next, slow from-source builds
# last, then the Python CLI tools. Each installer runs in its own process; a
# failure is logged and the run CONTINUES, with a summary at the end.
#
# Every installer is dry-run by default and so is this, so a bare run is a
# safe preview of the whole set. -e is forwarded to each installer and is what
# actually installs anything.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
here="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$here/lib.sh"

prog="${0##*/}"
ARGV_ORIG=("$@")

#-------------------------------------------------------------------------------
# Config
#-------------------------------------------------------------------------------
# group -> ordered tool list. The tool name is the <tool> in
# <tool>_local_install.sh, so there is no second place to keep in sync.
# NB: must NOT be named GROUPS -- that is a bash builtin array (your gid list).
declare -A TOOL_GROUPS=(
   [modern]="ripgrep fd bat delta eza procs lazygit"
   [prebuilt]="starship zellij patchelf pandoc verible nvim fzf node z clang_format fonts"
   [rpm]="xclip w3m x11apps"
   [app]="kitty ollama magick clang"
   [source]="git gettext verilator riscvgcc"
   [pip]="pip"
)
GROUP_ORDER=(modern prebuilt rpm app source pip)

# Groups skipped unless asked for by name. 'source' is hours of compiling and
# 'app' pulls multi-hundred-megabyte trees; neither belongs in a bare run.
SLOW_GROUPS=(app source)

DRY_RUN=1
FORCE=0
WANT_GROUPS=()
WANT_TOOLS=()
JOBS=()
STAMP="$(date +%Y-%m-%d_%H%M%S)"
FORENSICS="/tmp/dotfiles-install_all.$STAMP.forensics"
RESULTS=()

#-------------------------------------------------------------------------------
# usage / die
#-------------------------------------------------------------------------------
usage() {
   cat <<EOF
Usage: $prog [-e] [-g GROUP...] [-j JOB...] [-f] [-a] [-h] [TOOL...]

Run every ~/dotfiles/install/<tool>_local_install.sh, in dependency order.

Prints what each installer would do and exits; pass -e to actually run them.

Options:
  -e, --execute     actually install (default: dry run); forwarded to each tool
  -g, --group G...  only these groups (default: all but ${SLOW_GROUPS[*]})
  -j, --jobs J...   forwarded to each installer, e.g. -j check
  -f, --force       forwarded to each installer: reinstall even if current
  -a, --all         include the slow groups (${SLOW_GROUPS[*]}) in a default run
  -l, --list        list the groups and their tools, then exit
  -h, --help        show this help and exit

Groups, in run order:
$(for g in "${GROUP_ORDER[@]}"; do
     printf '  %-9s %s%s\n' "$g" "${TOOL_GROUPS[$g]}" \
        "$(printf '%s\n' "${SLOW_GROUPS[@]}" | grep -qx "$g" && echo '   [slow: opt in with -g or -a]')"
  done)

A bare TOOL argument runs just that installer, e.g. '$prog -e starship zellij'.
Versions are per-tool via each installer's own env var or -r; see
'<tool>_local_install.sh -h'.

Examples:
  $prog                     # preview everything that is not slow
  $prog -e                  # install it
  $prog -j check            # just report installed vs upstream, for every tool
  $prog -e -g modern        # only the single-binary modern-unix tools
  $prog -e starship zellij  # two named tools
  $prog -e -a               # everything including the from-source builds

Logs (on -e): $FORENSICS/<tool>.log
Spec: ~/dotfiles/install/recipe.md
EOF
}

die() { echo "$prog: error: $*" >&2; echo >&2; usage >&2; exit 2; }

record() { RESULTS+=("$1|$2|$3"); }

in_list() {
   local needle="$1"; shift
   local item
   for item in "$@"; do [[ "$item" == "$needle" ]] && return 0; done
   return 1
}

script_for() { printf '%s/%s_local_install.sh' "$here" "$1"; }

#-------------------------------------------------------------------------------
# Arg parsing
#-------------------------------------------------------------------------------
include_slow=0
while [[ $# -gt 0 ]]; do
   case "$1" in
      -e|--execute) DRY_RUN=0; shift ;;
      -f|--force)   FORCE=1; shift ;;
      -a|--all)     include_slow=1; shift ;;
      -g|--group)   shift
                    while [[ $# -gt 0 && "$1" != -* ]]; do WANT_GROUPS+=("$1"); shift; done
                    [[ ${#WANT_GROUPS[@]} -gt 0 ]] || die "--group requires a group name" ;;
      -j|--jobs)    shift
                    while [[ $# -gt 0 && "$1" != -* ]]; do JOBS+=("$1"); shift; done
                    [[ ${#JOBS[@]} -gt 0 ]] || die "--jobs requires a job name" ;;
      -l|--list)    for g in "${GROUP_ORDER[@]}"; do
                       printf '\n[%s]\n' "$g"
                       for t in ${TOOL_GROUPS[$g]}; do printf '  %-14s %s\n' "$t" "$(script_for "$t")"; done
                    done
                    exit 0 ;;
      -h|--help)    usage; exit 0 ;;
      --)           shift; WANT_TOOLS+=("$@"); break ;;
      -*)           die "unknown option: $1" ;;
      *)            WANT_TOOLS+=("$1"); shift ;;
   esac
done

#-------------------------------------------------------------------------------
# Selection
#-------------------------------------------------------------------------------
for g in "${WANT_GROUPS[@]+"${WANT_GROUPS[@]}"}"; do
   [[ -n "${TOOL_GROUPS[$g]:-}" ]] || die "unknown group: $g (valid: ${GROUP_ORDER[*]})"
done

SELECTED=()
if (( ${#WANT_TOOLS[@]} )); then
   # Named tools run in the order the groups declare them, not the order typed,
   # so dependencies between them still hold.
   for t in "${WANT_TOOLS[@]}"; do
      [[ -x "$(script_for "$t")" ]] || die "no installer for '$t' (try $prog --list)"
   done
   for g in "${GROUP_ORDER[@]}"; do
      for t in ${TOOL_GROUPS[$g]}; do
         in_list "$t" "${WANT_TOOLS[@]}" && SELECTED+=("$t")
      done
   done
   # A tool with a script but no group membership still gets to run.
   for t in "${WANT_TOOLS[@]}"; do
      in_list "$t" "${SELECTED[@]+"${SELECTED[@]}"}" || SELECTED+=("$t")
   done
else
   for g in "${GROUP_ORDER[@]}"; do
      if (( ${#WANT_GROUPS[@]} )); then
         in_list "$g" "${WANT_GROUPS[@]}" || continue
      elif (( include_slow == 0 )) && in_list "$g" "${SLOW_GROUPS[@]}"; then
         continue
      fi
      for t in ${TOOL_GROUPS[$g]}; do SELECTED+=("$t"); done
   done
fi

(( ${#SELECTED[@]} )) || die "nothing selected"

missing=()
for t in "${SELECTED[@]}"; do [[ -x "$(script_for "$t")" ]] || missing+=("$t"); done
(( ${#missing[@]} )) && die "missing or non-executable installers: ${missing[*]}"

#-------------------------------------------------------------------------------
# Run
#-------------------------------------------------------------------------------
FWD=()
(( DRY_RUN == 0 )) && FWD+=(-e)
(( FORCE ))        && FWD+=(-f)
(( ${#JOBS[@]} ))  && FWD+=(-j "${JOBS[@]}")

echo "$prog: ${#SELECTED[@]} installer(s): ${SELECTED[*]}"
if (( DRY_RUN )); then
   echo "$prog: DRY RUN -- each installer previews only; add -e to execute"
else
   mkdir -p "$FORENSICS"
   { echo "$prog ${ARGV_ORIG[*]+${ARGV_ORIG[*]}}"; echo "tools=${SELECTED[*]}"; echo "date=$STAMP"; } \
      > "$FORENSICS/invocation.txt"
fi
echo

for t in "${SELECTED[@]}"; do
   printf '%s\n' "================================================================================"
   info "$t"
   if (( DRY_RUN )); then
      # Let the preview land on the terminal; that is the entire output.
      if "$(script_for "$t")" "${FWD[@]+"${FWD[@]}"}"; then
         record "$t" OK "preview clean"
      else
         record "$t" FAIL "preview reported a problem"
      fi
   else
      log="$FORENSICS/$t.log"
      if "$(script_for "$t")" "${FWD[@]}" > >(tee "$log") 2>&1; then
         record "$t" OK "installed"
      else
         record "$t" FAIL "see $log"
      fi
   fi
done

#-------------------------------------------------------------------------------
# Summary
#-------------------------------------------------------------------------------
w=4
for r in "${RESULTS[@]}"; do k="${r%%|*}"; (( ${#k} > w )) && w=${#k}; done
echo
printf '%s\n' "================================================================================"
echo "Summary -- $( (( DRY_RUN )) && echo 'dry run' || echo 'executed' ):"
ok=0; bad=0
for r in "${RESULTS[@]}"; do
   k="${r%%|*}"; r="${r#*|}"; s="${r%%|*}"; d="${r#*|}"
   printf '  %-*s  %-4s  %s\n' "$w" "$k" "$s" "$d"
   if [[ "$s" == OK ]]; then ((ok++)); else ((bad++)); fi
done
printf '  %d OK, %d FAIL\n' "$ok" "$bad"
(( DRY_RUN == 0 )) && echo "  logs: $FORENSICS"
exit $(( bad > 0 ))
# vim: ts=3 sts=3 sw=3 et
