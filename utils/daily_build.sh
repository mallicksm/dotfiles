#!/usr/bin/env bash
#===============================================================================
# Bash Script
# Created: Apr-19-2023
# Author: soummya
#
# Note:
#
# Description: Description
#
#===============================================================================
# crontab -e
# 0 2 */2 * * /users/soummya/dotfiles/utils/daily_build.sh
source ~/dotfiles/utils/bash_snippets.sh 2>/dev/null
cd /opt/si/emu/users/soummya/jtag_compile/lpc_a0/rtl/top/qc
bsub -I aeva compile
mv emu-soummya* past_comiles/
