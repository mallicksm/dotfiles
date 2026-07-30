#!/usr/bin/env bash
#===============================================================================
# verilator_local_install.sh -- build Verilator from source, non-root.
#
# Builds help2man (a build-time dep) into ~/.local, then Verilator's `stable`
# branch into ~/.local/tools/verilator_<ts> and symlinks its bin/* into
# ~/.local/bin. Pin the branch/tag with VERILATOR_REF (default: stable):
#     VERILATOR_REF=v5.028 ./verilator_local_install.sh
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

sm_require git curl tar make gcc g++ autoconf

# NOTE: colon, not semicolon (the old script had a PATH-breaking ';' here).
export PATH="$BIN:$PATH"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

BUILD="$(sm_workdir verilator)"

# --- help2man (build dep) -----------------------------------------------------
HELP2MAN_VERSION="${HELP2MAN_VERSION:-help2man-1.49.3}"
sm_banner help2man "$HELP2MAN_VERSION"
cd "$BUILD"
sm_fetch_extract "https://ftp.gnu.org/gnu/help2man/${HELP2MAN_VERSION}.tar.xz"
cd "$HELP2MAN_VERSION"
./configure --prefix="$PREFIX" > configure.log
make -j"$(nproc)" > build.log
make install > install.log

# --- verilator ----------------------------------------------------------------
ref="${VERILATOR_REF:-stable}"
stamp="$(date +%Y_%b_%d_%H_%M_%S)"
dst="$TOOLSDIR/verilator_${stamp}"
sm_banner verilator "$ref"
cd "$BUILD"
git clone https://github.com/verilator/verilator.git verilator-src
cd verilator-src
git checkout "$ref"
autoconf
./configure --prefix="$dst" > configure.log
make -j"$(nproc)" > build.log
make install > install.log

ln -sfn "$dst" "$TOOLSDIR/verilator_latest"
for b in "$dst"/bin/*; do sm_link_bin "$b" "$(basename "$b")"; done
completed "verilator installed under ${dst}"
# vim: ts=3 sts=3 sw=3 et
