#!/usr/bin/env bash
#===============================================================================
# pandoc_local_install.sh -- pandoc prebuilt binary, non-root into ~/.local/bin.
# Latest by default; pin with PANDOC_VERSION (e.g. 3.5).
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl tar

v="$(sm_nov "$(sm_resolve_version "${PANDOC_VERSION:-}" jgm/pandoc)")"
sm_banner pandoc "$v"
sm_workdir pandoc >/dev/null
d="pandoc-${v}"
sm_fetch_extract "https://github.com/jgm/pandoc/releases/download/${v}/${d}-linux-amd64.tar.gz"
sm_install_bin "${d}/bin/pandoc"
completed "pandoc installed: $("$BIN/pandoc" --version | head -1)"
# vim: ts=3 sts=3 sw=3 et
