#!/usr/bin/env bash
# shellcheck shell=bash
#===============================================================================
# install/recipe.sh -- shared engine behind every ~/dotfiles/install/<tool>_local_install.sh
#
# Each tool installer declares what it is (name, upstream repo, binaries, jobs)
# and supplies only the job bodies that are genuinely tool-specific. This file
# supplies everything else, so every installer gets the same surface: -h help,
# dry-run by default, -j job selection, latest-version resolution with a pin
# override, a fail-soft OK/WARN/FAIL summary, and forensic logs.
#
# A tool script is:
#
#     #!/usr/bin/env bash
#     set -uo pipefail
#     source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"
#
#     TOOL=starship
#     TOOL_DESC="cross-shell prompt"
#     TOOL_REPO=starship/starship
#     TOOL_PIN_VAR=STARSHIP_VERSION
#     TOOL_BINS=(starship)
#     TOOL_NEEDS=(curl tar)
#     TOOL_JOBS=(check fetch install verify)
#
#     job_fetch()   { rc_workdir; rc_fetch_extract "...$VER..."; }
#     job_install() { rc_install_bin ./starship; }
#
#     recipe_main "$@"
#
# NOTHING in a job body may touch the filesystem directly -- route every
# mutating command through rc_* / run / run_sh so the dry-run print is
# guaranteed identical to what executes. Read-only inspection is fine, but
# must be guarded with `rc_real` since in dry run the earlier jobs did not
# actually run and the files it would look at do not exist.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================

# lib.sh supplies the install layout ($PREFIX/$BIN/$TOOLSDIR), the GitHub
# "latest release" lookup, and the colored info/warn/error/completed helpers.
# Its sm_* mutating helpers (sm_install_bin, sm_workdir, ...) run immediately,
# so they are deliberately NOT used from job bodies; the rc_* wrappers below
# are the dry-run-aware equivalents.
# shellcheck source=lib.sh
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

#-------------------------------------------------------------------------------
# Config / defaults
#-------------------------------------------------------------------------------
prog="${0##*/}"
RECIPE_ARGV=("$@")

# Canonical job order. A tool lists a subset in TOOL_JOBS; whatever the user
# passes to -j is reordered to match, so dependent jobs cannot run backwards.
RECIPE_JOB_ORDER=(check fetch build install link verify)

# Jobs that change the system. These are the ones skipped when the tool is
# already at the target version, and the ones -n suppresses.
RECIPE_MUTATING=(fetch build install link)

# --- tool declarations (defaults; a tool script overrides what it needs) ------
TOOL=""                      # short name, e.g. starship
TOOL_DESC=""                 # one line, shown in --help
TOOL_REPO=""                 # owner/repo for GitHub release lookup ("" = none)
TOOL_PIN_VAR=""              # env var that pins the version, e.g. STARSHIP_VERSION
TOOL_PIN_DEFAULT=""          # fallback when there is no repo / lookup fails
TOOL_PIN_IS_POLICY=0         # 1 = the default pin is deliberate, not staleness
TOOL_BINS=()                 # binaries this installs into $BIN
TOOL_VERSION_FLAG="--version"
TOOL_NEEDS=()                # prerequisite commands
TOOL_JOBS=(check fetch install verify)
TOOL_ALWAYS=0                # 1 = never skip as "already installed"
TOOL_SKIP_IF_PRESENT=0       # 1 = presence alone is enough to skip (no version to compare)
TOOL_SLOW=0                  # 1 = warn in --help that this is a long build
TOOL_USAGE_EXTRA=""          # extra lines appended to --help
TOOL_ENV_EXTRA=""            # extra env vars listed in --help
TOOL_ARGS_NAME=""            # non-empty => this tool takes positionals, e.g. "FAMILY"
ARGS=()                      # the positionals the user passed

