#!/usr/bin/env bash
#===============================================================================
# eza_local_install.sh -- eza, prebuilt, non-root.
#
# Newest release by default; pin with $EZA_VERSION or -r (e.g. v0.20.4).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=eza
TOOL_DESC="modern ls replacement"
TOOL_REPO=eza-community/eza
TOOL_PIN_VAR=EZA_VERSION
TOOL_PIN_DEFAULT=v0.20.4
TOOL_BINS=(eza)
TOOL_NEEDS=(curl unzip)
TOOL_JOBS=(check fetch install verify)
TOOL_USAGE_EXTRA="Backs the ls aliases in ~/dotfiles/bash_aliases.sh.
Note this is the gnu build, not musl -- eza ships no musl zip."

# The eza asset name embeds no version, so the tag only picks the release.
job_fetch() {
   rc_workdir
   rc_fetch_extract \
      "https://github.com/$TOOL_REPO/releases/download/$VER/eza_$(uname -m)-unknown-linux-gnu.zip"
}

job_install() {
   rc_install_bin ./eza
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
