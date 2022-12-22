#!/bin/bash
PREFIX=$HOME/tryout
PREFIX=$HOME/.local

AUTOCONF=autoconf-2.69
CURL=curl-7.47.1
GIT=2.6.4

mkdir -p $PREFIX
# clean
rm -rf curl-* v2.*

# wget+untar
wget http://ftp.gnu.org/gnu/autoconf/$AUTOCONF.tar.gz --no-check-certificate
tar -xvf $AUTOCONF.tar.gz
wget https://curl.haxx.se/download/$CURL.tar.gz --no-check-certificate
tar -xf $CURL.tar.gz
git clone https://github.com/libexpat/libexpat
cd libexpat
git checkout tags/R_2_4_7
cd ..
wget https://github.com/git/git/archive/v$GIT.tar.gz --no-check-certificate
tar -xf v$GIT.tar.gz

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
