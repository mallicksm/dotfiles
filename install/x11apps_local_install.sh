#!/usr/bin/env bash
#===============================================================================
# x11apps_local_install.sh -- xclock + xeyes via non-root RPM extraction.
#
# Pulls xorg-x11-apps from the distro repo and keeps just the two binaries.
# Handy as a quick "is my X11 forwarding alive?" test. Point
# $X11APPS_RPM_URL at a different RPM if the Rocky path moves.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=x11apps
TOOL_DESC="xclock and xeyes, for testing X11 forwarding"
TOOL_REPO=""                  # distro RPM, not a GitHub release
TOOL_PIN_VAR=""
TOOL_BINS=(xclock xeyes)
TOOL_NEEDS=(curl rpm2cpio cpio)
TOOL_JOBS=(check fetch install verify)
TOOL_ENV_EXTRA="  \$X11APPS_RPM_URL  source RPM (default: the Rocky 8 AppStream package)"

X11APPS_RPM_URL="${X11APPS_RPM_URL:-https://dl.rockylinux.org/pub/rocky/8/AppStream/x86_64/os/Packages/x/xorg-x11-apps-7.7-21.el8.x86_64.rpm}"
X11APPS_BINS=(xclock xeyes)

rc_resolve_version() { VER="$(basename "$X11APPS_RPM_URL" .rpm)"; VER_SOURCE=pin; }
RC_FIXED_URL="$X11APPS_RPM_URL"

# A pinned distro RPM has no "newer release" to chase; presence is the question.
job_check() { rc_check_fixed_url; }

job_fetch() {
   rc_workdir
   rc_fetch "$X11APPS_RPM_URL" x11apps.rpm
}

job_install() {
   run_sh 'rpm2cpio x11apps.rpm | cpio -idmv > /dev/null 2>&1'
   local b got=0
   for b in "${X11APPS_BINS[@]}"; do
      if ! rc_real || [[ -x "$W/usr/bin/$b" ]]; then
         rc_install_bin "./usr/bin/$b" && ((got++))
      else
         record "$b" WARN "not in this RPM; skipped"
      fi
   done
   if (( got )); then
      record install OK "$got of ${#X11APPS_BINS[@]} binaries installed"
   else
      record install FAIL "neither xclock nor xeyes found in the RPM"
      return 1
   fi
}

# Neither binary has a --version flag worth parsing; existence is the test.
job_verify() {
   if ! rc_real; then
      record verify OK "would check for ${X11APPS_BINS[*]} in $BIN"
      return 0
   fi
   local b missing=()
   for b in "${X11APPS_BINS[@]}"; do [[ -x "$BIN/$b" ]] || missing+=("$b"); done
   if (( ${#missing[@]} )); then
      record verify WARN "missing from $BIN: ${missing[*]}"
   else
      record verify OK "${X11APPS_BINS[*]} present in $BIN"
   fi
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
