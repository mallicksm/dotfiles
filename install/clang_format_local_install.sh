#!/usr/bin/env bash
#===============================================================================
# clang_format_local_install.sh -- clang-format alone, as a static binary.
#
# The lightweight alternative to clang_local_install.sh: one fully static
# binary from muttleyxd/clang-tools-static-binaries, no glibc requirement and
# no 2 GB LLVM tree. This is the right choice on the old EL8 boxes and when
# all you need is the formatter that utils/fmt.sh and conform.nvim call.
#
# Use clang_local_install.sh instead when you also want clangd and clang-tidy;
# the two scripts install the same $BIN/clang-format, so the last one run wins.
#
# Newest release by default; the clang major version is chosen with
# $CLANG_FORMAT_MAJOR (default 16), the release tag with $CLANG_FORMAT_VERSION.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=clang-format
TOOL_DESC="C/C++ formatter, static single binary"
TOOL_REPO=muttleyxd/clang-tools-static-binaries
TOOL_PIN_VAR=CLANG_FORMAT_VERSION
TOOL_PIN_DEFAULT=master-f4f85437
TOOL_BINS=(clang-format)
TOOL_NEEDS=(curl)
TOOL_JOBS=(check fetch install verify)
TOOL_ENV_EXTRA="  \$CLANG_FORMAT_MAJOR  clang major version to pull (default: 16)"
TOOL_USAGE_EXTRA="The upstream release tags are rolling snapshots (master-<sha>), not versions,
so -j check compares the clang major version rather than the tag."

CLANG_FORMAT_MAJOR="${CLANG_FORMAT_MAJOR:-16}"
CF_ASSET="clang-format-${CLANG_FORMAT_MAJOR}_linux-amd64"

# The binary reports its clang version, which has nothing to do with the
# snapshot tag, so the stock version comparison would always cry stale.
job_check() {
   local have
   [[ -x "$BIN/clang-format" ]] && have="$("$BIN/clang-format" --version 2>&1 | head -1)"
   echo "    target   : clang $CLANG_FORMAT_MAJOR  (release $VER, asset $CF_ASSET)"
   echo "    installed: ${have:-<not installed>}"
   if [[ -z "${have:-}" ]]; then
      record check WARN "not installed yet; would install clang $CLANG_FORMAT_MAJOR"
   elif [[ "$have" == *"version $CLANG_FORMAT_MAJOR."* ]]; then
      record check OK "already clang $CLANG_FORMAT_MAJOR ($have)"
   else
      record check WARN "installed '$have'; target is clang $CLANG_FORMAT_MAJOR"
   fi
}

# Rolling tags mean "is the installed one the target one?" cannot be answered
# by comparing tags, so skip on the major version instead.
recipe_skip_check() {
   SKIP_REASON=""
   (( FORCE )) && return
   [[ -x "$BIN/clang-format" ]] || return
   local have; have="$("$BIN/clang-format" --version 2>&1 | head -1)"
   [[ "$have" == *"version $CLANG_FORMAT_MAJOR."* ]] \
      && SKIP_REASON="already clang $CLANG_FORMAT_MAJOR"
}

job_fetch() {
   rc_workdir
   rc_fetch "https://github.com/$TOOL_REPO/releases/download/$VER/$CF_ASSET"
}

job_install() {
   rc_install_bin "./$CF_ASSET" clang-format
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
