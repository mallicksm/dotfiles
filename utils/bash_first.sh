#!/usr/bin/env bash
# shellcheck shell=bash
#===============================================================================
# bash_first.sh -- foundation layer for ~/dotfiles bash setup.
#
# This file MUST be sourced before any other bash_*.sh in ~/dotfiles/utils/.
# Loader contract:
#   ~/dotfiles/bash_functions.sh    -- sources this first, then alphabetical loop.
#   ~/dotfiles/dotfiles.sh          -- sources this for its own helper output.
#   ~/dotfiles/utils/bash_snippets.sh -- sources this at top for back-compat
#                                       so anything that still only sources
#                                       bash_snippets still gets the fundamentals.
#
# Contents (all "fundamental" -- consumed at source-time by other utils or by
# dotfiles.sh as it dispatches install/link actions):
#
#   * tput color constants    (BOLD/RED/GREEN/.../NO_COLOR)
#   * pretty-print helpers    (info / warn / error / completed / print / printne)
#   * print_sequence          (colored binary-nibble dump; used by `num`)
#   * has                     (command existence check)
#   * Pushd / Popd            (silent pushd/popd)
#   * download                (curl/wget/fetch dispatcher)
#   * modpath                 (idempotent prepend/append/delete on PATH-style vars)
#   * var                     (colon-var inspector; paired with var_dd in bash_utils.sh)
#
# Everything else (xpushd/xpopd, tempfile, timestamp, wget4me, latest_file,
# ifont, xvim, duration, build_*) is non-fundamental and lives
# in bash_snippets.sh.
#
# Guard: sourcing this file multiple times is harmless (function redefinition).
#
# _shellcheck waiver rationale (top-of-file):
#   SC2034 -- color constants are intentionally part of the public API of this
#             file even when not referenced internally (callers use $RED etc).
#   SC2086 -- modpath's parameter-expansion-based path edits require unquoted
#             expansions; explicit waivers at the per-line level there.
#===============================================================================

# --- tput color constants ------------------------------------------------------
# Probed once; cached for the life of the shell. `2>/dev/null || printf ''` so
# we fall back to "no escape code" on dumb terminals instead of leaking literal
# tput errors into prompts.
#
# These are intentionally exported-style public constants -- callers from
# bash_snippets.sh (print_sequence) and other utils read $RED / $BLUE / etc.
# Hence SC2034 (assigned but not used) is silenced for the whole block.
# shellcheck disable=SC2034
{
   BOLD="$(tput bold 2>/dev/null || printf '')"
   BLACK="$(tput setaf 240 2>/dev/null || printf '')"
   UNDERLINE="$(tput smul 2>/dev/null || printf '')"
   RED="$(tput setaf 1 2>/dev/null || printf '')"
   GREEN="$(tput setaf 2 2>/dev/null || printf '')"
   YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
   BLUE="$(tput setaf 4 2>/dev/null || printf '')"
   MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
   CYAN="$(tput setaf 6 2>/dev/null || printf '')"
   WHITE="$(tput setaf 7 2>/dev/null || printf '')"
   GRAY="$(tput setaf 8 2>/dev/null || printf '')"
   NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"
}
export BAT_THEME=gruvbox-dark

# --- pretty-print helpers ------------------------------------------------------
# printne COLOR_NAME  text...  : print text colored, NO trailing newline.
# print   COLOR_NAME  text...  : same, WITH trailing newline.
# Color is passed by NAME (BOLD/RED/...), looked up via indirect expansion.
# Note: %s used so user text is treated as data (immune to embedded %).
printne() {
   local color="$1"
   shift
   printf '%s%s%s' "${!color}" "$*" "$NO_COLOR"
}
print() {
   local color="$1"
   shift
   printf '%s%s%s\n' "${!color}" "$*" "$NO_COLOR"
}
# info / warn / error / completed : the four standard prompt prefixes used
# throughout dotfiles.sh and other utility scripts.
info() {
   printf '%s\n' "${BOLD}${WHITE}> $*${NO_COLOR}"
}
warn() {
   printf '%s\n' "${YELLOW}! $*${NO_COLOR}"
}
error() {
   printf '%s\n' "${RED}x $*${NO_COLOR}" >&2
}
completed() {
   printf '%s\n' "${GREEN}✓ $*${NO_COLOR}"
}

