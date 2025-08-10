#!/bin/bash
set -e

TEST=
PREFIX="$HOME/.local$TEST"
BUILD="$HOME/verilator-build$TEST"
mkdir -p "$PREFIX" "$BUILD"
cd "$BUILD"

export PATH="$PREFIX/bin;$PATH"
declare -A build_recipes

HELP2MAN_VERSION="help2man-1.49.3"
build_recipes[help2man.url]="https://mirror.us-midwest-1.nexcess.net/gnu/help2man/\$HELP2MAN_VERSION.tar.xz"
build_recipes[help2man.config_cmd]="./configure --prefix=\$PREFIX"
build_recipes[help2man.install_cmd]="make install"

source ~/dotfiles/utils/bash_snippets.sh 2>/dev/null
build_all_tools

VERILATOR_VERSION=verilator_$(date +"%Y_%b_%d_%H_%M_%S")
echo ""
echo "🔧 Building verilator ($VERILATOR_VERSION)..."

# Download
git clone https://github.com/verilator/verilator.git "$VERILATOR_VERSION"
cd "$VERILATOR_VERSION"
git checkout stable

# Configure
echo "→ Configuring: ./configure..."
autoconf
./configure --prefix="$PREFIX/$VERILATOR_VERSION" > configure.log

# Build
echo "→ Compiling: make > build.log"
make > build.log

# Install
echo "→ Installing: make install > install.log"
make install > install.log

echo ""
echo "✅ Git $VERILATOR_VERSION installed in $PREFIX/$VERILATOR_VERSION"
echo "👉 Add to PATH if not already:"
echo "   export PATH=\"$PREFIX/$VERILATOR_VERSION/bin:\$PATH\""
