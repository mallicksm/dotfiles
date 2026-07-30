#!/usr/bin/env bash
#===============================================================================
# xclip_local_install.sh -- xclip via non-root RPM extraction into ~/.local/bin.
#
# There's no upstream static xclip binary, so we pull the EPEL RPM and extract
# just the binary (no root / rpm database needed). Override the RPM URL with
# XCLIP_RPM_URL if the EPEL path changes.
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

sm_require curl rpm2cpio cpio

URL="${XCLIP_RPM_URL:-https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/x/xclip-0.13-8.el8.x86_64.rpm}"
sm_banner xclip "$(basename "$URL")"
sm_workdir xclip >/dev/null

sm_fetch "$URL" xclip.rpm
rpm2cpio xclip.rpm | cpio -idmv > /dev/null 2>&1

if [[ -x ./usr/bin/xclip ]]; then
   sm_install_bin ./usr/bin/xclip
else
   error "xclip binary not found after extraction"; exit 1
fi
completed "xclip installed: $("$BIN/xclip" -version 2>&1 | head -1)"
# vim: ts=3 sts=3 sw=3 et
