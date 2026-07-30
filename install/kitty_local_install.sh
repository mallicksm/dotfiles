#!/usr/bin/env bash
#===============================================================================
# kitty_local_install.sh -- kitty terminal via its official non-root installer.
#
# Installs kitty.app into ~/.local (no root) and symlinks kitty + kitten into
# ~/.local/bin. The upstream installer always fetches the latest stable; pin
# with KITTY_VERSION (e.g. 0.36.4).
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl

ver_arg=""
[[ -n "${KITTY_VERSION:-}" ]] && ver_arg="version=${KITTY_VERSION}"
sm_banner kitty "${KITTY_VERSION:-latest}"

# dest=~/.local -> installs to ~/.local/kitty.app ; launch=n -> don't open kitty.
curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh \
   | sh /dev/stdin dest="$PREFIX" launch=n ${ver_arg:+$ver_arg}

sm_link_bin "$PREFIX/kitty.app/bin/kitty" kitty
sm_link_bin "$PREFIX/kitty.app/bin/kitten" kitten
completed "kitty installed: $("$BIN/kitty" --version)"
# vim: ts=3 sts=3 sw=3 et
