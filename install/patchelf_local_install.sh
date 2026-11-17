#!/usr/bin/env bash
#===============================================================================
# patchelf_local_install.sh -- patchelf, prebuilt, non-root into ~/.local/bin.
#
# Newest release by default; pin with $PATCHELF_VERSION or -r (e.g. 0.18.0).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=patchelf
TOOL_DESC="rewrite the rpath/interpreter of ELF binaries"
TOOL_REPO=NixOS/patchelf
TOOL_PIN_VAR=PATCHELF_VERSION
TOOL_PIN_DEFAULT=0.18.0
TOOL_BINS=(patchelf)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)

# The release tarball unpacks to ./bin/patchelf alongside share/, man/ etc.
job_fetch() {
   local v; v="$(rc_nov "$VER")"
   rc_workdir
   rc_fetch_extract "https://github.com/$TOOL_REPO/releases/download/$v/patchelf-$v-$(uname -m).tar.gz"
}

job_install() {
   rc_install_bin ./bin/patchelf
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
