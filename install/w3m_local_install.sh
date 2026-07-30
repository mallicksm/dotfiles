#!/usr/bin/env bash
#===============================================================================
# w3m_local_install.sh -- w3m text browser via non-root RPM extraction.
#
# Extracts the EPEL w3m RPM into ~/.local/w3m and symlinks w3m + w3mman into
# ~/.local/bin. Override the RPM URL with W3M_RPM_URL if the EPEL path changes.
# (w3m links against gc/openssl already present on these boxes; if a shared lib
#  is missing, extract the matching dep RPM into ~/.local/w3m the same way.)
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl rpm2cpio cpio

URL="${W3M_RPM_URL:-https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/w/w3m-0.5.3-46.git20230121.el8.x86_64.rpm}"
sm_banner w3m "$(basename "$URL")"

dst="$PREFIX/w3m"
rm -rf "$dst"; mkdir -p "$dst"
sm_workdir w3m >/dev/null
sm_fetch "$URL" w3m.rpm
rpm2cpio w3m.rpm | ( cd "$dst" && cpio -idmv ) > /dev/null 2>&1

[[ -x "$dst/usr/bin/w3m" ]] || { error "w3m binary not found after extraction"; exit 1; }
sm_link_bin "$dst/usr/bin/w3m" w3m
[[ -e "$dst/usr/bin/w3mman" ]] && sm_link_bin "$dst/usr/bin/w3mman" w3mman
completed "w3m installed under ${dst}"
# vim: ts=3 sts=3 sw=3 et
