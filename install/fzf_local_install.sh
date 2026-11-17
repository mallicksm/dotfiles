#!/usr/bin/env bash
#===============================================================================
# fzf_local_install.sh -- fzf fuzzy finder, non-root, as a ~/.fzf checkout.
#
# Deliberately a git checkout rather than a loose binary: utils/bash_fzf.sh
# puts ~/.fzf/bin on PATH and sources ~/.fzf/shell/{completion,key-bindings}.bash,
# so the shell integration has to come from the repo layout. The binary itself
# is fetched by fzf's own ./install --bin.
#
# Newest release tag by default; pin with $FZF_VERSION or -r.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=fzf
TOOL_DESC="command-line fuzzy finder"
TOOL_REPO=junegunn/fzf
TOOL_PIN_VAR=FZF_VERSION
TOOL_PIN_DEFAULT=v0.56.3
TOOL_BINS=()                  # lives in ~/.fzf/bin, which bash_fzf.sh adds to PATH
TOOL_NEEDS=(git)
TOOL_JOBS=(check fetch install verify)
TOOL_ENV_EXTRA="  \$FZF_DIR        checkout location (default: ~/.fzf)"
TOOL_USAGE_EXTRA="Shell integration is NOT installed into your rc files -- utils/bash_fzf.sh
already carries a lightly edited copy of it, so ./install is run with --bin only."
RECIPE_JOB_DESC[fetch]="clone \$FZF_DIR if absent, then fetch tags"
RECIPE_JOB_DESC[install]="check out the target tag and run ./install --bin"
RECIPE_JOB_DESC[verify]="run \$FZF_DIR/bin/fzf --version"

FZF_DIR="${FZF_DIR:-$HOME/.fzf}"

rc_present() { [[ -x "$FZF_DIR/bin/fzf" ]]; }
rc_installed_version() {
   [[ -x "$FZF_DIR/bin/fzf" ]] || return 0
   "$FZF_DIR/bin/fzf" --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -1
}

job_check() {
   local have upstream
   have="$(rc_installed_version)"
   upstream="$(sm_gh_latest "$TOOL_REPO" 2>/dev/null)"
   echo "    checkout : $FZF_DIR"
   echo "    target   : $VER"
   echo "    installed: ${have:-<not installed>}"
   echo "    upstream : ${upstream:-<unreachable>}  ($TOOL_REPO)"
   if [[ -z "$have" ]]; then
      record check WARN "not installed yet; would clone $TOOL_REPO at $VER"
   elif [[ "$(rc_nov "$VER")" == "$have" ]]; then
      record check OK "up to date at $have"
   else
      record check WARN "installed $have; would install $VER"
   fi
}

# A full clone (not --depth 1) so the tag the user asked for is reachable;
# --filter keeps it cheap without losing history refs.
job_fetch() {
   if [[ -d "$FZF_DIR/.git" ]]; then
      rc_dir "$FZF_DIR"
      run git fetch --tags --prune origin
   else
      rc_dir /
      run git clone --filter=blob:none "https://github.com/$TOOL_REPO.git" "$FZF_DIR"
   fi
}

job_install() {
   rc_dir "$FZF_DIR"
   run git checkout --detach "$VER"
   # --bin: download the prebuilt fzf into ~/.fzf/bin and stop. No --all, which
   # would rewrite ~/.bashrc behind our back.
   run ./install --bin
}

job_verify() {
   if ! rc_real; then
      printf '    %q --version\n' "$FZF_DIR/bin/fzf"
      record verify OK "would run $FZF_DIR/bin/fzf --version"
      return 0
   fi
   local out
   out="$("$FZF_DIR/bin/fzf" --version 2>&1 | head -1)"
   if [[ -n "$out" ]]; then
      echo "    $out"
      record verify OK "$out"
   else
      record verify FAIL "$FZF_DIR/bin/fzf did not report a version"
      return 1
   fi
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
