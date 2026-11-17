#!/usr/bin/env bash
#===============================================================================
# pandoc_local_install.sh -- pandoc, prebuilt, non-root into ~/.local/bin.
#
# Newest release by default; pin with $PANDOC_VERSION or -r (e.g. 3.5).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=pandoc
TOOL_DESC="universal document converter"
TOOL_REPO=jgm/pandoc
TOOL_PIN_VAR=PANDOC_VERSION
TOOL_PIN_DEFAULT=3.5
TOOL_BINS=(pandoc)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)
TOOL_USAGE_EXTRA="Used by utils/pdf2md and the snps_md corpus flow; the markdown writer is the
only part those depend on, so a version bump here is low risk."

job_fetch() {
   local v; v="$(rc_nov "$VER")"
   rc_workdir
   rc_fetch_extract "https://github.com/$TOOL_REPO/releases/download/$v/pandoc-$v-linux-amd64.tar.gz"
}

job_install() {
   rc_install_bin "./pandoc-$(rc_nov "$VER")/bin/pandoc"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
