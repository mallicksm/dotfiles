#!/usr/bin/env bash
#===============================================================================
# node_local_install.sh -- Node.js + npm, prebuilt, non-root.
#
# Unpacks the official nodejs.org distribution into ~/.local/node, which is
# where utils/bash_node.sh expects it (it appends ~/.local/node/bin to PATH).
# Nothing is symlinked into ~/.local/bin, so node and npm stay a matched pair.
#
# Newest LTS by default (resolved from nodejs.org/dist/index.json); pin with
# $NODE_VERSION or -r, e.g. -r v22.11.0. Pass -r latest for the current line.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=node
TOOL_DESC="Node.js runtime and npm"
TOOL_REPO=""                  # versioned by nodejs.org, not GitHub releases
TOOL_PIN_VAR=NODE_VERSION
TOOL_PIN_DEFAULT=v20.12.2
TOOL_BINS=()                  # installs into $NODE_DIR/bin, not $BIN
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)
TOOL_ENV_EXTRA="  \$NODE_DIR       install location (default: ~/.local/node)"
TOOL_USAGE_EXTRA="~/.local/node/bin is put on PATH by utils/bash_node.sh, which also points
\$NODE_PATH at ~/.npm-packages -- so global npm installs survive a node upgrade."
RECIPE_JOB_DESC[install]="unpack the distribution into \$NODE_DIR"
RECIPE_JOB_DESC[verify]="run \$NODE_DIR/bin/{node,npm} --version"

NODE_DIR="${NODE_DIR:-$HOME/.local/node}"
NODE_ARCH="linux-x64"
NODE_DIST="https://nodejs.org/dist"

rc_present() { [[ -x "$NODE_DIR/bin/node" ]]; }
rc_installed_version() {
   [[ -x "$NODE_DIR/bin/node" ]] || return 0
   "$NODE_DIR/bin/node" --version 2>/dev/null | head -1
}

# Newest LTS line from the official index. The LTS field is the codename
# (e.g. "Jod") for LTS releases and false otherwise, so the first entry with a
# string there is the newest LTS -- index.json is ordered newest first.
node_latest_lts() {
   curl --fail --silent --location "$NODE_DIST/index.json" 2>/dev/null \
      | tr '{' '\n' \
      | grep -m1 '"lts":"' \
      | sed -E 's/.*"version":"([^"]+)".*/\1/'
}

rc_resolve_version() {
   [[ -n "$VERSION_OPT" ]] && { VER="$VERSION_OPT"; VER_SOURCE=opt; return; }
   [[ -n "${NODE_VERSION:-}" ]] && { VER="$NODE_VERSION"; VER_SOURCE=pin; return; }
   VER="$(node_latest_lts)"
   if [[ -n "$VER" ]]; then VER_SOURCE=upstream; else VER="$TOOL_PIN_DEFAULT"; VER_SOURCE=stale; fi
}

job_check() {
   local have lts
   have="$(rc_installed_version)"
   lts="$(node_latest_lts)"
   echo "    dest     : $NODE_DIR"
   echo "    target   : $VER"
   echo "    installed: ${have:-<not installed>}"
   echo "    newest LTS: ${lts:-<unreachable>}"
   if [[ -z "$have" ]]; then
      record check WARN "not installed yet; would install $VER"
   elif [[ "$have" == "$VER" ]]; then
      record check OK "up to date at $have"
   else
      record check WARN "installed $have; would install $VER"
   fi
}

job_fetch() {
   rc_workdir
   rc_fetch "$NODE_DIST/$VER/node-$VER-$NODE_ARCH.tar.xz"
}

job_install() {
   # Replace rather than overlay: a half-overwritten node tree with files from
   # two versions is far harder to debug than a clean reinstall.
   rc_rmrf "$NODE_DIR"
   rc_mkdir "$NODE_DIR"
   run tar -xf "node-$VER-$NODE_ARCH.tar.xz" --strip-components=1 -C "$NODE_DIR"
   record install OK "$VER unpacked into $NODE_DIR"
}

job_verify() {
   if ! rc_real; then
      printf '    %q --version && %q --version\n' "$NODE_DIR/bin/node" "$NODE_DIR/bin/npm"
      record verify OK "would run node/npm --version"
      return 0
   fi
   local n m
   n="$("$NODE_DIR/bin/node" --version 2>&1 | head -1)"
   m="$("$NODE_DIR/bin/npm" --version 2>&1 | head -1)"
   echo "    node $n / npm $m"
   if [[ -n "$n" && -n "$m" ]]; then
      record verify OK "node $n, npm $m"
   else
      record verify FAIL "node or npm did not report a version"
      return 1
   fi
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
