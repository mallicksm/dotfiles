#!/usr/bin/env bash
#===============================================================================
# fmt.sh — format files the same way Neovim's <leader>cf does, from the CLI.
#
# Mirrors the conform.nvim setup in ~/dotfiles/nvim.*/lua/.../formatting.lua:
# same tools, same flags, same per-extension dispatch. Takes any mix of files
# and directories (recursed), picks the right formatter per extension, and
# edits in place. DRY-RUN by default — pass -e/--execute to actually format.
#
# Spec: ~/dotfiles/utils/fmt.md
#===============================================================================
set -uo pipefail

#-------------------------------------------------------------------------------
# Config / defaults
#-------------------------------------------------------------------------------
FMT_DIR="${FMT_DIR:-$HOME/dotfiles/formatters}"   # clang-format / py-format.toml / semifore.py

prog="${0##*/}"                                    # use $prog in ALL messages

# Vim/conform dispatch is filetype-driven, so we mirror it in two stages:
#   (1) extension|filename -> filetype   (nvim builtins + your after/ftdetect/filetype.lua)
#   (2) filetype           -> formatter  (conform formatters_by_ft)
# Keep these in sync with ~/dotfiles/nvim.*/... if either side changes.

# --- (1a) extension -> filetype ------------------------------------------------
# Custom rows come from ~/dotfiles/nvim.*/after/ftdetect/filetype.lua; the rest
# are the nvim builtins for filetypes that actually have a formatter.
declare -A EXT2FT=(
   # ftdetect (custom)
   [v]=sv [vh]=sv [vp]=sv [sv]=sv [svh]=sv [svp]=sv
   [qel]=tcl [fs]=tcl
   [h]=c
   [csr]=semifore
   [tdf]=tdf [f]=f [scat]=scat [cmm]=trace32 [map]=map [mdc]=markdown [jira]=jira
   # nvim builtins (standard)
   [py]=python [lua]=lua [json]=json
   [c]=c [cc]=cpp [cpp]=cpp [cxx]=cpp [hpp]=cpp [hh]=cpp
   [sh]=sh [bash]=bash [zsh]=zsh [tcl]=tcl
)

# --- (1b) whole filename -> filetype ------------------------------------------
# From after/ftdetect/filetype.lua `filename` table (catches extensionless files).
declare -A FILE2FT=(
   [bash_profile]=sh [bashrc]=sh
   [cshrc]=csh [shellrc]=csh [.shellrc]=csh
)

# --- (2) filetype -> formatter key --------------------------------------------
# Exactly conform's formatters_by_ft. Filetypes not listed here have no
# formatter (tdf/f/scat/trace32/map/markdown/jira/csh) and are skipped as WARN.
declare -A FT2FMT=(
   [sv]=verible
   [c]=clang [cpp]=clang
   [python]=black
   [lua]=stylua
   [json]=prettier
   [sh]=shfmt [bash]=shfmt
   [zsh]=shfmt_zsh
   [tcl]=tcl
   [semifore]=semifore
)

# --- formatter key -> underlying tool binary (for the "is it installed?" check).
declare -A FMT2BIN=(
   [verible]=verible-verilog-format [clang]=clang-format [black]=black
   [stylua]=stylua [prettier]=prettier [shfmt]=shfmt [shfmt_zsh]=shfmt
   [tcl]=tclfmt [semifore]="$FMT_DIR/semifore.py"
)

#-------------------------------------------------------------------------------
# resolve_ft <path>  -> echoes the vim filetype (or "" if none)
#   filename table wins over extension (matches nvim precedence for these).
# resolve_fmt <path> -> echoes the formatter key (or "" if the ft has none)
#-------------------------------------------------------------------------------
resolve_ft() {
   local base ext
   base="$(basename "$1")"
   if [[ -n "${FILE2FT[$base]:-}" ]]; then echo "${FILE2FT[$base]}"; return; fi
   ext="${base##*.}"
   [[ "$base" == "$ext" ]] && { echo ""; return; }   # no extension, no filename match
   ext="${ext,,}"
   echo "${EXT2FT[$ext]:-}"
}

