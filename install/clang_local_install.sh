#!/usr/bin/env bash
#===============================================================================
# clang_local_install.sh -- prebuilt LLVM/Clang tools, non-root.
#
# Unpacks an official clang+llvm release into ~/.local/clang-llvm-<ver> and
# links the three tools the neovim config actually calls -- clang-format,
# clangd, clang-tidy -- into ~/.local/bin.
#
# The version is PINNED on purpose. LLVM's asset names encode both the version
# and the distro it was built against, so "newest release" is not a URL this
# script can construct; -j check still tells you what upstream has moved to.
# To move, pass both:
#     ./clang_local_install.sh -e -r 17.0.6 \
#        CLANG_ASSET=clang+llvm-17.0.6-x86_64-linux-gnu-ubuntu-22.04.tar.xz
#
# If you only want the formatter, clang_format_local_install.sh is a single
# static binary with no glibc requirement and no multi-GB tree.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=clang
TOOL_DESC="LLVM clang-format, clangd and clang-tidy"
TOOL_REPO=llvm/llvm-project
TOOL_PIN_VAR=CLANG_VERSION
TOOL_PIN_DEFAULT=16.0.3
TOOL_PIN_IS_POLICY=1          # the asset URL is version+distro specific; see above
TOOL_BINS=(clang-format clangd clang-tidy)
TOOL_NEEDS=(curl tar xz)
TOOL_JOBS=(check fetch install link verify)
TOOL_ENV_EXTRA="  \$CLANG_ASSET    release asset name (default: the ubuntu-22.04 x86_64 build)"
TOOL_USAGE_EXTRA="clangd here is what the 'clangd' LSP in ~/dotfiles/nvim.pack attaches for c/cpp,
and clang-format is driven by ~/dotfiles/formatters/clang-format via conform.
Both this and clang_format_local_install.sh write \$BIN/clang-format -- whichever
runs last wins."
RECIPE_JOB_DESC[install]="copy the unpacked tree to \$PREFIX/clang-llvm-<ver>"
RECIPE_JOB_DESC[link]="symlink clang-format, clangd and clang-tidy into \$BIN"

CLANG_ASSET="${CLANG_ASSET:-clang+llvm-$(rc_nov "${CLANG_VERSION:-$TOOL_PIN_DEFAULT}")-x86_64-linux-gnu-ubuntu-22.04.tar.xz}"

clang_dst() { printf '%s/clang-llvm-%s' "$PREFIX" "$(rc_nov "$VER")"; }

job_check() {
   local have upstream
   [[ -x "$BIN/clang-format" ]] && have="$("$BIN/clang-format" --version 2>&1 | head -1)"
   upstream="$(sm_gh_latest "$TOOL_REPO" 2>/dev/null)"
   upstream="${upstream#llvmorg-}"
   echo "    target   : $VER  (pinned; asset $CLANG_ASSET)"
   echo "    installed: ${have:-<not installed>}"
   echo "    upstream : ${upstream:-<unreachable>}  ($TOOL_REPO)"
   if [[ -z "${have:-}" ]]; then
      record check WARN "not installed yet; would install $VER"
   elif [[ -n "$upstream" && "$upstream" != "$VER" ]]; then
      record check WARN "pinned to $VER; upstream is at $upstream (needs a matching \$CLANG_ASSET to move)"
   else
      record check OK "at the pinned version $VER"
   fi
}

job_fetch() {
   rc_workdir
   rc_fetch_extract "https://github.com/$TOOL_REPO/releases/download/llvmorg-$(rc_nov "$VER")/$CLANG_ASSET"
}

job_install() {
   local dst; dst="$(clang_dst)"
   rc_rmrf "$dst"
   rc_mkdir "$dst"
   run cp -r "./${CLANG_ASSET%.tar.xz}/." "$dst/"
   record install OK "$dst"
}

job_link() {
   local dst b linked=0
   dst="$(clang_dst)"
   for b in "${TOOL_BINS[@]}"; do
      if ! rc_real || [[ -x "$dst/bin/$b" ]]; then
         rc_link_bin "$dst/bin/$b" "$b" && ((linked++))
      else
         record "$b" WARN "not in this LLVM release; skipped"
      fi
   done
   record link OK "$linked of ${#TOOL_BINS[@]} tools linked into $BIN"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
