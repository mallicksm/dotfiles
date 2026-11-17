#!/usr/bin/env bash
#===============================================================================
# magick_local_install.sh -- ImageMagick `magick`, portable AppImage, non-root.
#
# Grabs the upstream portable AppImage into ~/.local/tools/imagemagick. If
# FUSE works it is symlinked straight into ~/.local/bin; if not (common on the
# locked-down boxes) the AppImage is self-extracted and a small wrapper is
# dropped in ~/.local/bin instead.
#
# Upstream publishes a single rolling URL rather than versioned assets, so
# there is no version to resolve; override the whole URL with $MAGICK_URL.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=magick
TOOL_DESC="ImageMagick, portable single-file build"
TOOL_REPO=""                  # rolling URL, no release assets
TOOL_PIN_VAR=""
TOOL_BINS=(magick)
TOOL_NEEDS=(curl)
TOOL_JOBS=(check fetch install verify)
TOOL_ALWAYS=1                 # rolling build: re-running is how you update
TOOL_ENV_EXTRA="  \$MAGICK_URL     AppImage URL (default: imagemagick.org/archive/binaries/magick)"

MAGICK_URL="${MAGICK_URL:-https://imagemagick.org/archive/binaries/magick}"
MAGICK_DST="$TOOLSDIR/imagemagick"

rc_resolve_version() { VER=portable; VER_SOURCE=pin; }
RC_FIXED_URL="$MAGICK_URL"

# A rolling URL has no version to compare; re-fetching IS the upgrade.
job_check() { rc_check_fixed_url; }

job_fetch() {
   rc_rmrf "$MAGICK_DST"
   rc_mkdir "$MAGICK_DST"
   rc_dir "$MAGICK_DST"
   rc_fetch "$MAGICK_URL" magick.appimage
   run chmod +x magick.appimage
}

job_install() {
   rc_dir "$MAGICK_DST"
   if ! rc_real; then
      echo "    (if the AppImage runs directly)"
      rc_link_bin "$MAGICK_DST/magick.appimage" magick
      echo "    (otherwise) self-extract and install a wrapper at $BIN/magick"
      record install OK "would link or wrap $MAGICK_DST/magick.appimage"
      return 0
   fi
   if "$MAGICK_DST/magick.appimage" --version >/dev/null 2>&1; then
      rc_link_bin "$MAGICK_DST/magick.appimage" magick
      record install OK "linked the AppImage directly (FUSE works here)"
      return
   fi
   warn "AppImage will not run directly (no FUSE?) -- self-extracting"
   run ./magick.appimage --appimage-extract
   # A wrapper rather than a symlink: AppRun needs to be invoked from its own
   # squashfs-root, and a symlink into $BIN would lose that context.
   run_sh "printf '%s\n' '#!/bin/bash' 'exec $(printf '%q' "$MAGICK_DST/squashfs-root/AppRun") \"\$@\"' > $(printf '%q' "$BIN/magick")"
   run chmod +x "$BIN/magick"
   record install OK "wrapper -> $MAGICK_DST/squashfs-root/AppRun (no FUSE)"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