# print_sequence BIN_STR [GROUP=4] : print a binary string in alternating
# red/blue nibble-wide groups (visual debug of bit fields). Lives here (not in
# bash_snippets.sh) because it's consumed by a per-shell command -- `num` in
# bash_num.sh -- and bash_snippets is intentionally NOT sourced by the per-shell
# loader. Keeping it in the foundation makes `num` work on non-corp boxes too.
print_sequence() {
   local binary_sequence="$1"
   local group_size="${2:-4}"
   local padded_sequence color color1="$RED" color2="$BLUE" digit i

   # Left-pad with zeros to a whole multiple of group_size.
   if (( ${#binary_sequence} % group_size != 0 )); then
      padded_sequence=$(printf "%0$((group_size - ${#binary_sequence} % group_size))d%s" 0 "$binary_sequence")
   else
      padded_sequence=$binary_sequence
   fi

   for (( i = 0; i < ${#padded_sequence}; i++ )); do
      digit="${padded_sequence:i:1}"
      if (( i % (group_size * 2) < group_size )); then color="$color1"; else color="$color2"; fi
      echo -ne "${color}${digit}${NO_COLOR}"
   done
   echo
}

# --- shell utility primitives --------------------------------------------------
# has CMD : succeeds iff CMD is an executable on PATH (or a builtin/function).
has() {
   command -v "$1" 1>/dev/null 2>&1
}
# Silent pushd/popd: same semantics, but swallow the "stack" listing output.
Pushd() {
   command pushd "$@" >/dev/null 2>&1
}
Popd() {
   command popd >/dev/null 2>&1
}
# download URL : fetches URL to ./$(basename URL) via curl, wget, or fetch
# (whichever is on PATH). Returns the underlying tool's exit code; logs the
# failing command on error.
download() {
   local url="$1"
   local file="${url##*/}"
   local cmd rc

   if has curl; then
      cmd="curl --fail --silent --location --output $file $url"
   elif has wget; then
      cmd="wget --quiet --output-document=$file $url"
   elif has fetch; then
      cmd="fetch --quiet --output=$file $url"
   else
      error "No HTTP download program (curl, wget, fetch) found, exiting…"
      return 1
   fi

   # `$cmd` is built from internal constants + URL; intentional word-split
   # turns it into argv. The alternative (eval) is worse.
   # shellcheck disable=SC2086
   if $cmd; then
      return 0
   fi
   rc=$?
   error "Command failed (exit code $rc): ${BLUE}${cmd}${NO_COLOR}"
   return "$rc"
}

# --- PATH / colon-var manipulation --------------------------------------------
# var [VAR]       : show a colon-separated var, one entry per line. Defaults
#                   to PATH. Paired with var_dd in bash_utils.sh.
var() {
   local varname="${1:-PATH}"
   local value="${!varname-}"
   # tr is more portable than echo -e for "\n" interpretation, and avoids
   # the "echo -e in /bin/sh" portability footgun.
   printf '%s\n' "$value" | tr ':' '\n'
}

# modpath LOC OP [VAR] : modify LOC in VAR (default PATH).
#                   OP=d (delete), b (prepend / before), a (append / after).
#                   Idempotent on repeat: existing copies of LOC anywhere in
#                   the var are stripped before re-insertion at the requested
#                   end. Safe to call from bash_*.sh source-time, which is why
#                   it lives in bash_first.sh.
#
# Implementation notes / shellcheck rationale:
#   - We use parameter expansion (${PATHv/#"$loc:"} etc.) so the OP-specific
#     branches reduce to two string assigns; no awk/sed/eval fork.
#   - `eval` is used ONCE to read the named var. We could use the indirect
#     expansion ${!var} instead but the legacy semantics here are stable.
#   - Per-line waivers below cover the legitimate unquoted-expansion uses
#     that ${} parameter expansion semantics require.
modpath() {
   local loc="$1"
   local cmd="${2:-d}"
   local var="${3:-PATH}"
   local PATHv NEW_PATH
   # Read the named var indirectly. The `-` default makes unset == empty.
   PATHv="${!var-}"
   NEW_PATH="${PATHv/#"$loc:"/}"          # Beginning
   NEW_PATH="${NEW_PATH/#"$loc"/}"        # Solo
   NEW_PATH="${NEW_PATH/%":$loc"/}"       # Ending
   NEW_PATH="${NEW_PATH//":$loc:"/:}"     # Multiple middles

   case "$cmd" in
      d)
         # delete
         export "$var=$NEW_PATH"
         ;;
      b)
         # prepend / before
         if [[ -z "$NEW_PATH" ]]; then
            export "$var=$loc"
         else
            export "$var=$loc:$NEW_PATH"
         fi
         ;;
      a)
         # append / after
         if [[ -z "$NEW_PATH" ]]; then
            export "$var=$loc"
         else
            export "$var=$NEW_PATH:$loc"
         fi
         ;;
      *)
         printf 'usage: modpath [location] [d elete|b efore|a fter] [VARIABLE]\n' >&2
         return 2
         ;;
   esac
}
