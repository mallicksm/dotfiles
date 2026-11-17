#!/usr/bin/env bash
#===============================================================================
# starship_local_install.sh -- starship cross-shell prompt, prebuilt, non-root.
#
# Drops the prebuilt musl binary from the starship/starship release assets
# straight into ~/.local/bin. Newest release by default; pin with
# $STARSHIP_VERSION or -r.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=starship
TOOL_DESC="cross-shell prompt"
TOOL_REPO=starship/starship
TOOL_PIN_VAR=STARSHIP_VERSION
TOOL_PIN_DEFAULT=v1.23.0
TOOL_BINS=(starship)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)
TOOL_USAGE_EXTRA="Prompt config is a dotfile, not part of this install: ~/dotfiles/initrc/starship.toml
is linked by 'dotfiles.sh linkrc', and the shell glue lives in utils/bash_starship.sh."

# The musl build is deliberate: it runs on the old-glibc boxes too.
job_fetch() {
   rc_workdir
   rc_fetch_extract \
      "https://github.com/starship/starship/releases/download/${VER}/starship-$(uname -m)-unknown-linux-musl.tar.gz"
}

job_install() {
   rc_install_bin ./starship
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
