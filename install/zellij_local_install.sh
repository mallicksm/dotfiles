#!/usr/bin/env bash
#===============================================================================
# zellij_local_install.sh -- zellij terminal multiplexer, prebuilt, non-root.
#
# Prebuilt musl binary from the zellij-org/zellij release assets into
# ~/.local/bin, or `brew install` on macOS. Newest release by default; pin
# with $ZELLIJ_VERSION or -r.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=zellij
TOOL_DESC="terminal multiplexer"
TOOL_REPO=zellij-org/zellij
TOOL_PIN_VAR=ZELLIJ_VERSION
TOOL_PIN_DEFAULT=v0.44.2
TOOL_BINS=(zellij)
TOOL_JOBS=(check fetch install verify)
TOOL_USAGE_EXTRA="Layouts and config are dotfiles, not part of this install: ~/dotfiles/initrc/zellij
is linked by 'dotfiles.sh linkrc', and the shell glue lives in utils/bash_zellij.sh."

# macOS has no musl release asset, so it goes through brew. Everything the
# Linux path needs is declared here rather than at the top so a mac run does
# not demand tar.
if [[ "$(uname -s)" == Darwin ]]; then
   TOOL_NEEDS=(brew)
else
   TOOL_NEEDS=(curl tar)
fi

job_fetch() {
   if [[ "$(uname -s)" == Darwin ]]; then
      record fetch OK "nothing to fetch; brew owns the download on macOS"
      return 0
   fi
   rc_workdir
   rc_fetch_extract \
      "https://github.com/zellij-org/zellij/releases/download/${VER}/zellij-$(uname -m)-unknown-linux-musl.tar.gz"
}

job_install() {
   if [[ "$(uname -s)" == Darwin ]]; then
      # -f means the user asked for a reinstall; brew install would no-op.
      rc_dir /
      if (( FORCE )); then run brew reinstall zellij; else run brew install zellij; fi
      return
   fi
   rc_install_bin ./zellij
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
