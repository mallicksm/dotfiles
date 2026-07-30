#!/usr/bin/env bash
#===============================================================================
# ollama_local_install.sh -- ollama LLM runner, prebuilt, non-root.
#
# The official install.sh needs root; instead we grab the release tarball
# (bin/ + lib/) and unpack it straight into ~/.local so `ollama` lands in
# ~/.local/bin with its libs alongside. Latest by default; pin OLLAMA_VERSION.
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl tar

tag="$(sm_resolve_version "${OLLAMA_VERSION:-}" ollama/ollama)"
sm_banner ollama "$tag"
sm_workdir ollama >/dev/null
sm_fetch "https://github.com/ollama/ollama/releases/download/${tag}/ollama-linux-amd64.tgz" ollama.tgz
# tgz layout: ./bin/ollama, ./lib/ollama/* -> unpack directly into $PREFIX.
tar -xzf ollama.tgz -C "$PREFIX"
chmod +x "$BIN/ollama"
completed "ollama installed: $("$BIN/ollama" --version 2>&1 | head -1)"
# vim: ts=3 sts=3 sw=3 et
