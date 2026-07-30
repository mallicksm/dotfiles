#!/usr/bin/env bash
#===============================================================================
# nvim_local_install.sh -- Neovim, non-root into ~/.local/tools + ~/.local/bin.
#
# Uses the neovim/neovim-releases repo (static builds that run on older glibc,
# e.g. EL8) by default. Grabs the LATEST release; pin with NVIM_VERSION, e.g.:
#     NVIM_VERSION=v0.11.3 ./nvim_local_install.sh
# Set NVIM_REPO=neovim/neovim to use the mainline (newer-glibc) builds instead.
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

sm_require curl tar

repo="${NVIM_REPO:-neovim/neovim-releases}"
tag="$(sm_resolve_version "${NVIM_VERSION:-}" "$repo")"
sm_banner neovim "$tag"

dst="$TOOLSDIR/nvim_${tag}"
rm -rf "$dst" && mkdir -p "$dst"
Pushd "$dst"

asset="nvim-linux-x86_64.tar.gz"
sm_fetch_extract "https://github.com/${repo}/releases/download/${tag}/${asset}"

# The tarball unpacks to nvim-linux-x86_64/; keep a stable nvim_latest symlink
# alongside the versioned dir so the bin symlink never needs updating.
extracted="$(find . -maxdepth 1 -type d -name 'nvim-linux*' | head -1)"
ln -sfn "$dst/${extracted#./}" "$TOOLSDIR/nvim_latest"
Popd

sm_link_bin "$TOOLSDIR/nvim_latest/bin/nvim" nvim
completed "nvim ${tag} ready: $("$BIN/nvim" --version | head -1)"
# vim: ts=3 sts=3 sw=3 et
