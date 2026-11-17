#!/usr/bin/env bash
#===============================================================================
# gettext_local_install.sh -- GNU gettext from source, non-root.
#
# Provides envsubst, xgettext, the msg* family, ngettext, gettext(ize),
# autopoint and recode-sr-latin, all into ~/.local/bin.
#
# Newest release by default (read from the GNU ftp listing, which is the only
# index there is -- gettext has no GitHub releases); pin with $GETTEXT_VERSION
# or -r.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=gettext
TOOL_DESC="GNU gettext (envsubst, xgettext, msgfmt, ...)"
TOOL_REPO=""                  # GNU ftp, not GitHub
TOOL_PIN_VAR=GETTEXT_VERSION
TOOL_PIN_DEFAULT=0.22.5
TOOL_BINS=(xgettext envsubst msgfmt)
TOOL_NEEDS=(curl tar make gcc)
TOOL_JOBS=(check fetch build install verify)
TOOL_SLOW=1
TOOL_USAGE_EXTRA="envsubst is the one most things here actually want; it is a hard dependency
of several corp scripts that template config files."
RECIPE_JOB_DESC[build]="./configure --prefix=\$PREFIX --disable-static, then make"
RECIPE_JOB_DESC[install]="make install into \$PREFIX"

GETTEXT_MIRROR="https://ftp.gnu.org/gnu/gettext"

gettext_latest() {
   curl --fail --silent --location "$GETTEXT_MIRROR/" 2>/dev/null \
      | grep -oE 'gettext-[0-9]+\.[0-9]+(\.[0-9]+)?\.tar\.gz' \
      | sed -e 's/^gettext-//' -e 's/\.tar\.gz$//' \
      | sort -V | tail -1
}

rc_resolve_version() {
   [[ -n "$VERSION_OPT" ]] && { VER="$VERSION_OPT"; VER_SOURCE=opt; return; }
   [[ -n "${GETTEXT_VERSION:-}" ]] && { VER="$GETTEXT_VERSION"; VER_SOURCE=pin; return; }
   VER="$(gettext_latest)"
   if [[ -n "$VER" ]]; then VER_SOURCE=upstream; else VER="$TOOL_PIN_DEFAULT"; VER_SOURCE=stale; fi
}

gettext_src() { printf '%s/gettext-%s' "$W" "$VER"; }

job_check() {
   local have latest
   [[ -x "$BIN/xgettext" ]] && have="$("$BIN/xgettext" --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)"
   latest="$(gettext_latest)"
   echo "    target   : $VER"
   echo "    installed: ${have:-<not installed>}"
   echo "    upstream : ${latest:-<unreachable>}  ($GETTEXT_MIRROR)"
   if [[ -z "${have:-}" ]]; then
      record check WARN "not installed yet; would build $VER"
   elif [[ "$have" == "$VER" ]]; then
      record check OK "up to date at $have"
   else
      record check WARN "installed $have; would build $VER"
   fi
}

job_fetch() {
   rc_workdir
   rc_fetch_extract "$GETTEXT_MIRROR/gettext-$VER.tar.gz"
}

job_build() {
   # $BIN first on PATH so the build picks up tools this tree installed
   # earlier rather than the ancient system ones.
   rc_export "PATH=$BIN:$PATH"
   rc_dir "$(gettext_src)"
   run ./configure --prefix="$PREFIX" --disable-static || return 1
   run make -j"$(nproc)"
}

job_install() {
   rc_export "PATH=$BIN:$PATH"
   rc_dir "$(gettext_src)"
   run make install
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
