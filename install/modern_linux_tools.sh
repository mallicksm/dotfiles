#!/usr/bin/env bash
#===============================================================================
# Bash Script
# Created: Dec-22-2022
# Author: soummyam
#
# Note:
#
# Description: Locally installs git
#
#===============================================================================
source ~/dotfiles/utils/bash_snippets.sh 2>/dev/null
#===============================================================================
# Version specs
PREFIX=$HOME/.local
EXA=exa-linux-x86_64-musl-v0.10.1
BAT=bat-v0.22.1-i686-unknown-linux-musl
DELTA=delta-0.15.1-x86_64-unknown-linux-musl
#===============================================================================
idir=/tmp/$USER/modern_linux_tools
rm -rf $idir && mkdir -p $idir
Pushd $idir
download $EXA.zip https://github.com/ogham/exa/releases/download/v0.10.1/$EXA.zip
download $BAT.tar.gz https://github.com/sharkdp/bat/releases/download/v0.22.1/$BAT.tar.gz
download $DELTA.tar.gz https://github.com/dandavison/delta/releases/download/0.15.1/$DELTA.tar.gz
unzip $EXA.zip
tar -xvf $BAT.tar.gz
tar -xvf $DELTA.tar.gz
cp bin/* $PREFIX/bin
cp $BAT/bat $PREFIX/bin
cp $DELTA/delta $PREFIX/bin
