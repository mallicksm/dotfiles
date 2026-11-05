#!/usr/bin/env bash
#===============================================================================
# verible_local_install.sh -- SystemVerilog tooling (verible), prebuilt, non-root.
#
# Downloads the LATEST static linux release into ~/.local/tools/verible_<tag>
# and symlinks its bin/* (verible-verilog-format, -lint, -ls, ...) into
# ~/.local/bin. Pin with VERIBLE_VERSION:
#     VERIBLE_VERSION=v0.0-4013-gba3dc371 ./verible_local_install.sh
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

sm_require curl tar

tag="$(sm_resolve_version "${VERIBLE_VERSION:-}" chipsalliance/verible)"
sm_banner verible "$tag"
sm_workdir verible >/dev/null

d="verible-${tag}-linux-static-x86_64"
sm_fetch_extract "https://github.com/chipsalliance/verible/releases/download/${tag}/${d}.tar.gz"

# The asset is named ...-linux-static-x86_64.tar.gz but unpacks to a plain
# verible-<tag>/, so the archive name cannot double as the directory name.
extracted="$(find . -maxdepth 1 -type d -name 'verible-*' | head -1)"
[[ -n $extracted ]] || { error "no verible-* dir after extracting ${d}.tar.gz"; exit 1; }

dst="$TOOLSDIR/verible_${tag}"
rm -rf "$dst"; mkdir -p "$dst"
cp -r "$extracted"/. "$dst"/
ln -sfn "$dst" "$TOOLSDIR/verible_latest"
for b in "$dst"/bin/*; do sm_link_bin "$b" "$(basename "$b")"; done
completed "verible ${tag} installed under ${dst}"
# vim: ts=3 sts=3 sw=3 et
