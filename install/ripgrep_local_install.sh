#!/usr/bin/env bash
#===============================================================================
# ripgrep_local_install.sh -- ripgrep (rg), prebuilt musl, non-root.
#
# Newest release by default; pin with $RG_VERSION or -r (e.g. 14.1.1).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=ripgrep
TOOL_DESC="recursive grep (rg)"
TOOL_REPO=BurntSushi/ripgrep
TOOL_PIN_VAR=RG_VERSION
TOOL_PIN_DEFAULT=14.1.1
TOOL_BINS=(rg)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)

# ripgrep tags carry NO leading v, and the asset embeds the bare version.
job_fetch() {
   local v; v="$(rc_nov "$VER")"
   rc_workdir
   rc_fetch_extract \
      "https://github.com/$TOOL_REPO/releases/download/$v/ripgrep-$v-$(uname -m)-unknown-linux-musl.tar.gz"
}

job_install() {
   rc_install_bin "./ripgrep-$(rc_nov "$VER")-$(uname -m)-unknown-linux-musl/rg"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
