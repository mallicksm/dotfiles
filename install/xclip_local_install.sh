#!/usr/bin/env bash
#===============================================================================
# xclip_local_install.sh -- xclip via non-root RPM extraction into ~/.local/bin.
#
# There is no upstream static xclip binary, so the EPEL RPM is unpacked with
# rpm2cpio and only the binary is kept -- no root and no rpm database. There
# is nothing to resolve "latest" against; point $XCLIP_RPM_URL at a different
# RPM if the EPEL path moves.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=xclip
TOOL_DESC="X11 clipboard from the command line"
TOOL_REPO=""                  # distro RPM, not a GitHub release
TOOL_PIN_VAR=""
TOOL_BINS=(xclip)
TOOL_VERSION_FLAG="-version"  # note: one dash
TOOL_NEEDS=(curl rpm2cpio cpio)
TOOL_JOBS=(check fetch install verify)
TOOL_ENV_EXTRA="  \$XCLIP_RPM_URL  source RPM (default: the EPEL 8 x86_64 package)"
TOOL_USAGE_EXTRA="Neovim's clipboard=unnamedplus goes through this, so yanking to the system
clipboard over X11 forwarding stops working without it."

XCLIP_RPM_URL="${XCLIP_RPM_URL:-https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/x/xclip-0.13-8.el8.x86_64.rpm}"

# The RPM filename is the only version identity available.
rc_resolve_version() { VER="$(basename "$XCLIP_RPM_URL" .rpm)"; VER_SOURCE=pin; }
RC_FIXED_URL="$XCLIP_RPM_URL"

# A pinned distro RPM has no "newer release" to chase; presence is the question.
job_check() { rc_check_fixed_url; }

job_fetch() {
   rc_workdir
   rc_fetch "$XCLIP_RPM_URL" xclip.rpm
}

job_install() {
   run_sh 'rpm2cpio xclip.rpm | cpio -idmv > /dev/null 2>&1'
   if rc_real && [[ ! -x "$W/usr/bin/xclip" ]]; then
      record install FAIL "no usr/bin/xclip inside $XCLIP_RPM_URL"
      return 1
   fi
   rc_install_bin ./usr/bin/xclip
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