resolve_fmt() {
   local ft; ft="$(resolve_ft "$1")"
   [[ -n "$ft" ]] || { echo ""; return; }
   echo "${FT2FMT[$ft]:-}"
}

usage() {
   cat <<EOF
$prog — format files like Neovim's <leader>cf, from the command line.

Usage:
  $prog [options] <path> [path ...]        # files and/or directories
  $prog -e src/ foo.sv bar.py              # recurse dirs, execute

Options:
  -e, --execute    actually format the files. DEFAULT IS DRY-RUN: without -e,
                   $prog only prints the exact command it would run per file.
  -l, --list       list the extension -> formatter map and exit.
  -h, --help       show this help (also shown when run with no args).

Formatters (same tools/flags as conform.nvim <leader>cf):
  .sv .svh .svp .v .vh .vp   verible-verilog-format (house indent/align)
  .c .h .cc .cpp .cxx .hpp   clang-format  (--style=file:$FMT_DIR/clang-format)
  .py                        black         (--config $FMT_DIR/py-format.toml)
  .lua                       stylua
  .json                      prettier --write
  .sh .bash                  shfmt -i 3 -ci -bn -sr
  .zsh                       shfmt -ln zsh -i 3 -ci -bn -sr
  .tcl .qel .fs              tclfmt
  .csr                       $FMT_DIR/semifore.py

Behavior:
  - Directories are recursed (.git is pruned); only known extensions are picked.
  - A missing formatter tool is a WARN (skipped), not a hard failure.
  - On --execute, per-file logs + summary.txt land under
    /tmp/$prog.<timestamp>.forensics/.

Examples:
  $prog src/                 # dry-run: show what would be formatted under src/
  $prog -e src/ tb/fifo_tb.sv
  $prog -l                   # print the extension -> formatter table
EOF
}

die() { echo "$prog: error: $*" >&2; echo >&2; usage >&2; exit 2; }

#-------------------------------------------------------------------------------
# Result tracking: each entry is "file|status|detail"  (status: OK|WARN|FAIL)
#-------------------------------------------------------------------------------
RESULTS=()
record() { RESULTS+=("$1|$2|${3:-}"); }

#-------------------------------------------------------------------------------
# step  <dir> <argv...>         -- in-place formatters (file named in argv)
# stepf <dir> <file> <argv...>  -- stdin->stdout filters (redirect + atomic mv)
#   Single choke points: the dry-run print is the EXACT argv that executes.
#-------------------------------------------------------------------------------
step() {
   local dir="$1"; shift
   if (( DRY_RUN )); then
      local a out=""
      for a in "$@"; do out+="${out:+ }$(printf '%q' "$a")"; done
      printf '   cd %q && %s\n' "$dir" "$out"
      return 0
   fi
   ( CDPATH= cd "$dir" && "$@" )
}

stepf() {
   local dir="$1" file="$2"; shift 2
   local tmp="$file.fmt.$$"
   if (( DRY_RUN )); then
      local a out=""
      for a in "$@"; do out+="${out:+ }$(printf '%q' "$a")"; done
      printf '   cd %q && %s < %q > %q && mv %q %q\n' "$dir" "$out" "$file" "$tmp" "$tmp" "$file"
      return 0
   fi
   ( CDPATH= cd "$dir" && "$@" < "$file" > "$tmp" && mv "$tmp" "$file" ) || { rm -f "$dir/$tmp" 2>/dev/null; return 1; }
}

