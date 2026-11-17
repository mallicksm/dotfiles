#!/usr/bin/env bash
#===============================================================================
# kitty_local_install.sh -- kitty terminal via its official non-root installer.
#
# Upstream ships a self-contained installer that drops kitty.app into a prefix
# of your choosing, so that is used rather than hand-unpacking the tarball.
# kitty + kitten are then symlinked into ~/.local/bin.
#
# Newest stable by default; pin with $KITTY_VERSION or -r (e.g. 0.36.4).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=kitty
TOOL_DESC="GPU-accelerated terminal emulator"
TOOL_REPO=kovidgoyal/kitty
TOOL_PIN_VAR=KITTY_VERSION
TOOL_PIN_DEFAULT=0.36.4
TOOL_BINS=(kitty kitten)
TOOL_NEEDS=(curl)
TOOL_JOBS=(check install link verify)
TOOL_USAGE_EXTRA="Config is a dotfile: ~/dotfiles/initrc/kitty is linked by 'dotfiles.sh linkrc',
which also points kitty.os.conf at the kitty.darwin.conf / kitty.linux.conf
for this machine. utils/bash_kitty.sh carries the shell-side helpers."
RECIPE_JOB_DESC[install]="run the upstream installer into \$PREFIX/kitty.app"
RECIPE_JOB_DESC[link]="symlink kitty and kitten into \$BIN"

# The installer fetches its own tarball, so there is no separate fetch job.
job_install() {
   rc_dir /
   # dest=   -> installs to $PREFIX/kitty.app
   # launch=n -> do not open a window when it finishes
   # version= -> only passed when pinned; omitted means latest stable
   local ver_arg=""
   [[ -n "${KITTY_VERSION:-}$VERSION_OPT" ]] && ver_arg=" version=$VER"
   run_sh "curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh \
| sh /dev/stdin dest=$(printf '%q' "$PREFIX") launch=n$ver_arg"
   record install OK "$PREFIX/kitty.app"
}

job_link() {
   rc_link_bin "$PREFIX/kitty.app/bin/kitty" kitty
   rc_link_bin "$PREFIX/kitty.app/bin/kitten" kitten
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
