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

if false ;then
   https://github.com/neovim/neovim/releases
   wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
   chmod u+x nvim.appimage && mv ./nvim.appimage $HOME/.local/bin/nvim
else
   wget4me "tar" https://github.com/neovim/neovim-releases/releases/download/nightly/nvim-linux64.tar.gz
   echo "Note: cp nvim to .local/bin"
fi
