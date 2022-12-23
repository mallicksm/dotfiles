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
script_loc=$(dirname $0)
source $script_loc/utils.sh 2>/dev/null

#===============================================================================
# Version specs
PREFIX=$HOME/.local
LIBEVENT=libevent-2.1.11-stable
NCURSES=ncurses-6.2
TMUX=tmux-3.1b
#===============================================================================

mkdir -p $PREFIX
wget4me "tar" https://github.com/libevent/libevent/releases/download/release-2.1.11-stable/$LIBEVENT.tar.gz 
wget4me "tar" https://ftp.gnu.org/pub/gnu/ncurses/$NCURSES.tar.gz 
wget4me "tar" https://github.com/tmux/tmux/releases/download/3.1b/$TMUX.tar.gz 

cd $LIBEVENT
./configure --prefix=$PREFIX --disable-shared
make && make install
cd ..

cd $NCURSES
./configure --prefix=$PREFIX
make && make install
cd ..

cd $TMUX
./configure --prefix=$PREFIX\
   CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses" \
   LDFLAGS="-L$PREFIX/lib"
make && make install
cd ..

echo "export PATH=\"$PREFIX/bin:$PATH\""
echo "export LD_LIBRARY_PATH=\"$PREFIX/lib:$LD_LIBRARY_PATH\""
