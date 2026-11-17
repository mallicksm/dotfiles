#!/usr/bin/env bash
#===============================================================================
# z_local_install.sh -- rupa/z directory jumper, non-root.
#
# z is a single sourced shell function, not a binary, so it is installed as
# ~/dotfiles/initrc/z.sh where utils/bash_z.sh sources it from. (dotfiles.sh's
# link map deliberately maps z.sh to /dev/null: it is used in place, not
# symlinked into $HOME.)
#
# rupa/z cuts no releases, so the "version" is a git ref -- master by default.
# Pin with $Z_VERSION or -r, e.g. -r v1.12 or -r <sha>.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=z
TOOL_DESC="frecency directory jumper (sourced, not a binary)"
TOOL_REPO=""                  # no releases; versioned by git ref
TOOL_PIN_VAR=Z_VERSION
TOOL_PIN_DEFAULT=master
TOOL_BINS=()                  # nothing lands in $BIN
TOOL_NEEDS=(curl)
TOOL_JOBS=(check fetch install verify)
TOOL_ENV_EXTRA="  \$Z_DEST         where z.sh is written (default: ~/dotfiles/initrc/z.sh)"
TOOL_USAGE_EXTRA="z keeps its database at \$_Z_DATA (default ~/.z); this script never touches it,
so a reinstall or version bump will not lose your frecency history."
RECIPE_JOB_DESC[fetch]="download z.sh at the target ref into a scratch dir"
RECIPE_JOB_DESC[install]="write z.sh (and a .rev stamp) to \$Z_DEST"
RECIPE_JOB_DESC[verify]="syntax-check the installed z.sh and confirm it defines _z()"

Z_DEST="${Z_DEST:-$HOME/dotfiles/initrc/z.sh}"
Z_RAW="https://raw.githubusercontent.com/rupa/z"

# Installed-ness is a file on disk, not a binary in $BIN -- so the stock
# "is it already there?" probes have to be told where to look.
rc_present() { [[ -s "$Z_DEST" ]]; }

# z.sh carries no version string. The best available identity is the upstream
# commit it came from, which is recorded beside it at install time.
rc_installed_version() { [[ -s "$Z_DEST.rev" ]] && head -1 "$Z_DEST.rev"; }

z_upstream_rev() {
   git ls-remote "https://github.com/rupa/z" "$VER" 2>/dev/null | cut -c1-12 | head -1
}

job_check() {
   local have upstream
   have="$(rc_installed_version)"
   upstream="$(z_upstream_rev)"
   echo "    dest     : $Z_DEST"
   echo "    ref      : $VER"
   echo "    installed: ${have:-$(rc_present && echo 'present (unknown revision)' || echo '<not installed>')}"
   echo "    upstream : ${upstream:-<unreachable or not a ref>}"

   if ! rc_present; then
      record check WARN "not installed yet; would fetch $VER"
   elif [[ -n "$have" && -n "$upstream" && "$have" == "$upstream" ]]; then
      record check OK "up to date at $have"
   else
      record check WARN "installed ${have:-unknown}; upstream $VER is ${upstream:-unknown}"
   fi
}

job_fetch() {
   rc_workdir
   rc_fetch "$Z_RAW/$VER/z.sh" z.sh
}

job_install() {
   rc_mkdir "${Z_DEST%/*}"
   run install -m 0644 z.sh "$Z_DEST"
   # Stamp the upstream commit next to it so `check` can tell staleness later.
   local rev; rev="$(z_upstream_rev)"
   if [[ -n "$rev" ]]; then
      run_sh "printf '%s\n' $(printf '%q' "$rev") > $(printf '%q' "$Z_DEST.rev")"
   fi
   record install OK "$Z_DEST${rev:+ @ $rev}"
}

job_verify() {
   if ! rc_real; then
      printf '    bash -n %q\n' "$Z_DEST"
      record verify OK "would syntax-check $Z_DEST"
      return 0
   fi
   if bash -n "$Z_DEST" 2>/dev/null && grep -q '^_z()' "$Z_DEST"; then
      record verify OK "$Z_DEST parses and defines _z()"
   else
      record verify FAIL "$Z_DEST is not a usable z.sh"
      return 1
   fi
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
