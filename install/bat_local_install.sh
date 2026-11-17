#!/usr/bin/env bash
#===============================================================================
# bat_local_install.sh -- bat, prebuilt musl, non-root.
#
# Newest release by default; pin with $BAT_VERSION or -r (e.g. v0.24.0).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=bat
TOOL_DESC="cat with syntax highlighting"
TOOL_REPO=sharkdp/bat
TOOL_PIN_VAR=BAT_VERSION
TOOL_PIN_DEFAULT=v0.24.0
TOOL_BINS=(bat)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)
TOOL_USAGE_EXTRA="bash_first.sh exports BAT_THEME=gruvbox-dark to match the colorscheme."

# bat tags HAVE a leading v, and so does the directory inside the asset.
bat_dir() { printf 'bat-v%s-%s-unknown-linux-musl' "$(rc_nov "$VER")" "$(uname -m)"; }

job_fetch() {
   rc_workdir
   rc_fetch_extract "https://github.com/$TOOL_REPO/releases/download/v$(rc_nov "$VER")/$(bat_dir).tar.gz"
}

job_install() {
   rc_install_bin "./$(bat_dir)/bat"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