#-------------------------------------------------------------------------------
# do_format <file>: dispatch one file to its formatter (via step / stepf).
#   Returns 0=OK, 2=WARN (skipped: unknown ext or tool missing), 1=FAIL.
#-------------------------------------------------------------------------------
do_format() {
   local f="$1"
   local ft fmt
   ft="$(resolve_ft "$f")"
   if [[ -z "$ft" ]]; then echo "no filetype for $(basename "$f")" >&2; return 2; fi
   fmt="${FT2FMT[$ft]:-}"
   [[ -n "$fmt" ]] || { echo "no formatter for filetype '$ft'" >&2; return 2; }

   local bin="${FMT2BIN[$fmt]}"
   if [[ "$bin" == /* ]]; then
      [[ -x "$bin" ]] || { echo "formatter not found: $bin" >&2; return 2; }
   else
      command -v "$bin" >/dev/null 2>&1 || { echo "formatter not on PATH: $bin ($fmt)" >&2; return 2; }
   fi

   local dir base
   dir="$(CDPATH= cd "$(dirname "$f")" && pwd)" || { echo "bad dir for $f" >&2; return 1; }
   base="$(basename "$f")"

   case "$fmt" in
      verible)
         # flags live in the shared flagfile (single source of truth, also used
         # by nvim conform.nvim); edit $FMT_DIR/verible-format.flagfile, not here.
         step "$dir" verible-verilog-format \
            --flagfile="$FMT_DIR/verible-format.flagfile" \
            --inplace "$base" ;;
      clang)
         step "$dir" clang-format --style=file:"$FMT_DIR/clang-format" -i "$base" ;;
      black)
         step "$dir" black --config "$FMT_DIR/py-format.toml" --quiet "$base" ;;
      stylua)
         step "$dir" stylua "$base" ;;
      prettier)
         step "$dir" prettier --write "$base" ;;
      shfmt)
         step "$dir" shfmt -i 3 -ci -bn -sr -w "$base" ;;
      shfmt_zsh)
         step "$dir" shfmt -ln zsh -i 3 -ci -bn -sr -w "$base" ;;
      tcl)
         stepf "$dir" "$base" tclfmt - ;;
      semifore)
         stepf "$dir" "$base" "$FMT_DIR/semifore.py" ;;
      *)
         echo "internal: unhandled formatter '$fmt'" >&2; return 1 ;;
   esac
}

#-------------------------------------------------------------------------------
# Summary (three-state: OK / WARN / FAIL)
#-------------------------------------------------------------------------------
print_summary() {
   local ok=0 warn=0 fail=0 line file status detail w=4 r
   for line in "${RESULTS[@]}"; do r="${line%%|*}"; (( ${#r} > w )) && w=${#r}; done
   echo
   printf '==================== %s summary ====================\n' "$prog"
   printf '%-*s %s\n' "$w" "FILE" "RESULT"
   for line in "${RESULTS[@]}"; do
      IFS='|' read -r file status detail <<<"$line"
      case "$status" in
         OK)   (( ok++ ));   printf '%-*s %s\n' "$w" "$file" "OK${detail:+ ($detail)}" ;;
         WARN) (( warn++ )); printf '%-*s %s\n' "$w" "$file" "WARN${detail:+ ($detail)}" ;;
         *)    (( fail++ )); printf '%-*s %s\n' "$w" "$file" "FAIL${detail:+ ($detail)}" ;;
      esac
   done
   printf -- '----------------------------------------------------------\n'
   printf '%d OK, %d WARN, %d FAIL\n' "$ok" "$warn" "$fail"
   (( fail == 0 ))
}

#-------------------------------------------------------------------------------
# Arg parsing
#-------------------------------------------------------------------------------
PATHS=()
DRY_RUN=1   # dry-run is the default; -e/--execute opts in to running

[[ $# -eq 0 ]] && { usage; exit 0; }

while [[ $# -gt 0 ]]; do
   case "$1" in
      -h|--help)    usage; exit 0 ;;
      -e|--execute) DRY_RUN=0; shift ;;
      -l|--list)
         echo "extension|filename -> filetype -> formatter (mirrors vim <leader>cf):"
         for e in $(printf '%s\n' "${!EXT2FT[@]}" | sort); do
            ft="${EXT2FT[$e]}"; fmt="${FT2FMT[$ft]:-(none)}"
            printf '   .%-6s -> %-10s -> %s\n' "$e" "$ft" "$fmt"
         done
         for n in $(printf '%s\n' "${!FILE2FT[@]}" | sort); do
            ft="${FILE2FT[$n]}"; fmt="${FT2FMT[$ft]:-(none)}"
            printf '   %-7s -> %-10s -> %s\n' "$n" "$ft" "$fmt"
         done
         exit 0 ;;
      --)           shift; while [[ $# -gt 0 ]]; do PATHS+=("$1"); shift; done ;;
      -*)           die "unknown argument: $1" ;;
      *)            PATHS+=("$1"); shift ;;
   esac
done

(( ${#PATHS[@]} > 0 )) || die "no paths given"

#-------------------------------------------------------------------------------
# Discovery: expand dirs (recurse, prune .git) into files with known extensions
#-------------------------------------------------------------------------------
# Build a find expression for every extension AND filename whose filetype has a
# formatter (so extensionless files like `bashrc` are picked up too).
FIND_EXPR=()
add_find() { (( ${#FIND_EXPR[@]} )) && FIND_EXPR+=(-o); FIND_EXPR+=("$@"); }
for e in "${!EXT2FT[@]}"; do
   [[ -n "${FT2FMT[${EXT2FT[$e]}]:-}" ]] && add_find -iname "*.$e"
done
for n in "${!FILE2FT[@]}"; do
   [[ -n "${FT2FMT[${FILE2FT[$n]}]:-}" ]] && add_find -name "$n"
done

FILES=()
for p in "${PATHS[@]}"; do
   if [[ -d "$p" ]]; then
      while IFS= read -r -d '' f; do FILES+=("$f"); done \
         < <(find "$p" -name .git -prune -o -type f \( "${FIND_EXPR[@]}" \) -print0 2>/dev/null)
   elif [[ -f "$p" ]]; then
      FILES+=("$p")
   else
      record "$p" WARN "not a file or directory"
   fi
done

if (( ${#FILES[@]} == 0 )); then
   # Nothing discovered; still print any WARN rows we recorded above.
   if (( ${#RESULTS[@]} )); then print_summary; exit 1; fi
   echo "$prog: nothing to format under: ${PATHS[*]}" >&2
   exit 1
fi

#-------------------------------------------------------------------------------
# Forensics dir (execute mode only)
#-------------------------------------------------------------------------------
FORENSICS_DIR=""
if (( ! DRY_RUN )); then
   FORENSICS_DIR="/tmp/$prog.$(date +%Y-%m-%d_%H%M%S).forensics"
   mkdir -p "$FORENSICS_DIR" || die "could not create forensics dir: $FORENSICS_DIR"
   { echo "$prog ${PATHS[*]}  (execute)"; echo "files: ${#FILES[@]}"; } > "$FORENSICS_DIR/invocation.txt"
fi

#-------------------------------------------------------------------------------
# Run
#-------------------------------------------------------------------------------
if (( DRY_RUN )); then
   echo "[dry-run] $prog ${PATHS[*]}"
   echo "files: ${#FILES[@]}"
else
   echo "forensics: $FORENSICS_DIR"
fi

for f in "${FILES[@]}"; do
   if (( DRY_RUN )); then
      echo "  # $f  [ft=$(resolve_ft "$f"), fmt=$(resolve_fmt "$f")]"
      do_format "$f"
   else
      log="$FORENSICS_DIR/$(echo "$f" | tr '/ ' '__').log"
      do_format "$f" >"$log" 2>&1
      case $? in
         0) record "$f" OK ;;
         2) record "$f" WARN "$(tail -1 "$log" 2>/dev/null)" ;;
         *) record "$f" FAIL "log $log" ;;
      esac
   fi
done

if (( DRY_RUN )); then
   echo
   echo "[dry-run] nothing was changed. Re-run with -e/--execute to format the above."
   exit 0
fi

print_summary | tee "$FORENSICS_DIR/summary.txt"
rc="${PIPESTATUS[0]}"
echo "forensics: $FORENSICS_DIR"
exit "$rc"

# vim: ts=3 sts=3 sw=3 et
