#!/usr/bin/env bash
#===============================================================================
# ollama_local_install.sh -- ollama LLM runner, prebuilt, non-root.
#
# The official install.sh wants root, so the release tarball is unpacked
# straight into ~/.local instead: its layout is already ./bin/ollama plus
# ./lib/ollama/*, which lands the binary in ~/.local/bin with its libraries
# beside it.
#
# Newest release by default; pin with $OLLAMA_VERSION or -r.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=ollama
TOOL_DESC="run LLMs locally"
TOOL_REPO=ollama/ollama
TOOL_PIN_VAR=OLLAMA_VERSION
TOOL_PIN_DEFAULT=v0.5.7
TOOL_BINS=(ollama)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)
TOOL_USAGE_EXTRA="This installs the runner only. Models are pulled separately with 'ollama pull'
and live in ~/.ollama, which a reinstall does not touch."
RECIPE_JOB_DESC[install]="unpack bin/ and lib/ into \$PREFIX"

job_fetch() {
   rc_workdir
   rc_fetch "https://github.com/$TOOL_REPO/releases/download/$VER/ollama-linux-amd64.tgz" ollama.tgz
}

job_install() {
   run tar -xzf ollama.tgz -C "$PREFIX"
   run chmod +x "$BIN/ollama"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
