#!/usr/bin/env bash
# shellcheck shell=bash
#===============================================================================
# install/lib.sh -- shared helpers for every ~/dotfiles/install/*_local_install.sh
#
# Design goals (map to the user's requirements):
#   * NON-ROOT: everything installs under $PREFIX (~/.local). Executables end
#     up on PATH in $BIN (~/.local/bin); larger unpacked trees live in
#     $TOOLSDIR (~/.local/tools) and are symlinked into $BIN.
#   * CONSISTENT: one place defines the dirs, download, sm_extract, and install
#     primitives so every tool script looks the same.
#   * LATEST, but PINNABLE (hybrid): sm_resolve_version prefers an explicit pin
#     (env var / arg) and otherwise queries the GitHub "latest release" API.
#     So a bare run on a fresh box grabs the newest release, while
#     `RG_VERSION=14.1.1 ./modern_linux_tools.sh` reproduces a known-good one.
#
# Source this at the top of a tool script:
#     set -euo pipefail
#     source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
#
# NOTE: this file intentionally does NOT `set -e` -- the orchestrator sources
# it and manages per-tool failures itself. Individual tool scripts opt into
# `set -euo pipefail` on their own.
#===============================================================================

# Fundamentals (info/warn/error/completed, has, Pushd/Popd, download) come from
# the dotfiles foundation layer. Fall back to minimal defs if it's ever missing.
if [[ -r "$HOME/dotfiles/utils/bash_first.sh" ]]; then
   # shellcheck source=../utils/bash_first.sh
   source "$HOME/dotfiles/utils/bash_first.sh"
else
   has() { command -v "$1" >/dev/null 2>&1; }
   info() { printf '> %s\n' "$*"; }
   warn() { printf '! %s\n' "$*" >&2; }
   error() { printf 'x %s\n' "$*" >&2; }
   completed() { printf 'v %s\n' "$*"; }
   Pushd() { command pushd "$@" >/dev/null 2>&1; }
   Popd() { command popd >/dev/null 2>&1; }
   download() {
      local url="$1" file="${2:-${1##*/}}"
      if has curl; then curl --fail --silent --location --output "$file" "$url"
      elif has wget; then wget --quiet --output-document="$file" "$url"
      else error "no curl/wget"; return 1; fi
   }
fi

# --- install layout -----------------------------------------------------------
PREFIX="${LOCAL_PREFIX:-$HOME/.local}"   # honor LOCAL_PREFIX override
BIN="$PREFIX/bin"
TOOLSDIR="$PREFIX/tools"
WORKROOT="${TMPDIR:-/tmp}/$USER/dotfiles-install"
export PREFIX BIN TOOLSDIR WORKROOT
mkdir -p "$BIN" "$TOOLSDIR"

# --- version resolution (hybrid: pin wins, else GitHub latest) ----------------
# sm_gh_latest OWNER/REPO : echo the newest release tag (e.g. v14.1.1 or 3.10.1).
# Downloads the API JSON to a temp file first (avoids SIGPIPE noise from
# grep -m1 closing a live curl pipe).
sm_gh_latest() {
   local repo="$1" tmp tag hdr=()
   [[ -n "${GITHUB_TOKEN:-}" ]] && hdr=(-H "Authorization: Bearer $GITHUB_TOKEN")
   tmp="$(mktemp "${TMPDIR:-/tmp}/sm_gh_latest.XXXXXX")"
   if ! curl -fsSL "${hdr[@]}" "https://api.github.com/repos/$repo/releases/latest" -o "$tmp"; then
      rm -f "$tmp"; error "sm_gh_latest: API request failed for $repo"; return 1
   fi
   tag="$(grep -m1 '"tag_name"' "$tmp" | sed -E 's/.*"tag_name":[[:space:]]*"([^"]+)".*/\1/')"
   rm -f "$tmp"
   [[ -n "$tag" ]] || { error "sm_gh_latest: no tag_name for $repo"; return 1; }
   printf '%s' "$tag"
}

# sm_resolve_version PIN OWNER/REPO : echo PIN if non-empty, else sm_gh_latest REPO.
sm_resolve_version() {
   local pin="$1" repo="$2"
   if [[ -n "$pin" ]]; then printf '%s' "$pin"; else sm_gh_latest "$repo"; fi
}

# strip a leading 'v' from a tag: v14.1.1 -> 14.1.1 (many asset names omit it)
sm_nov() { printf '%s' "${1#v}"; }

# --- scratch / sm_fetch / sm_extract ------------------------------------------------
# sm_workdir NAME : make a FRESH scratch dir under $WORKROOT and cd into it.
sm_workdir() {
   local d="$WORKROOT/$1"
   rm -rf "$d"; mkdir -p "$d"; cd "$d" || return 1
   printf '%s' "$d"
}

# sm_fetch URL [OUTFILE] : download into cwd (thin wrapper for symmetry / logging).
sm_fetch() {
   local url="$1"
   info "downloading ${url}"
   download "$url" "${2:-${url##*/}}"
}

# sm_extract FILE : unpack a tar.*/zip archive into cwd.
sm_extract() {
   local f="$1"
   case "$f" in
      *.tar.gz | *.tgz)   tar -xzf "$f" ;;
      *.tar.xz)           tar -xJf "$f" ;;
      *.tar.bz2)          tar -xjf "$f" ;;
      *.tar)              tar -xf  "$f" ;;
      *.zip)              unzip -q -o "$f" ;;
      *) error "sm_extract: unknown archive type: $f"; return 1 ;;
   esac
}

# sm_fetch_extract URL : download then sm_extract into cwd. Echoes the archive name.
sm_fetch_extract() {
   local url="$1" file="${1##*/}"
   sm_fetch "$url" "$file" && sm_extract "$file"
}

# --- install into $BIN --------------------------------------------------------
# sm_install_bin SRC [NAME] : copy an executable into $BIN (mode 0755).
sm_install_bin() {
   local src="$1" name="${2:-$(basename "$1")}"
   install -m 0755 "$src" "$BIN/$name"
   completed "installed ${name} -> ${BIN}/${name}"
}

# sm_link_bin TARGET NAME : create/replace symlink $BIN/NAME -> TARGET.
sm_link_bin() {
   local target="$1" name="$2"
   ln -sfn "$target" "$BIN/$name"
   completed "linked ${name} -> ${target}"
}

# sm_require CMD... : abort if any build/runtime prerequisite is missing.
sm_require() {
   local missing=() c
   for c in "$@"; do has "$c" || missing+=("$c"); done
   if (( ${#missing[@]} )); then
      error "missing prerequisites: ${missing[*]}"
      return 1
   fi
}

# sm_banner NAME VERSION : consistent per-tool header.
sm_banner() { info "=== ${1} (${2:-latest}) ==="; }
# vim: ts=3 sts=3 sw=3 et
