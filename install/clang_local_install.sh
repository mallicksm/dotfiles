#!/usr/bin/env bash
#===============================================================================
# clang_local_install.sh -- prebuilt LLVM/Clang tools, non-root.
#
# Extracts an official clang+llvm release into ~/.local/clang-llvm-<ver> and
# symlinks clang-format, clangd, clang-tidy (the ones the nvim config uses)
# into ~/.local/bin. LLVM's release asset names are version/distro-specific, so
# this pins to the known-good 16.0.3 build by default. Override with:
#     CLANG_VERSION=17.0.6 CLANG_ASSET=clang+llvm-17.0.6-x86_64-linux-gnu-ubuntu-22.04.tar.xz ./clang_local_install.sh
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl tar xz

CLANG_VERSION="${CLANG_VERSION:-16.0.3}"
CLANG_ASSET="${CLANG_ASSET:-clang+llvm-${CLANG_VERSION}-x86_64-linux-gnu-ubuntu-22.04.tar.xz}"
sm_banner clang+llvm "$CLANG_VERSION"

sm_workdir clang >/dev/null
sm_fetch_extract "https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_VERSION}/${CLANG_ASSET}"

srcdir="${CLANG_ASSET%.tar.xz}"
dst="$PREFIX/clang-llvm-${CLANG_VERSION}"
rm -rf "$dst"; mkdir -p "$dst"
cp -r "$srcdir"/. "$dst"/
for b in clang-format clangd clang-tidy; do
   [[ -x "$dst/bin/$b" ]] && sm_link_bin "$dst/bin/$b" "$b" || warn "$b not in release"
done
completed "clang tools installed under ${dst}"
# vim: ts=3 sts=3 sw=3 et
