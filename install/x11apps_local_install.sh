#!/usr/bin/env bash
#===============================================================================
# x11apps_local_install.sh -- xclock + xeyes via non-root RPM extraction.
#
# Pulls xorg-x11-apps from the distro repo and extracts just the binaries into
# ~/.local/bin. Override the RPM URL with X11APPS_RPM_URL.
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl rpm2cpio cpio

URL="${X11APPS_RPM_URL:-https://dl.rockylinux.org/pub/rocky/8/AppStream/x86_64/os/Packages/x/xorg-x11-apps-7.7-21.el8.x86_64.rpm}"
sm_banner x11apps "$(basename "$URL")"
sm_workdir x11apps >/dev/null

sm_fetch "$URL" x11apps.rpm
rpm2cpio x11apps.rpm | cpio -idmv > /dev/null 2>&1

for b in xclock xeyes; do
   if [[ -x "./usr/bin/$b" ]]; then sm_install_bin "./usr/bin/$b"; else warn "$b not in RPM"; fi
done
completed "x11apps done"
# vim: ts=3 sts=3 sw=3 et
