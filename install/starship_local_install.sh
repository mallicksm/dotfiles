#!/usr/bin/env bash
#===============================================================================
# starship_local_install.sh -- starship prompt, prebuilt, non-root into ~/.local/bin.
# Latest by default; pin with STARSHIP_VERSION (e.g. v1.23.0).
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl tar

tag="$(sm_resolve_version "${STARSHIP_VERSION:-}" starship/starship)"
sm_banner starship "$tag"
sm_workdir starship >/dev/null
sm_fetch_extract "https://github.com/starship/starship/releases/download/${tag}/starship-x86_64-unknown-linux-musl.tar.gz"
sm_install_bin ./starship
completed "starship installed: $("$BIN/starship" --version | head -1)"
# vim: ts=3 sts=3 sw=3 et