# --- runtime state ------------------------------------------------------------
DRY_RUN=1                    # -e/--execute flips this
FORCE=0                      # -f/--force: reinstall even if current
DO_INSTALL=1                 # -n/--no-install: fetch/build but do not install
VERSION_OPT=""               # -r/--version
JOBS=()
RESULTS=()
VER=""                       # resolved target version (pin, else latest)
W=""                         # scratch work dir, set by rc_workdir
RC_DIR="/"                   # cwd for the next run/rc_* command
LOG=""                       # current job's log file
STAMP="$(date +%Y-%m-%d_%H%M%S)"
FORENSICS=""
SKIP_REASON=""               # non-empty => mutating jobs are skipped

#-------------------------------------------------------------------------------
# usage / die
#-------------------------------------------------------------------------------
usage() {
   local slow="" bins="" env_block="" examples=""

   (( TOOL_SLOW )) && slow="
This is a LONG from-source build; preview it before committing to an -e run."
   (( ${#TOOL_BINS[@]} )) && bins="   (installs: ${TOOL_BINS[*]})"

   if [[ -n "$TOOL_PIN_VAR" ]]; then
      local def="${TOOL_PIN_DEFAULT:-latest}"
      [[ -n "$TOOL_REPO" ]] && (( TOOL_PIN_IS_POLICY == 0 )) && def="newest release of $TOOL_REPO"
      env_block+="$(printf '  $%-14s pin the version (default: %s)\n' "$TOOL_PIN_VAR" "$def")"$'\n'
   fi
   env_block+="$(printf '  $%-14s install root (default: $HOME/.local)\n' LOCAL_PREFIX)"$'\n'
   env_block+="$(printf '  $%-14s raises the GitHub API rate limit for the version lookup\n' GITHUB_TOKEN)"$'\n'
   [[ -n "$TOOL_ENV_EXTRA" ]] && env_block+="$TOOL_ENV_EXTRA"$'\n'

   examples+="  $prog                 # preview, change nothing"$'\n'
   examples+="  $prog -e              # do it"$'\n'
   examples+="  $prog -j check        # just compare installed vs upstream"$'\n'
   examples+="  $prog -e -f           # force a reinstall of the same version"$'\n'
   [[ -n "$TOOL_PIN_VAR" ]] && \
      examples+="  $prog -e -r ${TOOL_PIN_DEFAULT:-1.2.3}   # pin a version (same as \$$TOOL_PIN_VAR)"$'\n'

   cat <<EOF
Usage: $prog [-e] [-j JOB...] [-f] [-r VERSION] [-n] [-h]${TOOL_ARGS_NAME:+ [$TOOL_ARGS_NAME...]}

Install $TOOL${TOOL_DESC:+ -- $TOOL_DESC} under \$HOME/.local, without root.

Prints what it would do and exits; pass -e to actually run it.$slow

Options:
  -e, --execute       actually download/build/install (default: dry run)
  -j, --jobs JOB...   run only these jobs, in the canonical order below
                      (default: ${TOOL_JOBS[*]})
  -f, --force         reinstall even if the target version is already present
  -r, --version VER   install this version instead of the default
  -n, --no-install    fetch/build only; leave \$BIN untouched
  -h, --help          show this help and exit

Jobs, in order:
$(recipe_job_help)

Install layout (override the root with \$LOCAL_PREFIX):
  \$PREFIX    $PREFIX
  \$BIN       $BIN$bins
  \$TOOLSDIR  $TOOLSDIR

Environment:
$env_block
Examples:
$examples${TOOL_USAGE_EXTRA:+
$TOOL_USAGE_EXTRA
}
Driven with -e by ~/dotfiles/dotfiles.sh and ~/dotfiles/install/install_all.sh.
Spec: ~/dotfiles/install/recipe.md
EOF
}

# One help line per job the tool actually has, using the stock descriptions
# unless the tool overrides one via RECIPE_JOB_DESC[<job>].
declare -A RECIPE_JOB_DESC=(
   [check]="compare the installed version against upstream (read-only; runs in dry mode)"
   [fetch]="download and unpack the release into a scratch dir"
   [build]="compile from source"
   [install]="place the binaries into \$BIN"
   [link]="symlink an unpacked tree's bin/* into \$BIN"
   [verify]="run the installed binary and report its version"
)
recipe_job_help() {
   local j
   for j in "${TOOL_JOBS[@]}"; do
      printf '  %-9s %s\n' "$j" "${RECIPE_JOB_DESC[$j]:-(tool-specific)}"
   done
}

die() { echo "$prog: error: $*" >&2; echo >&2; usage >&2; exit 2; }

#-------------------------------------------------------------------------------
# Result tracking + the step choke point
#-------------------------------------------------------------------------------
record() { RESULTS+=("$1|$2|$3"); }      # key|status|detail

# rc_real : true only when commands are really being run. Guard every piece of
# filesystem inspection with it -- in dry run the files are not there.
rc_real() { (( DRY_RUN == 0 )); }

# step <dir> <cmd...> : prints the exact shell-quoted argv in dry run, runs the
# identical argv otherwise with output appended to the current job's log.
# Everything that mutates anything goes through here.
step() {
   local dir="$1"; shift
   if (( DRY_RUN )); then
      local a out=""
      for a in "$@"; do out+="${out:+ }$(printf '%q' "$a")"; done
      printf '    cd %q && %s\n' "$dir" "$out"
      return 0
   fi
   mkdir -p "${LOG%/*}"
   ( CDPATH= cd -- "$dir" && "$@" ) >>"$LOG" 2>&1
}

# rc_dir <path> : set the directory the following run/rc_* calls execute in.
rc_dir() { RC_DIR="$1"; }

# run <cmd...> : the workhorse. Runs argv in $RC_DIR through step.
run() { step "$RC_DIR" "$@"; }

# run_sh '<shell text>' : for the handful of recipes that genuinely need shell
# syntax (pipes into cpio, curl | sh, a heredoc wrapper). Prints the text
# verbatim in dry run and runs it with bash -c otherwise, so the preview is
# still exactly what executes.
run_sh() {
   if (( DRY_RUN )); then
      printf '    cd %q && %s\n' "$RC_DIR" "$1"
      return 0
   fi
   mkdir -p "${LOG%/*}"
   ( CDPATH= cd -- "$RC_DIR" && bash -c "$1" ) >>"$LOG" 2>&1
}

print_summary() {
   local w=3 r key status detail
   for r in "${RESULTS[@]+"${RESULTS[@]}"}"; do
      key="${r%%|*}"
      (( ${#key} > w )) && w=${#key}
   done
   echo
   echo "Summary -- $TOOL ${VER:+$VER }($( (( DRY_RUN )) && echo 'dry run' || echo 'executed' )):"
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
   rc_real && echo "  logs: $FORENSICS"
   return $(( bad > 0 ))
}

#-------------------------------------------------------------------------------
# Helpers for job bodies
#-------------------------------------------------------------------------------
in_list() {
   local needle="$1"; shift
   local item
   for item in "$@"; do [[ "$item" == "$needle" ]] && return 0; done
   return 1
}

# rc_nov <tag> : strip a leading v. Many assets embed the bare number.
rc_nov() { printf '%s' "${1#v}"; }

# rc_workdir [name] : a FRESH scratch dir under $WORKROOT, and cd into it for
# subsequent run/rc_* calls. Sets $W.
rc_workdir() {
   W="$WORKROOT/${1:-$TOOL}"
   step / rm -rf "$W"
   step / mkdir -p "$W"
   rc_dir "$W"
}

rc_mkdir()  { step / mkdir -p "$@"; }
rc_rmrf()   { step / rm -rf "$@"; }

# rc_export NAME=VALUE... : set build environment for every later run/run_sh.
# Exporting (rather than prefixing each command with `env NAME=VALUE`) keeps
# the dry-run transcript readable -- an expanded $PATH is several hundred
# characters and buries the command it decorates. The exports are printed
# once, so the preview still accounts for everything that will be in effect.
rc_export() {
   local kv shown
   for kv in "$@"; do
      if (( DRY_RUN )); then
         # Print "$PATH" rather than the 2000-character expansion of it; the
         # point of the line is the prefix being added, not the inherited tail.
         shown="${kv//"$PATH"/\$PATH}"
         shown="${shown//"${LD_LIBRARY_PATH:-$RANDOM-unset}"/\$LD_LIBRARY_PATH}"
         printf '    export %s\n' "$shown"
      fi
      export "${kv?}"
   done
}

# rc_fetch URL [OUTFILE] : download into $RC_DIR.
rc_fetch() {
   local url="$1" out="${2:-${1##*/}}"
   run curl --fail --silent --show-error --location --output "$out" "$url"
}

# rc_extract FILE : unpack a tar.*/zip archive in $RC_DIR.
rc_extract() {
   case "$1" in
      *.tar.gz | *.tgz)  run tar -xzf "$1" ;;
      *.tar.xz)          run tar -xJf "$1" ;;
      *.tar.bz2)         run tar -xjf "$1" ;;
      *.tar)             run tar -xf  "$1" ;;
      *.zip)             run unzip -q -o "$1" ;;
      *) error "rc_extract: unknown archive type: $1"; return 1 ;;
   esac
}

