#!/usr/bin/env bash
#===============================================================================
# pip_local_install.sh -- install the Python CLI tools (requirements.txt), non-root.
#
# Uses `pip install --user` so all entry-point scripts land in ~/.local/bin.
# Latest by default; edit install/requirements.txt to pin versions.
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
req="$here/requirements.txt"

# Prefer python3 -m pip; fall back to pip3 / pip.
if has python3 && python3 -m pip --version >/dev/null 2>&1; then
   PIP=(python3 -m pip)
elif has pip3; then PIP=(pip3)
elif has pip;  then PIP=(pip)
else error "no pip found (need python3 -m pip / pip3 / pip)"; exit 1; fi

sm_banner "python tools" "requirements.txt"
export PYTHONUSERBASE="$PREFIX"   # ensure --user scripts go to ~/.local/bin
"${PIP[@]}" install --user --upgrade -r "$req"
completed "pip tools installed into ${BIN} (see $req)"
# vim: ts=3 sts=3 sw=3 et
