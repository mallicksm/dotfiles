#!/usr/bin/env bash
#===============================================================================
# refresh.sh — bootstrap or update PdfCraft: clone, build, install
#
# Fetches github.com/storytold/pdfcraft, checks out the newest release tag (or a
# ref you name), rebuilds pdfcraft + pdfcraft-cli in release mode, and installs
# them into ~/.local/bin, keeping the previous binaries as .bak files.
#
# Works from scratch: drop this script in an empty directory and run it with -e,
# and it creates the checkout there before building.
#
# Spec: ~/pdfcraft/refresh.md
#===============================================================================
set -uo pipefail

#-------------------------------------------------------------------------------
# Config / defaults
#-------------------------------------------------------------------------------
prog="${0##*/}"

DEST="${PDFCRAFT_DEST:-$HOME/.local/bin}"
REPO_URL="${PDFCRAFT_URL:-https://github.com/storytold/pdfcraft.git}"
FALLBACK_SRC="$HOME/pdfcraft"
BINS=(pdfcraft pdfcraft-cli)

# Resolve through symlinks so a symlink on $PATH still finds the real checkout.
SELF="${BASH_SOURCE[0]}"
command -v realpath >/dev/null 2>&1 && SELF="$(realpath "$SELF" 2>/dev/null || echo "$SELF")"
SELF_DIR="$(cd -- "$(dirname -- "$SELF")" 2>/dev/null && pwd)"

# Where to work when -s / $PDFCRAFT_SRC say nothing. The script's own directory
# is used only when that is actually sensible -- a PdfCraft checkout, or a bare
# directory holding nothing but this script. Anything else (a copy sitting on
# $PATH, or dropped into an unrelated repo) falls back to $FALLBACK_SRC rather
# than treating someone else's directory as the build tree.
default_src() {
   local d="$SELF_DIR" url
   [[ -n "$d" ]] || { echo "$FALLBACK_SRC"; return; }

   if [[ -d "$d/.git" ]]; then
      url="$(git -C "$d" remote get-url origin 2>/dev/null)"
      [[ "$url" == *pdfcraft* ]] && { echo "$d"; return; }
      echo "$FALLBACK_SRC"; return
   fi

   if [[ -z "$(ls -A "$d" 2>/dev/null | grep -vx -e "$prog" -e "${prog%.sh}.md")" ]]; then
      echo "$d"; return
   fi
   echo "$FALLBACK_SRC"
}
SRC="${PDFCRAFT_SRC:-$(default_src)}"

VALID_JOBS=(check clone fetch checkout models build install verify)
JOBS=()                    # empty => all of VALID_JOBS, in order

REF=""                     # empty => newest release tag (highest vN.N.N)
DRY_RUN=1                  # -e/--execute flips this
DO_MODELS=1                # --no-models skips the OCR model fetch
DO_INSTALL=1               # -n/--no-install builds without installing

STAMP="$(date +%Y-%m-%d_%H%M%S)"
FORENSICS="/tmp/${prog%.sh}.$STAMP.forensics"
RESULTS=()

