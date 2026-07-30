#!/usr/bin/env bash
#===============================================================================
# tmux_local_install.sh -- build tmux (+ libevent, ncurses) from source, non-root.
#
# Installs a modern tmux into ~/.local/bin without root (handy when the system
# tmux is ancient). Versions pinned/overridable via *_VERSION env vars.
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

sm_require curl tar make gcc

LIBEVENT_VERSION="${LIBEVENT_VERSION:-2.1.12-stable}"
NCURSES_VERSION="${NCURSES_VERSION:-6.4}"
TMUX_VERSION="${TMUX_VERSION:-3.5a}"

export PATH="$BIN:$PATH"
BUILD="$(sm_workdir tmux)"

# libevent
sm_banner libevent "$LIBEVENT_VERSION"
cd "$BUILD"
sm_fetch_extract "https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz"
cd "libevent-${LIBEVENT_VERSION}"
./configure --prefix="$PREFIX" --disable-shared > configure.log
make -j"$(nproc)" > build.log && make install > install.log

# ncurses
sm_banner ncurses "$NCURSES_VERSION"
cd "$BUILD"
sm_fetch_extract "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz"
cd "ncurses-${NCURSES_VERSION}"
./configure --prefix="$PREFIX" --with-shared --enable-pc-files > configure.log
make -j"$(nproc)" > build.log && make install > install.log

# tmux
sm_banner tmux "$TMUX_VERSION"
cd "$BUILD"
sm_fetch_extract "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
cd "tmux-${TMUX_VERSION}"
./configure --prefix="$PREFIX" \
   CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses" \
   LDFLAGS="-L$PREFIX/lib" > configure.log
make -j"$(nproc)" > build.log && make install > install.log

completed "tmux installed: $("$BIN/tmux" -V)"
# vim: ts=3 sts=3 sw=3 et
