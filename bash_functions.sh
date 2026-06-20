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
# Source the foundation layer FIRST so subsequent bash_*.sh files can rely on
# modpath, has, info/warn/error, etc. at their own source-time (e.g. bash_fzf.sh,
# bash_node.sh, bash_utils.sh all call `modpath` at top-level).
source ~/dotfiles/utils/bash_first.sh

# Then iterate the rest in alphabetical order. Skip:
#   - bash_first.sh   (already sourced above; re-sourcing is harmless but noisy)
#   - bash_snippets.sh (kept out of the per-shell init; it's a domain-specific
#                      collection sourced explicitly by tools that want it,
#                      e.g. daily_build.sh)
for file in $(command ls ~/dotfiles/utils/bash_*.sh); do
   case "$file" in
      */bash_first.sh|*/bash_snippets.sh) continue ;;
   esac
   source $file
done
#-------------------------------------------------------------------------------
# Functions
#===============================================================================

