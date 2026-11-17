#!/usr/bin/env bash
#===============================================================================
# procs_local_install.sh -- procs, prebuilt, non-root.
#
# Newest release by default; pin with $PROCS_VERSION or -r (e.g. v0.14.6).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=procs
TOOL_DESC="modern ps replacement"
TOOL_REPO=dalance/procs
TOOL_PIN_VAR=PROCS_VERSION
TOOL_PIN_DEFAULT=v0.14.6
TOOL_BINS=(procs)
TOOL_NEEDS=(curl unzip)
TOOL_JOBS=(check fetch install verify)

# procs tags HAVE a leading v; the asset repeats it but the rest of the name
# does not follow the usual <name>-<ver>-<triple> shape.
job_fetch() {
   local v; v="$(rc_nov "$VER")"
   rc_workdir
   rc_fetch_extract "https://github.com/$TOOL_REPO/releases/download/v$v/procs-v$v-$(uname -m)-linux.zip"
}

job_install() {
   rc_install_bin ./procs
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
