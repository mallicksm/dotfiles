#!/usr/bin/env bash
#===============================================================================
# fd_local_install.sh -- fd, prebuilt musl, non-root.
#
# Newest release by default; pin with $FD_VERSION or -r (e.g. v10.4.2).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=fd
TOOL_DESC="fast find replacement"
TOOL_REPO=sharkdp/fd
TOOL_PIN_VAR=FD_VERSION
TOOL_PIN_DEFAULT=v10.4.2
TOOL_BINS=(fd)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)
TOOL_USAGE_EXTRA="\$FZF_DEFAULT_COMMAND in utils/bash_fzf.sh is 'fd --type f', so fzf's file
widget stops working if this is missing."

# fd tags HAVE a leading v, and so does the directory inside the asset.
fd_dir() { printf 'fd-v%s-%s-unknown-linux-musl' "$(rc_nov "$VER")" "$(uname -m)"; }

job_fetch() {
   rc_workdir
   rc_fetch_extract "https://github.com/$TOOL_REPO/releases/download/v$(rc_nov "$VER")/$(fd_dir).tar.gz"
}

job_install() {
   rc_install_bin "./$(fd_dir)/fd"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
