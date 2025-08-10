#!/bin/bash
set -e

TEST=
export PREFIX="$HOME/.local$TEST"
export BUILD="$HOME/riscvgcc-build$TEST"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

mkdir -p "$PREFIX" "$BUILD"
cd "$BUILD"

export PATH="$PREFIX/bin;$PATH"
declare -A build_recipes

TEXINFO_VERSION="texinfo-7.1"
build_recipes[texinfo.url]="https://ftp.gnu.org/gnu/texinfo/\$TEXINFO_VERSION.tar.gz"
build_recipes[texinfo.config_cmd]="./configure --prefix=\$HOME/.local"
build_recipes[texinfo.install_cmd]="make install"

GMP_VERSION="gmp-6.3.0"
build_recipes[gmp.url]="https://ftp.gnu.org/gnu/gmp/\$GMP_VERSION.tar.xz"
build_recipes[gmp.config_cmd]="./configure --prefix=$PREFIX --enable-cxx"
build_recipes[gmp.install_cmd]="make install"

MPFR_VERSION="mpfr-4.2.1"
build_recipes[mpfr.url]="https://ftp.gnu.org/gnu/mpfr/\$MPFR_VERSION.tar.xz"
build_recipes[mpfr.config_cmd]="./configure --prefix=$PREFIX --with-gmp=$PREFIX"
build_recipes[mpfr.install_cmd]="make install"

source ~/dotfiles/utils/bash_snippets.sh 2>/dev/null
build_all_tools

RISCVGCC_VERSION=riscvgcc_$(date +"%Y_%b_%d_%H_%M_%S")
echo ""
echo "🔧 Building riscvgcc ($RISCVGCC_VERSION)..."

# Download
git clone https://github.com/riscv/riscv-gnu-toolchain "$RISCVGCC_VERSION"
cd "$RISCVGCC_VERSION"

# Configure
echo "→ Configuring: ./configure..."
GDB_CONFIGURE_ARGS="--with-gmp=$PREFIX --with-mpfr=$PREFIX" ./configure --prefix="$PREFIX/$RISCVGCC_VERSION" > configure.log

# Build
echo "→ Compiling: make -j$(nproc) > build.log"
make > build.log

echo ""
echo "✅ Git $RISCVGCC_VERSION installed in $PREFIX/$RISCVGCC_VERSION"
echo "👉 Add to PATH if not already:"
echo "   export PATH=\"$PREFIX/$RISCVGCC_VERSION/bin:\$PATH\""
