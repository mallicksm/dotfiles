#!/usr/bin/env bash
#===============================================================================
# Bash Script
# Created: May-18-2023
# Author: soummya
#
# Note:
#
# Description: basic functions for shell
#
#===============================================================================
# Loader contract / ORDER INVARIANT:
#   1. bash_first.sh is sourced FIRST -- it's the foundation layer (modpath,
#      has, info/warn/error, printne, print_sequence, download, Pushd/Popd,
#      colors). Several utils call these at their own SOURCE-TIME (bash_fzf,
#      bash_node, bash_utils all call `modpath` at top level), so it must exist
#      before the sweep.
#   2. Everything else is sourced in alphabetical order. This is safe *only*
#      because all cross-file dependencies among the remaining utils are
#      RUNTIME (inside function bodies), never source-time. If you ever add a
#      file with a source-time dependency on another util, list it in
#      $_sm_util_priority below so it loads before the alphabetical sweep --
#      do NOT rely on filename ordering.
# Skipped by the sweep:
#   - bash_first.sh    (already sourced above)
#   - bash_snippets.sh (domain-specific; sourced on demand by standalone
#                       scripts like daily_build.sh, not per-shell)
source ~/dotfiles/utils/bash_first.sh

# Optional explicit-priority list (files to load before the alphabetical sweep).
# Empty today -- see invariant #2 above. Add bare filenames, e.g. "bash_foo.sh".
_sm_util_priority=()

# Names already handled (leading/trailing spaces so the case-glob match is exact).
_sm_loaded=" bash_first.sh bash_snippets.sh "
for _f in "${_sm_util_priority[@]}"; do
   [[ -r ~/dotfiles/utils/$_f ]] || continue
   source ~/dotfiles/utils/"$_f"
   _sm_loaded+="$_f "
done

# Alphabetical sweep via glob (no `ls` word-splitting). nullglob keeps the loop
# from running once with a literal pattern if the dir is ever empty.
shopt -s nullglob
for _f in ~/dotfiles/utils/bash_*.sh; do
   case "$_sm_loaded" in *" ${_f##*/} "*) continue ;; esac
   source "$_f"
done
shopt -u nullglob
unset _f _sm_util_priority _sm_loaded
#-------------------------------------------------------------------------------
# Functions
#===============================================================================

