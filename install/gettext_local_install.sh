#!/usr/bin/env bash
#===============================================================================
# gettext_local_install.sh -- GNU gettext from source, non-root.
#
# Provides envsubst, xgettext, msgfmt/msgmerge/msg*, ngettext, gettext(ize),
# autopoint, recode-sr-latin -> all into ~/.local/bin. Pin GETTEXT_VERSION.
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
sm_require curl tar make gcc

GETTEXT_VERSION="${GETTEXT_VERSION:-0.22.5}"
sm_banner gettext "$GETTEXT_VERSION"

export PATH="$BIN:$PATH"
BUILD="$(sm_workdir gettext)"
cd "$BUILD"
sm_fetch_extract "https://ftp.gnu.org/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz"
cd "gettext-${GETTEXT_VERSION}"
./configure --prefix="$PREFIX" --disable-static > configure.log
make -j"$(nproc)" > build.log
make install > install.log
completed "gettext installed: $("$BIN/xgettext" --version | head -1)"
# vim: ts=3 sts=3 sw=3 et
