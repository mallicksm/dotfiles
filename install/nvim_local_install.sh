#!/usr/bin/env bash
#===============================================================================
# Bash Script
# Created: Jan-02-2024
# Author: soummya
#
# Note:
#
# Description: nvim install
#
#===============================================================================
source ~/dotfiles/utils/bash_snippets.sh 2>/dev/null
# Latest glibc
src=https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
# Unsupported builds for legacy glibc
src=https://github.com/neovim/neovim-releases/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz
dst=~/.local/tools/nvim_$(date +"%b%d_%I%M%P")
command mkdir -pv $dst && command cd $dst && command rm -rf $(pwd)/../nvim_latest && command ln -sf $(pwd) $(pwd)/../nvim_latest
download $src $(basename $src)
tar -xvf $(basename $src) > nvim_tar.log
loc=$(find . -print | grep 'bin/nvim')
echo "alias nvim into $(dirname $dst)/nvim_latest/$loc"
