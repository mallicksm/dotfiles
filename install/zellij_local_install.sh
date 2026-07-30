#!/usr/bin/env bash
#===============================================================================
# zellij_local_install.sh -- zellij terminal multiplexer, prebuilt, non-root.
# Latest by default; pin with ZELLIJ_VERSION (e.g. v0.44.2).
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl tar

tag="$(sm_resolve_version "${ZELLIJ_VERSION:-}" zellij-org/zellij)"
sm_banner zellij "$tag"
sm_workdir zellij >/dev/null
sm_fetch_extract "https://github.com/zellij-org/zellij/releases/download/${tag}/zellij-x86_64-unknown-linux-musl.tar.gz"
sm_install_bin ./zellij
completed "zellij installed: $("$BIN/zellij" --version)"
# vim: ts=3 sts=3 sw=3 et
