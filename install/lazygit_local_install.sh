#!/usr/bin/env bash
#===============================================================================
# lazygit_local_install.sh -- lazygit, prebuilt, non-root.
#
# Newest release by default; pin with $LAZYGIT_VERSION or -r (e.g. v0.44.1).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=lazygit
TOOL_DESC="terminal UI for git"
TOOL_REPO=jesseduffield/lazygit
TOOL_PIN_VAR=LAZYGIT_VERSION
TOOL_PIN_DEFAULT=v0.44.1
TOOL_BINS=(lazygit)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)
TOOL_USAGE_EXTRA="Config lives in ~/dotfiles/lazygit; neovim opens it with <leader>gl via
snacks.lazygit, so this is a hard dependency of that keymap."

# lazygit tags HAVE a leading v; the asset embeds the bare version.
job_fetch() {
   local v; v="$(rc_nov "$VER")"
   rc_workdir
   rc_fetch_extract "https://github.com/$TOOL_REPO/releases/download/v$v/lazygit_${v}_Linux_$(uname -m).tar.gz"
}

job_install() {
   rc_install_bin ./lazygit
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
