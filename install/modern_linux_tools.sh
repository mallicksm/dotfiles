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
PROCS=procs-v0.14.3-x86_64-linux
#===============================================================================
idir=/tmp/$USER/modern_linux_tools
rm -rf $idir && mkdir -p $idir
Pushd $idir

download https://github.com/dalance/procs/releases/download/v0.14.3/$PROCS.zip
unzip $PROCS.zip
cp procs $PREFIX/bin

download https://github.com/ogham/exa/releases/download/v0.10.1/$EXA.zip
unzip $EXA.zip
cp bin/* $PREFIX/bin

download https://github.com/sharkdp/bat/releases/download/v0.22.1/$BAT.tar.gz
tar -xvf $BAT.tar.gz
cp $BAT/bat $PREFIX/bin

download https://github.com/dandavison/delta/releases/download/0.15.1/$DELTA.tar.gz
tar -xvf $DELTA.tar.gz
cp $DELTA/delta $PREFIX/bin

FD=fd-v10.3.0-x86_64-unknown-linux-musl
curl -LO https://github.com/sharkdp/fd/releases/download/v10.3.0/$FD.tar.gz
tar xzf $FD.tar.gz
cp $FD/fd $PREFIX/bin

RG=ripgrep-14.1.1-x86_64-unknown-linux-musl
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/$RG.tar.gz
tar xzf $RG.tar.gz
cp $RG/rg $PREFIX/bin

LG=lazygit_0.54.2_Linux_x86_64
curl -LO https://github.com/jesseduffield/lazygit/releases/download/v0.54.2/$LG.tar.gz
tar xzf $LG.tar.gz
install -m 0755 lazygit "$PREFIX/bin/lazygit"
