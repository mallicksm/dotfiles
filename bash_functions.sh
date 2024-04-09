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
for file in $(command ls ~/dotfiles/utils/bash_*.sh); do
   if [[ $file =~ "bash_snippets.sh" ]]; then 
      continue
   fi
   source $file
done
#-------------------------------------------------------------------------------
# Functions
#===============================================================================

