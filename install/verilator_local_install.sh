#!/usr/bin/env bash
#===============================================================================
# verilator_local_install.sh -- build Verilator from source, non-root.
#
# Builds help2man (a build-time dependency these boxes lack) into ~/.local,
# then Verilator into ~/.local/tools/verilator_<ts>, retags verilator_latest
# and links its bin/* into ~/.local/bin.
#
# Tracks the `stable` branch by default; pin with $VERILATOR_REF or -r, e.g.
#     ./verilator_local_install.sh -e -r v5.028
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=verilator
TOOL_DESC="Verilog/SystemVerilog simulator and lint front end"
TOOL_REPO=verilator/verilator
TOOL_PIN_VAR=VERILATOR_REF
TOOL_PIN_DEFAULT=stable
TOOL_PIN_IS_POLICY=1          # a branch, not a tag; -j check reports the newest tag
TOOL_BINS=(verilator)
TOOL_NEEDS=(git curl tar make gcc g++ autoconf)
TOOL_JOBS=(check fetch build install link verify)
TOOL_SLOW=1
TOOL_ENV_EXTRA="  \$HELP2MAN_VERSION  build dependency (default: help2man-1.49.3)"
RECIPE_JOB_DESC[fetch]="download help2man and clone verilator at the target ref"
RECIPE_JOB_DESC[build]="build+install help2man, then autoconf/configure/make verilator"
RECIPE_JOB_DESC[install]="make install into \$TOOLSDIR/verilator_<ts> and retag verilator_latest"
RECIPE_JOB_DESC[link]="symlink \$TOOLSDIR/verilator_latest/bin/* into \$BIN"

HELP2MAN_VERSION="${HELP2MAN_VERSION:-help2man-1.49.3}"
# Timestamped so an older build stays on disk and verilator_latest is the only
# thing that moves -- a bad build can be backed out by retargeting the symlink.
VERILATOR_DST="$TOOLSDIR/verilator_$(date +%Y_%b_%d_%H_%M_%S)"

# NOTE: colon, not semicolon. The pre-recipe version of this script had a
# PATH-breaking ';' here that silently poisoned the rest of the build.
verilator_env() {
   rc_export "PATH=$BIN:$PATH" "CPPFLAGS=-I$PREFIX/include" "LDFLAGS=-L$PREFIX/lib"
}

job_check() {
   local have upstream
   [[ -x "$BIN/verilator" ]] && have="$("$BIN/verilator" --version 2>/dev/null | head -1)"
   upstream="$(sm_gh_latest "$TOOL_REPO" 2>/dev/null)"
   echo "    target ref: $VER"
   if [[ -z "${have:-}" && -x "$BIN/verilator" ]]; then
      echo "    installed : present but not runnable (stale)"
   else
      echo "    installed : ${have:-<not installed>}"
   fi
   echo "    newest tag: ${upstream:-<unreachable>}  ($TOOL_REPO)"
   if [[ -x "$BIN/verilator" && -z "${have:-}" ]]; then
      # Usually a leftover wrapper whose $TOOLSDIR tree was cleaned away.
      record check WARN "$BIN/verilator exists but will not run -- stale install, rebuild it"
   elif [[ -z "${have:-}" ]]; then
      record check WARN "not installed yet; would build $VER"
   else
      record check OK "installed ($have); building $VER again picks up any new commits"
   fi
}

job_fetch() {
   rc_workdir
   rc_fetch_extract "https://ftp.gnu.org/gnu/help2man/${HELP2MAN_VERSION}.tar.xz" || return 1
   rc_dir "$W"
   run git clone "https://github.com/$TOOL_REPO.git" verilator-src || return 1
   rc_dir "$W/verilator-src"
   run git checkout "$VER"
}

job_build() {
   verilator_env

   echo "    --- $HELP2MAN_VERSION"
   rc_dir "$W/$HELP2MAN_VERSION"
   run ./configure --prefix="$PREFIX" || return 1
   run make -j"$(nproc)"              || return 1
   run make install                   || return 1

   echo "    --- verilator $VER"
   rc_dir "$W/verilator-src"
   run autoconf                            || return 1
   run ./configure --prefix="$VERILATOR_DST" || return 1
   run make -j"$(nproc)"
}

job_install() {
   verilator_env
   rc_dir "$W/verilator-src"
   run make install || return 1
   step / ln -sfn "$VERILATOR_DST" "$TOOLSDIR/verilator_latest"
   record install OK "$VERILATOR_DST (verilator_latest retagged)"
}

job_link() {
   rc_link_tree_bins "$TOOLSDIR/verilator_latest"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
