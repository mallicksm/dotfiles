#!/usr/bin/env bash
#===============================================================================
# patchelf_local_install.sh -- patchelf prebuilt, non-root into ~/.local/bin.
# Latest by default; pin with PATCHELF_VERSION (e.g. 0.18.0).
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl tar

v="$(sm_nov "$(sm_resolve_version "${PATCHELF_VERSION:-}" NixOS/patchelf)")"
sm_banner patchelf "$v"
sm_workdir patchelf >/dev/null
# Release ships a tarball that unpacks to ./bin/patchelf (+ share/, etc.)
sm_fetch_extract "https://github.com/NixOS/patchelf/releases/download/${v}/patchelf-${v}-x86_64.tar.gz"
sm_install_bin ./bin/patchelf
completed "patchelf installed: $("$BIN/patchelf" --version)"
# vim: ts=3 sts=3 sw=3 et
