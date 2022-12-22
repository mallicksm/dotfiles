#!/bin/bash
PREFIX=$HOME/tryout
PREFIX=$HOME/.local
mkdir -p $PREFIX

# clean
rm -rf libevent* ncurses* tmux-*

# download
wget https://github.com/libevent/libevent/releases/download/release-2.1.11-stable/libevent-2.1.11-stable.tar.gz --no-check-certificate
wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.2.tar.gz --no-check-certificate
wget https://github.com/tmux/tmux/releases/download/3.1b/tmux-3.1b.tar.gz --no-check-certificate
# untar
tar zxvf libevent-2.1.11-stable.tar.gz
tar zxvf ncurses-6.2.tar.gz
tar zxvf tmux-3.1b.tar.gz

# libevent #
cd libevent-2.1.11-stable
./configure --prefix=$PREFIX --disable-shared
make && make install
cd ..

# ncurses
cd ncurses-6.2
./configure --prefix=$PREFIX
make && make install
cd ..

# tmux
cd tmux-3.1b
./configure --prefix=$PREFIX\
   CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses" \
   LDFLAGS="-L$PREFIX/lib"
make && make install
cd ..

echo "export PATH=\"$PREFIX/bin:$PATH\""
echo "export LD_LIBRARY_PATH=\"$PREFIX/lib:$LD_LIBRARY_PATH\""
