#!/usr/bin/env bash
#===============================================================================
# verible_local_install.sh -- SystemVerilog tooling (verible), prebuilt, non-root.
#
# Unpacks the static linux release into ~/.local/tools/verible_<tag>, keeps a
# verible_latest symlink beside it, and links every bin/* (verible-verilog-format,
# -lint, -ls, ...) into ~/.local/bin.
#
# Newest release by default; pin with $VERIBLE_VERSION or -r, e.g.
#     ./verible_local_install.sh -e -r v0.0-4013-gba3dc371
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=verible
TOOL_DESC="SystemVerilog formatter, linter and language server"
TOOL_REPO=chipsalliance/verible
TOOL_PIN_VAR=VERIBLE_VERSION
TOOL_PIN_DEFAULT=v0.0-4013-gba3dc371
TOOL_BINS=(verible-verilog-format verible-verilog-lint verible-verilog-ls)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install link verify)
TOOL_USAGE_EXTRA="This is the formatter behind utils/fmt.sh, conform.nvim's verible_verilog_format,
and the 'verible' LSP in the neovim config. Its rules live in
~/dotfiles/formatters/verible-rules and ~/dotfiles/formatters/verible-format.flagfile."
RECIPE_JOB_DESC[install]="copy the unpacked tree to \$TOOLSDIR/verible_<tag> and retag verible_latest"
RECIPE_JOB_DESC[link]="symlink \$TOOLSDIR/verible_latest/bin/* into \$BIN"

TOOL_VERSION_FLAG="--version"
VERIBLE_DST=""   # set in recipe_main's flow via the jobs below

# verible-verilog-format prints "v0.0-4013-gba3dc371", which has no dotted
# number for the stock probe to find.
rc_installed_version() {
   [[ -x "$BIN/verible-verilog-format" ]] || return 0
   "$BIN/verible-verilog-format" --version 2>&1 | grep -oE 'v[0-9.]+-[0-9]+-g[0-9a-f]+' | head -1
}

job_fetch() {
   rc_workdir
   # The asset is named ...-linux-static-x86_64.tar.gz but unpacks to a plain
   # verible-<tag>/, so the archive name cannot double as the directory name.
   rc_fetch_extract \
      "https://github.com/$TOOL_REPO/releases/download/$VER/verible-$VER-linux-static-x86_64.tar.gz"
}

job_install() {
   VERIBLE_DST="$TOOLSDIR/verible_$VER"
   rc_rmrf "$VERIBLE_DST"
   rc_mkdir "$VERIBLE_DST"
   # Resolved as a glob at run time because the unpacked directory name does
   # not always match the asset name.
   run_sh "d=\$(find . -maxdepth 1 -type d -name 'verible-*' | head -1); \
[ -n \"\$d\" ] || { echo 'no verible-* dir after extract' >&2; exit 1; }; \
cp -r \"\$d\"/. $(printf '%q' "$VERIBLE_DST")/" || {
      record install FAIL "no verible-* directory after extracting the release"
      return 1
   }
   step / ln -sfn "$VERIBLE_DST" "$TOOLSDIR/verible_latest"
   record install OK "$VERIBLE_DST (verible_latest retagged)"
}

job_link() {
   rc_link_tree_bins "$TOOLSDIR/verible_latest"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
