#!/usr/bin/env bash
#===============================================================================
# nvim_local_install.sh -- Neovim, prebuilt, non-root.
#
# Pulls from neovim/neovim-releases by default -- those are the static builds
# that still run on old glibc (EL8). Set $NVIM_REPO=neovim/neovim for the
# mainline builds instead.
#
# Unpacks into ~/.local/tools/nvim_<tag>, retags ~/.local/tools/nvim_latest,
# and links ~/.local/bin/nvim at it, so the bin symlink never has to change.
#
# Newest release by default; pin with $NVIM_VERSION or -r (e.g. v0.11.3).
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=nvim
TOOL_DESC="Neovim editor"
TOOL_REPO="${NVIM_REPO:-neovim/neovim-releases}"
TOOL_PIN_VAR=NVIM_VERSION
TOOL_PIN_DEFAULT=v0.11.3
TOOL_BINS=(nvim)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install link verify)
TOOL_ENV_EXTRA="  \$NVIM_REPO      release repo (default: neovim/neovim-releases, old-glibc safe)"
TOOL_USAGE_EXTRA="The config this drives lives in ~/dotfiles/nvim.pack (default, vim.pack) and
~/dotfiles/nvim.easy (lazy.nvim); the 'vi' wrapper in utils/bash_nvim.sh picks.
nvim.pack needs Neovim 0.12+ for vim.pack, so do not pin below that for it."
RECIPE_JOB_DESC[install]="copy the unpacked tree to \$TOOLSDIR/nvim_<tag> and retag nvim_latest"
RECIPE_JOB_DESC[link]="symlink \$TOOLSDIR/nvim_latest/bin/nvim into \$BIN"

NVIM_ASSET="nvim-linux-$(uname -m).tar.gz"

job_fetch() {
   rc_workdir
   rc_fetch_extract "https://github.com/$TOOL_REPO/releases/download/$VER/$NVIM_ASSET"
}

job_install() {
   local dst="$TOOLSDIR/nvim_$VER"
   rc_rmrf "$dst"
   rc_mkdir "$dst"
   run_sh "d=\$(find . -maxdepth 1 -type d -name 'nvim-linux*' | head -1); \
[ -n \"\$d\" ] || { echo 'no nvim-linux* dir after extract' >&2; exit 1; }; \
cp -r \"\$d\"/. $(printf '%q' "$dst")/" || {
      record install FAIL "no nvim-linux* directory after extracting $NVIM_ASSET"
      return 1
   }
   step / ln -sfn "$dst" "$TOOLSDIR/nvim_latest"
   record install OK "$dst (nvim_latest retagged)"
}

job_link() {
   rc_link_bin "$TOOLSDIR/nvim_latest/bin/nvim" nvim
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