#-------------------------------------------------------------------------------
# usage / die
#-------------------------------------------------------------------------------
usage() {
   cat <<EOF
Usage: $prog [-e] [-j JOB...] [-s DIR] [-r REF] [-n] [--no-models]

Bootstrap or update a PdfCraft checkout, rebuild it, and install the binaries.

Prints what it would do and exits; pass -e to actually run it.

Runnable from any directory. With no -s it works in this script's own directory
when that is a PdfCraft checkout or holds nothing but $prog, and
otherwise in $FALLBACK_SRC. Resolved for this run: $SRC

Options:
  -e, --execute       actually clone/build/install (default: dry run)
  -j, --jobs JOB...   run only these jobs, in the order listed below
                      (default: all of them)
  -s, --src DIR       checkout to create or update (default: this script's dir)
  -r, --ref REF       tag or branch to build (default: newest release tag)
      --main          shorthand for -r origin/main (development tip)
      --url URL       upstream repository (default: $REPO_URL)
  -n, --no-install    build only; leave \$DEST untouched
      --no-models     skip 'cargo xtask models' (Scan & OCR lose their models)
  -h, --help          show this help and exit

Environment:
  \$PDFCRAFT_SRC       source checkout  (default: this script's directory)
  \$PDFCRAFT_DEST      install dir      (default: \$HOME/.local/bin)
  \$PDFCRAFT_URL       upstream repo URL

Jobs, in order:
  check     ask the remote what tags/branches exist (read-only, no clone needed)
  clone     create the checkout if absent (git init + remote add; no-op if present)
  fetch     git fetch --all --prune --tags
  checkout  detach at the target ref (refuses to run on a dirty tree)
  models    cargo xtask models        -> assets/models/
  build     cargo build --release -p pdfcraft -p pdfcraft-cli
  install   back up \$DEST/<bin> as <bin>-<oldver>.bak, copy the new ones in
  verify    run the installed pdfcraft-cli --version

Jobs run in the order shown above regardless of the order you list them, and a
FAIL stops the run. Each is independently runnable: 'install' uses whatever is
already in target/release, 'verify' just reads the installed binary.

Examples:
  $prog                      # preview a refresh to the newest release tag
  $prog -e                   # do it
  $prog -j check             # just ask the remote what is available
  $prog -e -j install verify # install an already-built target/release
  $prog -e -j build          # rebuild in place, install nothing
  $prog -e --main            # build the development tip instead
  $prog -e -r v0.8.0         # pin to a specific tag
  $prog -e -n                # rebuild but don't touch ~/.local/bin

From scratch:
  mkdir -p ~/pc && cp $prog ~/pc/ && ~/pc/$prog -e
  $prog -e -s ~/pc           # same thing, naming the directory instead
EOF
}

die() { echo "$prog: error: $*" >&2; echo >&2; usage >&2; exit 2; }

warn() { echo "$prog: warning: $*" >&2; }

#-------------------------------------------------------------------------------
# Result tracking + the step choke point
#-------------------------------------------------------------------------------
record() { RESULTS+=("$1|$2|$3"); }     # key|status|detail

# step <dir> <logfile> <cmd...> -- prints the exact argv in dry-run, runs the
# identical argv otherwise, appending output to <logfile>.
step() {
   local dir="$1" log="$2"; shift 2
   if (( DRY_RUN )); then
      local a out=""
      for a in "$@"; do out+="${out:+ }$(printf '%q' "$a")"; done
      printf '    cd %q && %s\n' "$dir" "$out"
      return 0
   fi
   mkdir -p "${log%/*}"
   ( cd "$dir" && "$@" ) >>"$log" 2>&1
}

print_summary() {
   local w=3 r key status detail
   for r in "${RESULTS[@]+"${RESULTS[@]}"}"; do
      key="${r%%|*}"
      (( ${#key} > w )) && w=${#key}
   done
   echo
   echo "Summary ($( (( DRY_RUN )) && echo 'dry run' || echo 'executed' )):"
   local ok=0 wrn=0 bad=0
   for r in "${RESULTS[@]+"${RESULTS[@]}"}"; do
      key="${r%%|*}"; r="${r#*|}"
      status="${r%%|*}"; detail="${r#*|}"
      printf '  %-*s  %-4s  %s\n' "$w" "$key" "$status" "$detail"
      case "$status" in
         OK)   ((ok++))  ;;
         WARN) ((wrn++)) ;;
         *)    ((bad++)) ;;
      esac
   done
   printf '  %d OK, %d WARN, %d FAIL\n' "$ok" "$wrn" "$bad"
   (( DRY_RUN == 0 )) && echo "  logs: $FORENSICS"
   return $(( bad > 0 ))
}

#-------------------------------------------------------------------------------
# Helpers
#-------------------------------------------------------------------------------
in_list() {
   local needle="$1"; shift
   local item
   for item in "$@"; do
      [[ "$item" == "$needle" ]] && return 0
   done
   return 1
}

# The checkout's origin if there is one, else the configured upstream -- so the
# remote can be queried before anything has been cloned.
remote_url() {
   local u=""
   [[ -d "$SRC/.git" ]] && u="$(git -C "$SRC" remote get-url origin 2>/dev/null)"
   echo "${u:-$REPO_URL}"
}

# Release tags the remote advertises, oldest first. Needs no local clone.
remote_tags() {
   git ls-remote --refs --tags "$(remote_url)" 'v*' 2>/dev/null \
      | awk '{print $2}' | sed 's#refs/tags/##' | sort -V
}

# Newest release tag by version order, e.g. v0.8.0. Falls back to asking the
# remote when there are no local tags yet (fresh or not-yet-created checkout).
newest_tag() {
   local t=""
   [[ -d "$SRC/.git" ]] && t="$(git -C "$SRC" tag --sort=-v:refname 2>/dev/null | head -1)"
   [[ -z "$t" ]] && t="$(remote_tags | tail -1)"
   echo "$t"
}

# Version of the currently installed CLI, for naming the .bak files.
old_version() {
   local cli="$DEST/pdfcraft-cli" v=""
   if [[ -x "$cli" ]]; then
      v="$("$cli" --version 2>/dev/null | head -1 | awk '{print $2}')"
   fi
   echo "${v:-$STAMP}"
}

# Highest GLIBC_x.y symbol a binary needs, vs what this host provides.
glibc_check() {
   local bin="$1" need host
   command -v objdump >/dev/null 2>&1 || { echo "skipped"; return 0; }
   need="$(objdump -T "$bin" 2>/dev/null | grep -o 'GLIBC_[0-9.]*' \
           | sed 's/GLIBC_//' | sort -uV | tail -1)"
   host="$(ldd --version 2>/dev/null | head -1 | awk '{print $NF}')"
   [[ -z "$need" || -z "$host" ]] && { echo "skipped"; return 0; }
   if [[ "$(printf '%s\n%s\n' "$need" "$host" | sort -V | tail -1)" == "$host" ]]; then
      echo "needs glibc $need, host has $host"
      return 0
   fi
   echo "needs glibc $need but host has $host"
   return 2
}

#-------------------------------------------------------------------------------
# Jobs
#-------------------------------------------------------------------------------
# Read-only, so it runs in dry mode too -- it answers "is there anything newer?"
# straight from the remote, without fetching or touching the working tree.
job_check() {
   echo "==> check"
   local url tags newest_r newest_l installed
   url="$(remote_url)"
   echo "    remote: $url"
   printf '    git ls-remote --refs --tags %q %q\n' "$url" 'v*'

   tags="$(remote_tags)"
   if [[ -z "$tags" ]]; then
      record check WARN "could not reach $url (offline?)"
      return 0
   fi

   newest_r="$(echo "$tags" | tail -1)"
   newest_l=""
   [[ -d "$SRC/.git" ]] && newest_l="$(git -C "$SRC" tag --sort=-v:refname 2>/dev/null | head -1)"
   installed="$(old_version)"

   echo "    tags upstream  : $(echo "$tags" | tail -4 | tr '\n' ' ')"
   echo "    newest upstream: $newest_r"
   echo "    newest local   : ${newest_l:-<no checkout yet>}"
   echo "    installed      : $installed"
   # Upstream keeps ~20 short-lived feature branches; only the long-lived ones
   # are meaningful as build targets, so summarize the rest as a count.
   local heads n
   heads="$(git ls-remote --refs --heads "$url" 2>/dev/null)"
   n="$(echo "$heads" | grep -c . )"
   echo "    branches       : $n total; buildable ones:"
   echo "$heads" | awk '$2 ~ /refs\/heads\/(main|release|master|develop)$/ {
      sub("refs/heads/","",$2); printf "      %-10s %s\n", $2, substr($1,1,8) }'

   if [[ "v$installed" == "$newest_r" ]]; then
      record check OK "up to date; newest upstream tag is $newest_r"
   else
      record check WARN "newer upstream: $newest_r (installed $installed)"
   fi
}

# Bootstrap. Uses init + remote add rather than 'git clone' because the target
# directory normally already holds this script, and git clone refuses to write
# into a non-empty directory. The fetch and checkout jobs then fill it in.
job_clone() {
   echo "==> clone"
   if [[ -d "$SRC/.git" ]]; then
      record clone OK "already a checkout: $SRC"
      return 0
   fi

   # Anything other than this script and its spec means we'd be colonizing
   # someone else's directory; refuse rather than scatter a repo into it.
   if [[ -d "$SRC" ]]; then
      local stray
      stray="$(ls -A "$SRC" 2>/dev/null | grep -vx -e "$prog" -e "${prog%.sh}.md" | head -3)"
      if [[ -n "$stray" ]]; then
         record clone FAIL "$SRC is neither empty nor a checkout (e.g. $(echo "$stray" | tr '\n' ' '))"
         return 1
      fi
   fi

   step / "$FORENSICS/clone.log" mkdir -p "$SRC" \
      || { record clone FAIL "could not create $SRC"; return 1; }
   step "$SRC" "$FORENSICS/clone.log" git init -q . \
      || { record clone FAIL "git init failed in $SRC"; return 1; }
   step "$SRC" "$FORENSICS/clone.log" git remote add origin "$REPO_URL" \
      || { record clone FAIL "could not add origin $REPO_URL"; return 1; }
   record clone OK "initialized $SRC with origin $REPO_URL"
}

job_fetch() {
   echo "==> fetch"
   if step "$SRC" "$FORENSICS/fetch.log" git fetch --all --prune --tags; then
      record fetch OK "origin fetched"
   else
      record fetch FAIL "git fetch failed (see log)"
      return 1
   fi
}

job_checkout() {
   echo "==> checkout"
   local dirty
   dirty="$(git -C "$SRC" status --porcelain --untracked-files=no 2>/dev/null \
            | grep -v 'assets/models' | head -5)"
   if [[ -n "$dirty" ]]; then
      record checkout FAIL "working tree has local changes; refusing to checkout"
      return 1
   fi
   local ref="$REF"
   [[ -z "$ref" ]] && ref="$(newest_tag)"
   [[ -z "$ref" ]] && { record checkout FAIL "could not determine a ref to build"; return 1; }
   # In execute mode the fetch above already ran, so an unknown ref is a typo.
   # In dry run nothing was fetched, so it may simply be a brand-new upstream
   # tag -- report it, but don't claim the checkout would succeed.
   local known=1
   git -C "$SRC" rev-parse --verify --quiet "${ref}^{commit}" >/dev/null 2>&1 || known=0

   if step "$SRC" "$FORENSICS/checkout.log" git checkout --detach "$ref"; then
      if (( known )); then
         record checkout OK "detached at $ref"
      else
         record checkout WARN "'$ref' not in the local clone yet; fetch should bring it in"
      fi
   else
      record checkout FAIL "git checkout $ref failed"
      return 1
   fi
}

job_models() {
   echo "==> models"
   if (( DO_MODELS == 0 )); then
      record models WARN "skipped (--no-models); Scan & OCR will have no models"
      return 0
   fi
   if step "$SRC" "$FORENSICS/models.log" cargo xtask models; then
      record models OK "assets/models populated"
   else
      record models WARN "model fetch failed; build continues without OCR models"
   fi
}

job_build() {
   echo "==> build (this is the slow part)"
   if step "$SRC" "$FORENSICS/build.log" \
        cargo build --release -p pdfcraft -p pdfcraft-cli; then
      record build OK "target/release/{$(IFS=,; echo "${BINS[*]}")}"
   else
      record build FAIL "cargo build failed (see $FORENSICS/build.log)"
      return 1
   fi
}

job_install() {
   echo "==> install"
   if (( DO_INSTALL == 0 )); then
      record install WARN "skipped (-n); binaries left in $SRC/target/release"
      return 0
   fi
   # A running GUI blocks a real install, but must not abort a preview -- the
   # whole point of the dry run is to show every remaining command.
   local running=0
   if pgrep -x pdfcraft >/dev/null 2>&1; then
      if (( DRY_RUN )); then
         running=1
      else
         record install FAIL "pdfcraft is running; quit it first"
         return 1
      fi
   fi

   local b msg rc=0
   # Sanity-check before overwriting: an official release build would need a
   # newer glibc than this host, so confirm our own build does not.
   for b in "${BINS[@]}"; do
      if (( DRY_RUN == 0 )); then
         msg="$(glibc_check "$SRC/target/release/$b")" || rc=2
         [[ "$msg" == "skipped" ]] || echo "    $b: $msg"
      fi
   done
   if (( rc == 2 )); then
      record install FAIL "built binary needs a newer glibc than this host"
      return 1
   fi

   step / "$FORENSICS/install.log" mkdir -p "$DEST" \
      || { record install FAIL "could not create $DEST"; return 1; }

   local v; v="$(old_version)"
   for b in "${BINS[@]}"; do
      if [[ -f "$DEST/$b" ]]; then
         step "$DEST" "$FORENSICS/install.log" mv "$b" "$b-$v.bak" \
            || { record install FAIL "could not back up $b"; return 1; }
      fi
      step "$SRC" "$FORENSICS/install.log" cp "target/release/$b" "$DEST/$b" \
         || { record install FAIL "could not install $b"; return 1; }
   done
   if (( running )); then
      record install WARN "pdfcraft is running -- quit it before an -e run"
   else
      record install OK "installed to $DEST (previous kept as *-$v.bak)"
   fi
}

job_verify() {
   echo "==> verify"
   if (( DRY_RUN )); then
      printf '    %q --version\n' "$DEST/pdfcraft-cli"
      record verify OK "would run pdfcraft-cli --version"
      return 0
   fi
   local out
   out="$("$DEST/pdfcraft-cli" --version 2>/dev/null | head -1)"
   if [[ -n "$out" ]]; then
      echo "    $out"
      record verify OK "$out"
   else
      record verify FAIL "installed pdfcraft-cli did not report a version"
      return 1
   fi
}

#-------------------------------------------------------------------------------
# Arg parsing
#-------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
   case "$1" in
      -e|--execute)    DRY_RUN=0; shift ;;
      -j|--jobs)       shift
                       while [[ $# -gt 0 && "$1" != -* ]]; do JOBS+=("$1"); shift; done
                       [[ ${#JOBS[@]} -gt 0 ]] || die "--jobs requires at least one job name" ;;
      -s|--src)        [[ $# -ge 2 ]] || die "$1 requires a DIR"
                       SRC="$2"; shift 2 ;;
      -r|--ref)        [[ $# -ge 2 ]] || die "$1 requires a REF"
                       REF="$2"; shift 2 ;;
      --main)          REF="origin/main"; shift ;;
      --url)           [[ $# -ge 2 ]] || die "$1 requires a URL"
                       REPO_URL="$2"; shift 2 ;;
      -n|--no-install) DO_INSTALL=0; shift ;;
      --no-models)     DO_MODELS=0; shift ;;
      -h|--help)       usage; exit 0 ;;
      *)               die "unknown option: $1" ;;
   esac
done

#-------------------------------------------------------------------------------
# Validation
#-------------------------------------------------------------------------------
command -v cargo >/dev/null 2>&1 || die "cargo not on PATH"
command -v git   >/dev/null 2>&1 || die "git not on PATH"

for j in "${JOBS[@]+"${JOBS[@]}"}"; do
   in_list "$j" "${VALID_JOBS[@]}" || die "unknown job: $j (valid: ${VALID_JOBS[*]})"
done
# Normalize to canonical order so dependent jobs can't run out of sequence.
if [[ ${#JOBS[@]} -gt 0 ]]; then
   SELECTED=()
   for j in "${VALID_JOBS[@]}"; do
      in_list "$j" "${JOBS[@]}" && SELECTED+=("$j")
   done
   JOBS=("${SELECTED[@]}")
else
   JOBS=("${VALID_JOBS[@]}")
fi

# An existing checkout is only required for jobs that read the tree; the clone
# job is what creates it, so don't demand one when it is selected.
if ! in_list clone "${JOBS[@]}"; then
   [[ -d "$SRC/.git" ]] || die "not a git checkout: $SRC (run with the 'clone' job, or set -s)"
fi
if in_list build "${JOBS[@]}" && [[ -d "$SRC/.git" && ! -f "$SRC/Cargo.toml" ]]; then
   warn "no Cargo.toml in $SRC yet; the checkout job should supply it"
fi
if in_list install "${JOBS[@]}" && (( DO_INSTALL )); then
   [[ -e "$DEST" && ! -d "$DEST" ]] && die "install dir is not a directory: $DEST"
   [[ -d "$DEST" && ! -w "$DEST" ]] && die "install dir not writable: $DEST"
fi

#-------------------------------------------------------------------------------
# Run
#-------------------------------------------------------------------------------
echo "$prog: src=$SRC dest=$DEST ref=${REF:-newest release tag} jobs=${JOBS[*]}"
if (( DRY_RUN )); then
   echo "$prog: DRY RUN -- showing commands only; add -e to execute"
else
   mkdir -p "$FORENSICS"
   { echo "$prog $*"; echo "src=$SRC"; echo "dest=$DEST"; echo "ref=${REF:-newest tag}";
     echo "jobs=${JOBS[*]}"; echo "date=$STAMP"; } > "$FORENSICS/invocation.txt"
fi
echo

for j in "${JOBS[@]}"; do
   "job_$j" || { print_summary; exit 1; }
done

if (( DRY_RUN )); then
   print_summary
else
   print_summary | tee "$FORENSICS/summary.txt"
   exit "${PIPESTATUS[0]}"
fi
