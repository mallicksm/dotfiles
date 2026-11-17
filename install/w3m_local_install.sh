#!/usr/bin/env bash
#===============================================================================
# w3m_local_install.sh -- w3m text browser via non-root RPM extraction.
#
# Unpacks the EPEL w3m RPM into ~/.local/w3m and symlinks w3m + w3mman into
# ~/.local/bin. w3m links against gc/openssl that these boxes already have; if
# a shared library turns out to be missing, extract the matching dependency
# RPM into ~/.local/w3m the same way.
#
# Point $W3M_RPM_URL at a different RPM if the EPEL path moves.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=w3m
TOOL_DESC="terminal web browser and pager"
TOOL_REPO=""                  # distro RPM, not a GitHub release
TOOL_PIN_VAR=""
TOOL_BINS=(w3m)
TOOL_NEEDS=(curl rpm2cpio cpio)
TOOL_JOBS=(check fetch install link verify)
TOOL_ENV_EXTRA="  \$W3M_RPM_URL    source RPM (default: the EPEL 8 x86_64 package)"
RECIPE_JOB_DESC[install]="unpack the RPM into \$PREFIX/w3m"
RECIPE_JOB_DESC[link]="symlink w3m and w3mman into \$BIN"

W3M_RPM_URL="${W3M_RPM_URL:-https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/w/w3m-0.5.3-46.git20230121.el8.x86_64.rpm}"
W3M_DST="$PREFIX/w3m"

rc_resolve_version() { VER="$(basename "$W3M_RPM_URL" .rpm)"; VER_SOURCE=pin; }
RC_FIXED_URL="$W3M_RPM_URL"

# A pinned distro RPM has no "newer release" to chase; presence is the question.
job_check() { rc_check_fixed_url; }

job_fetch() {
   rc_workdir
   rc_fetch "$W3M_RPM_URL" w3m.rpm
}

# Unpacked into its own prefix rather than scattered over ~/.local, because
# w3m wants its share/w3m data files at a fixed path relative to the binary.
job_install() {
   rc_rmrf "$W3M_DST"
   rc_mkdir "$W3M_DST"
   run_sh "rpm2cpio w3m.rpm | ( cd $(printf '%q' "$W3M_DST") && cpio -idmv ) > /dev/null 2>&1"
   if rc_real && [[ ! -x "$W3M_DST/usr/bin/w3m" ]]; then
      record install FAIL "no usr/bin/w3m inside $W3M_RPM_URL"
      return 1
   fi
   record install OK "unpacked into $W3M_DST"
}

job_link() {
   rc_link_bin "$W3M_DST/usr/bin/w3m" w3m
   if ! rc_real || [[ -e "$W3M_DST/usr/bin/w3mman" ]]; then
      rc_link_bin "$W3M_DST/usr/bin/w3mman" w3mman
   else
      record w3mman WARN "not in this RPM; skipped"
   fi
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
