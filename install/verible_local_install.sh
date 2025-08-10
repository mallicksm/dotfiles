#!/bin/bash
set -e

TEST=
PREFIX="$HOME/.local$TEST"
BUILD="$HOME/verible-build$TEST"
URL=https://github.com/chipsalliance/verible/releases/download/v0.0-4013-gba3dc371/verible-v0.0-4013-gba3dc371-linux-static-x86_64.tar.gz
mkdir -p "$PREFIX" "$BUILD"
cd "$BUILD"

echo "⬇️  Downloading Verible release..."
curl -LO "$URL"

TARFILE=$(basename $URL)
INSTALL_DIR=${TARFILE%-linux-static-x86_64.tar.gz}
echo "📦 Extracting..."
tar -xf "$TARFILE"
cp -r "$INSTALL_DIR" $PREFIX

echo "✅ Installed to: $PREFIX/$INSTALL_DIR"
echo "   Add to your PATH:"
echo "   export PATH=\"$PREFIX/$INSTALL_DIR/bin:\$PATH\""
