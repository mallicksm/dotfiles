#!/usr/bin/env bash
#===============================================================================
# riscvgcc_local_install.sh -- build the RISC-V GNU toolchain from source.
#
# Builds texinfo/gmp/mpfr into ~/.local, then the riscv-gnu-toolchain into
# ~/.local/tools/riscvgcc_<ts> and symlinks its bin/* into ~/.local/bin.
# This is a LONG build. Pin deps via *_VERSION; pin the toolchain ref via
# RISCVGCC_REF (default: master).
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

sm_require git curl tar make gcc g++

# NOTE: colon, not semicolon (the old script had a PATH-breaking ';' here).
export PATH="$BIN:$PATH"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

BUILD="$(sm_workdir riscvgcc)"

sm_build_dep() { # name url configure_cmd tarball topdir
   local name="$1" url="$2" cfg="$3" tarball="$4" top="$5"
   sm_banner "$name" ""
   cd "$BUILD"
   sm_fetch_extract "$url"
   cd "$top"
   eval "$cfg" > configure.log
   make -j"$(nproc)" > build.log
   make install > install.log
   cd "$BUILD"
}

TEXINFO_VERSION="${TEXINFO_VERSION:-texinfo-7.1}"
GMP_VERSION="${GMP_VERSION:-gmp-6.3.0}"
MPFR_VERSION="${MPFR_VERSION:-mpfr-4.2.1}"

sm_build_dep texinfo "https://ftp.gnu.org/gnu/texinfo/${TEXINFO_VERSION}.tar.gz" \
   "./configure --prefix=$PREFIX" "${TEXINFO_VERSION}.tar.gz" "$TEXINFO_VERSION"
sm_build_dep gmp "https://ftp.gnu.org/gnu/gmp/${GMP_VERSION}.tar.xz" \
   "./configure --prefix=$PREFIX --enable-cxx" "${GMP_VERSION}.tar.xz" "$GMP_VERSION"
sm_build_dep mpfr "https://ftp.gnu.org/gnu/mpfr/${MPFR_VERSION}.tar.xz" \
   "./configure --prefix=$PREFIX --with-gmp=$PREFIX" "${MPFR_VERSION}.tar.xz" "$MPFR_VERSION"

# --- riscv-gnu-toolchain ------------------------------------------------------
ref="${RISCVGCC_REF:-master}"
stamp="$(date +%Y_%b_%d_%H_%M_%S)"
dst="$TOOLSDIR/riscvgcc_${stamp}"
sm_banner riscvgcc "$ref"
cd "$BUILD"
git clone https://github.com/riscv/riscv-gnu-toolchain riscvgcc-src
cd riscvgcc-src
[[ "$ref" != master ]] && git checkout "$ref"
GDB_CONFIGURE_ARGS="--with-gmp=$PREFIX --with-mpfr=$PREFIX" \
   ./configure --prefix="$dst" > configure.log
make > build.log   # note: riscv-gnu-toolchain's `make` self-parallelizes

ln -sfn "$dst" "$TOOLSDIR/riscvgcc_latest"
if [[ -d "$dst/bin" ]]; then
   for b in "$dst"/bin/*; do sm_link_bin "$b" "$(basename "$b")"; done
fi
completed "riscv toolchain installed under ${dst}"
# vim: ts=3 sts=3 sw=3 et
