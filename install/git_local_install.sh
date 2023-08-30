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
AUTOCONF=autoconf-2.69
CURL=curl-7.47.1
GIT=2.39.0
#===============================================================================

mkdir -p $PREFIX
#https://github.com/git/git/archive/refs/tags/v2.39.0.tar.gz
# wget+untar
wget4me "tar" http://ftp.gnu.org/gnu/autoconf/$AUTOCONF.tar.gz
wget4me "tar" https://curl.haxx.se/download/$CURL.tar.gz
wget4me "tar" https://github.com/git/git/archive/refs/tags/v$GIT.tar.gz
if [[ ! -d "libexpat" ]]; then
   echo "Info: gitcloneing libexpat"
   git clone https://github.com/libexpat/libexpat > libexpat.git.log 2>&1
   cd libexpat
      git checkout tags/R_2_4_7 >> libexpat.git.log 2>&1
   cd ..
fi

# compile exec
cd $AUTOCONF
./configure --prefix=$PREFIX
make && make install
cd ..

export PATH=$PREFIX/bin:$PATH
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

cd $CURL
./configure --prefix=$PREFIX
make && make install
cd ..

cd libexpat
./configure --prefix=$PREFIX
make && make install
cd ..

cd git-$GIT
make configure
./configure --prefix=$PREFIX --with-curl=$PREFIX --with-expat=$PREFIX
make && make install
cd ..

# manpages
git clone http://git.kernel.org/pub/scm/git/git-manpages.git
mkdir -p $PREFIX/share/man/man1/ && cp -r git-manpages/man1/* $PREFIX/share/man/man1/
mkdir -p $PREFIX/share/man/man5/ && cp -r git-manpages/man5/* $PREFIX/share/man/man5/
mkdir -p $PREFIX/share/man/man7/ && cp -r git-manpages/man7/* $PREFIX/share/man/man7/
