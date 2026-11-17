#!/usr/bin/env bash
#===============================================================================
# delta_local_install.sh -- delta git pager, prebuilt musl, non-root.
#
# Newest release by default; pin with $DELTA_VERSION or -r (e.g. 0.18.2).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=delta
TOOL_DESC="syntax-highlighting pager for git diffs"
TOOL_REPO=dandavison/delta
TOOL_PIN_VAR=DELTA_VERSION
TOOL_PIN_DEFAULT=0.18.2
TOOL_BINS=(delta)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)
TOOL_USAGE_EXTRA="Wired in as git's pager by ~/dotfiles/initrc/git, so git diff/log/show go
through it; git falls back to less if it is missing."

# delta tags carry NO leading v, and the asset embeds the bare version.
delta_dir() { printf 'delta-%s-%s-unknown-linux-musl' "$(rc_nov "$VER")" "$(uname -m)"; }

job_fetch() {
   rc_workdir
   rc_fetch_extract "https://github.com/$TOOL_REPO/releases/download/$(rc_nov "$VER")/$(delta_dir).tar.gz"
}

job_install() {
   rc_install_bin "./$(delta_dir)/delta"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