rc_fetch_extract() {
   local url="$1" file="${2:-${1##*/}}"
   rc_fetch "$url" "$file" && rc_extract "$file"
}

# rc_install_bin SRC [NAME] : copy an executable into $BIN, mode 0755.
rc_install_bin() {
   local src="$1" name="${2:-${1##*/}}"
   run install -m 0755 "$src" "$BIN/$name"
}

# rc_link_bin TARGET NAME : create/replace $BIN/NAME -> TARGET.
rc_link_bin() { step / ln -sfn "$1" "$BIN/$2"; }

# rc_link_tree_bins DIR : symlink every executable in DIR/bin into $BIN.
# The glob needs the files to exist, so in dry run it can only say what it
# would do -- hence the explicit split.
rc_link_tree_bins() {
   local dir="$1" b
   if ! rc_real; then
      printf '    for b in %q/bin/*; do ln -sfn "$b" %q/"${b##*/}"; done\n' "$dir" "$BIN"
      return 0
   fi
   for b in "$dir"/bin/*; do
      [[ -x "$b" && ! -d "$b" ]] || continue
      rc_link_bin "$b" "${b##*/}" || return 1
   done
}

# rc_installed_version : first-line version of the tool as currently installed,
# or "" if it is not installed / cannot say.
rc_installed_version() {
   local b="${TOOL_BINS[0]:-$TOOL}" out
   [[ -x "$BIN/$b" ]] || { printf ''; return; }
   out="$("$BIN/$b" "$TOOL_VERSION_FLAG" 2>&1 | head -1)"
   # Pull the first dotted number out of e.g. "starship 1.23.0" / "git version 2.45.1".
   printf '%s' "$(printf '%s' "$out" | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)"
}

