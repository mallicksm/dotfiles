#!/usr/bin/env bash
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
#   * has                     (command existence check)
#   * Pushd / Popd            (silent pushd/popd)
#   * download                (curl/wget/fetch dispatcher)
#   * modpath                 (idempotent prepend/append/delete on PATH-style vars)
#   * var                     (colon-var inspector; paired with var_dd in bash_utils.sh)
#
# Everything else (xpushd/xpopd, tempfile, timestamp, wget4me, latest_file,
# ifont, xvim, duration, print_sequence, build_*) is non-fundamental and lives
# in bash_snippets.sh.
#
# Guard: sourcing this file multiple times is harmless (function redefinition).
#===============================================================================

# --- tput color constants ------------------------------------------------------
# Probed once; cached for the life of the shell. `2>/dev/null || printf ''` so
# we fall back to "no escape code" on dumb terminals instead of leaking literal
# tput errors into prompts.
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
export BAT_THEME=gruvbox-dark

# --- pretty-print helpers ------------------------------------------------------
# printne COLOR_VAR  string  : print string colored, NO trailing newline.
# print   COLOR_VAR  string  : same, WITH trailing newline.
# Color is passed by NAME (BOLD/RED/...), looked up via indirect expansion.
function printne() {
   color=$1
   str="${@:2}"
   printf "${!color}$str$NO_COLOR"
}
function print() {
   color=$1
   str="${@:2}"
   printf "${!color}$str$NO_COLOR\n"
}
# info / warn / error / completed : the four standard prompt prefixes used
# throughout dotfiles.sh and other utility scripts.
function info() {
   printf '%s\n' "$BOLD$WHITE> $@$NO_COLOR"
}
function warn() {
   printf '%s\n' "$YELLOW! $@$NO_COLOR"
}
function error() {
   printf '%s\n' "${RED}x $@$NO_COLOR" >&2
}
function completed() {
   printf '%s\n' "$GREEN✓ $@$NO_COLOR"
}

# --- shell utility primitives --------------------------------------------------
# has CMD : succeeds iff CMD is an executable on PATH (or a builtin/function).
function has() {
   command -v "$1" 1>/dev/null 2>&1
}
# Silent pushd/popd: same semantics, but swallow the "stack" listing output.
function Pushd() {
   command pushd "$@" >/dev/null 2>&1
}
function Popd() {
   command popd >/dev/null 2>&1
}
# download URL : fetches URL to ./$(basename URL) via curl, wget, or fetch
# (whichever is on PATH). Returns the underlying tool's exit code; logs the
# failing command on error.
function download() {
   url="$1"
   file="${url##*/}"

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

   $cmd && return 0 || rc=$?

   error "Command failed (exit code $rc): ${BLUE}${cmd}${NO_COLOR}"
   return $rc
}

# --- PATH / colon-var manipulation --------------------------------------------
# var [VAR]       : show a colon-separated var, one entry per line. Defaults
#                   to PATH. Paired with var_dd in bash_utils.sh.
# modpath LOC OP [VAR] : modify LOC in VAR (default PATH).
#                   OP=d (delete), b (prepend / before), a (append / after).
#                   Idempotent on repeat: existing copies of LOC anywhere in
#                   the var are stripped before re-insertion at the requested
#                   end. Safe to call from bash_*.sh source-time, which is why
#                   it lives in bash_first.sh.
function var () {
   VAR=${1:-PATH}
   DOLLARVAR=${!VAR}
   echo -e ${DOLLARVAR//:/\\n}
}
function modpath () {
   loc=$1
   cmd=${2:-"d"}
   var=${3:-PATH}
   eval PATHv=\$$var    # set PATHv to the var reference (double indirection)
   NEW_PATH=${PATHv/#"$loc:"}         #    Begining
   NEW_PATH=${NEW_PATH/#"$loc"}       #    Solo
   NEW_PATH=${NEW_PATH/%":$loc"}      #    Ending
   NEW_PATH=${NEW_PATH//":$loc:"/:}   #    Multiple middles

   if [ $cmd = "d" ]; then
      export ${var}=$NEW_PATH
   elif [ $cmd = "b" ]; then
      if [ -z $NEW_PATH ]; then
         export ${var}=$loc   # old PATH empty
      else
         export ${var}=$loc:$NEW_PATH
      fi
   elif [ $cmd = "a" ]; then
      if [ -z $NEW_PATH ]; then
         export ${var}=$loc   # old PATH empty
      else
         export ${var}=$NEW_PATH:$loc
      fi
   else
      echo "usage: modpath [location] [d elete|b efore|a fter] [VARIABLE]"
   fi
}
