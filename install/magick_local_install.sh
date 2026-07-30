#!/usr/bin/env bash
#===============================================================================
# magick_local_install.sh -- ImageMagick `magick` portable AppImage, non-root.
#
# Grabs the upstream portable AppImage. If FUSE is available it's symlinked
# straight into ~/.local/bin; otherwise we self-extract it and drop a tiny
# wrapper in ~/.local/bin (works on boxes without FUSE). Override MAGICK_URL.
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl

URL="${MAGICK_URL:-https://imagemagick.org/archive/binaries/magick}"
sm_banner ImageMagick "portable"

dst="$TOOLSDIR/imagemagick"
rm -rf "$dst"; mkdir -p "$dst"; cd "$dst"
sm_fetch "$URL" magick.appimage
chmod +x magick.appimage

if ./magick.appimage --version >/dev/null 2>&1; then
   sm_link_bin "$dst/magick.appimage" magick
else
   warn "AppImage can't run directly (no FUSE?) -- self-extracting"
   ./magick.appimage --appimage-extract >/dev/null
   cat > "$BIN/magick" <<EOF
#!/bin/bash
exec "$dst/squashfs-root/AppRun" "\$@"
EOF
   chmod +x "$BIN/magick"
   completed "installed magick wrapper -> $dst/squashfs-root/AppRun"
fi
completed "magick installed: $("$BIN/magick" --version | head -1)"
# vim: ts=3 sts=3 sw=3 et