# rc_present : true if every binary this tool installs is already in place.
rc_present() {
   local b
   (( ${#TOOL_BINS[@]} )) || return 1
   for b in "${TOOL_BINS[@]}"; do [[ -x "$BIN/$b" ]] || return 1; done
   return 0
}

# Where $VER came from. "stale" is the dangerous one: the upstream lookup
# failed and we fell back to the built-in default, which may be months old.
# Saying "up to date" off the back of that would be a lie, and silently
# skipping the install because of it would be worse -- GitHub allows 60
# unauthenticated API calls an hour, and install_all.sh makes about 25.
VER_SOURCE="pin"

# rc_resolve_version : decide the version this run targets.
#   -r VERSION  >  $<TOOL>_PIN_VAR  >  newest GitHub release  >  TOOL_PIN_DEFAULT
#
# It ASSIGNS $VER and $VER_SOURCE rather than echoing, because a command
# substitution would run it in a subshell and throw $VER_SOURCE away. Tools
# that override this must assign both too.
rc_resolve_version() {
   local pin=""
   [[ -n "$VERSION_OPT" ]] && { VER="$VERSION_OPT"; VER_SOURCE=opt; return; }
   [[ -n "$TOOL_PIN_VAR" ]] && pin="${!TOOL_PIN_VAR:-}"
   [[ -n "$pin" ]] && { VER="$pin"; VER_SOURCE=pin; return; }
   # A deliberate policy pin (a known-good build whose asset URL is
   # version-specific) wins over "newest"; `check` still reports what is newer.
   (( TOOL_PIN_IS_POLICY )) && { VER="$TOOL_PIN_DEFAULT"; VER_SOURCE=policy; return; }
   if [[ -n "$TOOL_REPO" ]]; then
      local t; t="$(sm_gh_latest "$TOOL_REPO" 2>/dev/null)"
      [[ -n "$t" ]] && { VER="$t"; VER_SOURCE=upstream; return; }
      VER="$TOOL_PIN_DEFAULT"; VER_SOURCE=stale; return
   fi
   VER="$TOOL_PIN_DEFAULT"; VER_SOURCE=pin
}

# The one-line explanation of a failed lookup, for check and the banner.
rc_stale_note() {
   printf 'could not reach the %s release API (rate limit? set $GITHUB_TOKEN); fell back to %s' \
      "${TOOL_REPO:-upstream}" "$TOOL_PIN_DEFAULT"
}

#-------------------------------------------------------------------------------
# Stock jobs (a tool script may override any of them)
#-------------------------------------------------------------------------------
# Read-only, so it runs in dry mode too: it answers "is there anything newer?".
job_check() {
   local installed latest=""
   installed="$(rc_installed_version)"
   [[ -z "$installed" ]] && rc_present && installed="present (version unknown)"

   echo "    target   : ${VER:-<none>}"
   echo "    installed: ${installed:-<not installed>}"
   if [[ -n "$TOOL_REPO" ]]; then
      latest="$(sm_gh_latest "$TOOL_REPO" 2>/dev/null)"
      echo "    upstream : ${latest:-<unreachable>}  ($TOOL_REPO)"
   fi

   if [[ "$VER_SOURCE" == stale ]]; then
      # Do not claim anything about currency -- we never learned what current is.
      record check WARN "$(rc_stale_note); installed ${installed:-nothing}"
   elif [[ -z "$installed" ]]; then
      record check WARN "not installed yet; would install ${VER:-latest}"
   elif [[ -n "$VER" && "$(rc_nov "$VER")" == "$(rc_nov "$installed")" ]]; then
      record check OK "up to date at $installed"
   elif [[ -n "$latest" && -n "$VER" && "$(rc_nov "$latest")" != "$(rc_nov "$VER")" ]]; then
      record check WARN "pinned to $VER; upstream has $latest (installed $installed)"
   else
      record check WARN "installed $installed; would install ${VER:-latest}"
   fi
}

# For tools pinned to a fixed URL (a distro RPM, a rolling AppImage): there is
# no upstream version to compare against, so "is it there and what is it?" is
# the whole question. Tools opt in with  job_check() { rc_check_fixed_url; }
rc_check_fixed_url() {
   local b="${TOOL_BINS[0]:-$TOOL}" have=""
   [[ -x "$BIN/$b" ]] && have="$("$BIN/$b" "$TOOL_VERSION_FLAG" 2>&1 | head -1)"
   echo "    source   : $RC_FIXED_URL"
   echo "    installed: ${have:-<not installed>}"
   if [[ -n "$have" ]]; then
      # w3m's version line runs to 200 characters of build options; keep the
      # summary table readable.
      (( ${#have} > 60 )) && have="${have:0:57}..."
      record check OK "present ($have); -f refreshes from the same URL"
   else
      record check WARN "not installed yet"
   fi
}
RC_FIXED_URL=""              # set by tools that use rc_check_fixed_url

job_verify() {
   local b out any=0
   for b in "${TOOL_BINS[@]}"; do
      if (( DRY_RUN )); then
         printf '    %q %s\n' "$BIN/$b" "$TOOL_VERSION_FLAG"
         continue
      fi
      if [[ ! -x "$BIN/$b" ]]; then
         record verify FAIL "$b not installed in $BIN"
         return 1
      fi
      out="$("$BIN/$b" "$TOOL_VERSION_FLAG" 2>&1 | head -1)"
      echo "    $out"
      any=1
   done
   if (( DRY_RUN )); then
      record verify OK "would run ${TOOL_BINS[*]} $TOOL_VERSION_FLAG"
   elif (( any )); then
      record verify OK "$out"
   else
      record verify WARN "nothing to verify"
   fi
}

#-------------------------------------------------------------------------------
# Driver
#-------------------------------------------------------------------------------
recipe_parse() {
   while [[ $# -gt 0 ]]; do
      case "$1" in
         -e|--execute)    DRY_RUN=0; shift ;;
         -j|--jobs)       shift
                          while [[ $# -gt 0 && "$1" != -* ]]; do JOBS+=("$1"); shift; done
                          [[ ${#JOBS[@]} -gt 0 ]] || die "--jobs requires at least one job name" ;;
         -f|--force)      FORCE=1; shift ;;
         -r|--version)    [[ $# -ge 2 ]] || die "$1 requires a VERSION"
                          VERSION_OPT="$2"; shift 2 ;;
         -n|--no-install) DO_INSTALL=0; shift ;;
         -h|--help)       usage; exit 0 ;;
         --)              shift; ARGS+=("$@"); break ;;
         -*)              die "unknown option: $1" ;;
         *)               [[ -n "$TOOL_ARGS_NAME" ]] \
                             || die "$TOOL takes no positional arguments (got '$1')"
                          ARGS+=("$1"); shift ;;
      esac
   done
   [[ -n "$TOOL_ARGS_NAME" ]] || return 0
   # -j greedily eats the non-flag tokens after it, so a trailing positional
   # would be mistaken for a job name. '--' is the escape hatch.
   local a
   for a in "${ARGS[@]+"${ARGS[@]}"}"; do
      in_list "$a" "${RECIPE_JOB_ORDER[@]}" \
         && die "'$a' is both a job name and a $TOOL_ARGS_NAME; separate them with -- "
   done
}

recipe_validate() {
   local j
   for j in "${JOBS[@]+"${JOBS[@]}"}"; do
      in_list "$j" "${TOOL_JOBS[@]}" \
         || die "unknown job for $TOOL: $j (valid: ${TOOL_JOBS[*]})"
   done
   # Reorder the selection into canonical order so e.g. `-j install fetch`
   # still fetches first.
   if [[ ${#JOBS[@]} -gt 0 ]]; then
      local sel=()
      for j in "${RECIPE_JOB_ORDER[@]}"; do
         in_list "$j" "${TOOL_JOBS[@]}" && in_list "$j" "${JOBS[@]}" && sel+=("$j")
      done
      JOBS=("${sel[@]}")
   else
      JOBS=("${TOOL_JOBS[@]}")
   fi

   # Prerequisites only matter for jobs that actually do work; `check` alone
   # must stay runnable on a box missing the build tools.
   local needs_work=0
   for j in "${JOBS[@]}"; do in_list "$j" "${RECIPE_MUTATING[@]}" && needs_work=1; done
   if (( needs_work )) && (( ${#TOOL_NEEDS[@]} )); then
      local missing=() c
      for c in "${TOOL_NEEDS[@]}"; do has "$c" || missing+=("$c"); done
      (( ${#missing[@]} )) && die "missing prerequisites: ${missing[*]}"
   fi

   if (( DO_INSTALL )) && in_list install "${JOBS[@]}"; then
      [[ -e "$BIN" && ! -d "$BIN" ]] && die "install dir is not a directory: $BIN"
      [[ -d "$BIN" && ! -w "$BIN" ]] && die "install dir not writable: $BIN"
   fi
}

# Decide up front whether the mutating jobs have anything to do, so the run
# short-circuits instead of re-downloading something already at the right
# version. -f always overrides; TOOL_ALWAYS=1 opts a tool out entirely.
recipe_skip_check() {
   SKIP_REASON=""
   (( FORCE )) && return
   (( TOOL_ALWAYS )) && return
   rc_present || return
   local installed; installed="$(rc_installed_version)"
   if [[ -n "$installed" && -n "$VER" && "$(rc_nov "$VER")" == "$(rc_nov "$installed")" ]]; then
      if [[ "$VER_SOURCE" == stale ]]; then
         SKIP_REASON="matches the fallback $VER, but upstream was unreachable"
      else
         SKIP_REASON="already at $installed"
      fi
   elif [[ -z "$installed" ]] && (( TOOL_SKIP_IF_PRESENT )); then
      # Only for tools with no version to read (a sourced script, a checkout).
      # Everywhere else a binary that is present but will not report a version
      # is a BROKEN install -- exactly the case that must be reinstalled, not
      # skipped. (A stale ~/.local/bin/verilator pointing at a deleted tree
      # used to silently skip its own repair here.)
      SKIP_REASON="already present (version unknown)"
   fi
}

recipe_main() {
   [[ -n "$TOOL" ]] || { echo "$prog: recipe.sh: TOOL is not set" >&2; exit 2; }
   recipe_parse "$@"

   rc_resolve_version          # assigns $VER and $VER_SOURCE
   FORENSICS="/tmp/dotfiles-install.$TOOL.$STAMP.forensics"

   recipe_validate
   recipe_skip_check

   echo "$prog: tool=$TOOL version=${VER:-n/a} prefix=$PREFIX jobs=${JOBS[*]}"
   [[ "$VER_SOURCE" == stale ]] && warn "$prog: $(rc_stale_note) -- version unverified"
   if (( DRY_RUN )); then
      echo "$prog: DRY RUN -- showing commands only; add -e to execute"
   else
      mkdir -p "$FORENSICS"
      { echo "$prog ${RECIPE_ARGV[*]+${RECIPE_ARGV[*]}}"; echo "tool=$TOOL";
        echo "version=$VER"; echo "prefix=$PREFIX"; echo "jobs=${JOBS[*]}";
        echo "date=$STAMP"; } > "$FORENSICS/invocation.txt"
   fi
   echo

   local j
   for j in "${JOBS[@]}"; do
      LOG="$FORENSICS/$j.log"
      RC_DIR="${W:-/}"
      if in_list "$j" "${RECIPE_MUTATING[@]}"; then
         if [[ -n "$SKIP_REASON" ]]; then
            record "$j" OK "skipped -- $SKIP_REASON (-f to reinstall)"
            continue
         fi
         if (( DO_INSTALL == 0 )) && [[ "$j" == install || "$j" == link ]]; then
            record "$j" WARN "skipped (-n); nothing written to $BIN"
            continue
         fi
      fi
      # -n left nothing installed, so verifying it would fail by construction.
      if (( DO_INSTALL == 0 )) && [[ "$j" == verify ]]; then
         record verify WARN "skipped (-n); nothing was installed to verify"
         continue
      fi
      echo "==> $j"
      if ! declare -F "job_$j" >/dev/null; then
         record "$j" FAIL "$TOOL declares job '$j' but defines no job_$j"
         print_summary; exit 1
      fi
      # Most job bodies just do their work and let the driver score them; the
      # ones with something more interesting to say call record themselves, so
      # only fill in a default result when the job stayed quiet.
      local before=${#RESULTS[@]}
      if "job_$j"; then
         (( ${#RESULTS[@]} > before )) || record "$j" OK "done"
      else
         (( ${#RESULTS[@]} > before )) || record "$j" FAIL "failed$(rc_real && echo " -- see $LOG")"
         print_summary; exit 1
      fi
   done

   if (( DRY_RUN )); then
      print_summary
   else
      print_summary | tee "$FORENSICS/summary.txt"
      exit "${PIPESTATUS[0]}"
   fi
}
# vim: ts=3 sts=3 sw=3 et
