#!/usr/bin/env bash
#===============================================================================
# git_local_install.sh -- build git and its dependencies from source, non-root.
#
# Builds static openssl, zlib, expat and curl into ~/.local, then git against
# them. The point is a self-contained git with working https on boxes whose
# system git is ancient and whose system curl is older still.
#
# The dependency versions are PINNED to the known-good set that produced the
# current working toolchain -- this is a chain of four libraries that have to
# agree with each other, so "newest of everything" is not automatically a
# build that links. -j check reports what upstream git has moved to; override
# any single component with its own env var:
#     OPENSSL_VERSION=openssl-3.3.2 ./git_local_install.sh -e
#     ./git_local_install.sh -e -r 2.47.1        # git itself
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=git
TOOL_DESC="git built against its own static openssl/zlib/expat/curl"
TOOL_REPO=git/git
TOOL_PIN_VAR=GIT_VERSION
TOOL_PIN_DEFAULT=2.45.1
TOOL_PIN_IS_POLICY=1          # part of a four-library set that must agree
TOOL_BINS=(git)
TOOL_NEEDS=(curl tar make gcc)
TOOL_JOBS=(check fetch build install verify)
TOOL_SLOW=1
TOOL_ENV_EXTRA="  \$OPENSSL_VERSION, \$ZLIB_VERSION, \$EXPAT_VERSION, \$CURL_VERSION
                  pin an individual dependency (defaults below)"
RECIPE_JOB_DESC[fetch]="download git and all four dependency tarballs"
RECIPE_JOB_DESC[build]="build+install openssl, zlib, expat, curl, then configure and make git"
RECIPE_JOB_DESC[install]="make install git into \$PREFIX"

# Pinned, known-good versions (override via env).
OPENSSL_VERSION="${OPENSSL_VERSION:-openssl-3.3.1}"
ZLIB_VERSION="${ZLIB_VERSION:-zlib-1.3.1}"
EXPAT_VERSION="${EXPAT_VERSION:-expat-2.6.2}"
CURL_VERSION="${CURL_VERSION:-curl-8.8.0}"

TOOL_USAGE_EXTRA="Dependency versions in effect:
  $OPENSSL_VERSION  $ZLIB_VERSION  $EXPAT_VERSION  $CURL_VERSION

Installs into \$PREFIX, so ~/.local/bin/git shadows /usr/bin/git for anyone
whose PATH puts ~/.local/bin first."

# expat's release tag uses the R_2_6_2 form rather than the tarball name.
EXPAT_TAG="R_$(printf '%s' "${EXPAT_VERSION#*-}" | tr . _)"

git_src() { printf '%s/git-%s' "$W" "$(rc_nov "$VER")"; }

# Every sub-build needs the same environment: find the headers and libraries
# the previous steps installed into $PREFIX, and prefer $BIN on PATH.
git_env() {
   rc_export \
      "PATH=$BIN:$PATH" \
      "PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig" \
      "LD_LIBRARY_PATH=$PREFIX/lib:${LD_LIBRARY_PATH:-}" \
      "CPPFLAGS=-I$PREFIX/include" \
      "LDFLAGS=-L$PREFIX/lib"
}

# build_dep <topdir> <configure argv...> -- configure, make, make install.
git_build_dep() {
   local top="$1"; shift
   echo "    --- $top"
   rc_dir "$W/$top"
   run "$@"                  || return 1
   run make -j"$(nproc)"     || return 1
   # openssl's `make install` also builds the man pages, which takes longer
   # than the library itself; install_sw is the software-only target.
   if [[ "$top" == openssl-* ]]; then
      run make install_sw    || return 1
   else
      run make install       || return 1
   fi
}

job_check() {
   local have upstream
   [[ -x "$BIN/git" ]] && have="$("$BIN/git" --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)"
   # git/git publishes tags, not GitHub "releases", so the releases API that
   # sm_gh_latest uses returns nothing here. Ask for tags directly, and drop
   # the -rc ones.
   upstream="$(git ls-remote --refs --tags "https://github.com/$TOOL_REPO" 'v*' 2>/dev/null \
      | sed 's#.*refs/tags/v##' | grep -vE 'rc[0-9]*$' | sort -V | tail -1)"
   echo "    target   : $VER  (pinned alongside $OPENSSL_VERSION $ZLIB_VERSION $EXPAT_VERSION $CURL_VERSION)"
   echo "    installed: ${have:-<not installed in \$BIN>}  (system git: $(command -v git >/dev/null && git --version | head -1 || echo none))"
   echo "    upstream : ${upstream:-<unreachable>}  ($TOOL_REPO)"
   if [[ -z "${have:-}" ]]; then
      record check WARN "no git in $BIN yet; would build $VER"
   elif [[ "$have" == "$(rc_nov "$VER")" ]]; then
      record check OK "up to date at $have"
   else
      record check WARN "installed $have; would build $VER"
   fi
}

job_fetch() {
   rc_workdir
   rc_fetch_extract "https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz"       || return 1
   rc_fetch_extract "https://zlib.net/${ZLIB_VERSION}.tar.gz"                        || return 1
   rc_fetch_extract "https://github.com/libexpat/libexpat/releases/download/${EXPAT_TAG}/${EXPAT_VERSION}.tar.gz" || return 1
   rc_fetch_extract "https://curl.se/download/${CURL_VERSION}.tar.gz"                || return 1
   rc_fetch "https://github.com/git/git/archive/refs/tags/v$(rc_nov "$VER").tar.gz" "git-$(rc_nov "$VER").tar.gz" || return 1
   rc_dir "$W"
   rc_extract "git-$(rc_nov "$VER").tar.gz"
}

job_build() {
   git_env
   # Order matters: curl is configured against the openssl and zlib built here.
   git_build_dep "$OPENSSL_VERSION" ./Configure --prefix="$PREFIX" \
      --openssldir="$PREFIX/ssl" no-shared linux-"$(uname -m)"          || return 1
   git_build_dep "$ZLIB_VERSION"  ./configure --prefix="$PREFIX"        || return 1
   git_build_dep "$EXPAT_VERSION" ./configure --prefix="$PREFIX"        || return 1
   git_build_dep "$CURL_VERSION"  ./configure --prefix="$PREFIX" \
      --with-ssl="$PREFIX" --with-zlib="$PREFIX" --disable-shared       || return 1

   echo "    --- git $VER"
   rc_dir "$(git_src)"
   run make clean                                                       # may not apply yet
   run make configure                                                   || return 1
   run ./configure --prefix="$PREFIX" \
      --with-curl="$PREFIX" --with-expat="$PREFIX" --with-zlib="$PREFIX" || return 1
   # NO_OPENSSL: git uses its own SHA1 and talks TLS through the curl built
   # above, so linking the static openssl into git itself is unnecessary.
   run make -j"$(nproc)" NO_OPENSSL=YesPlease
}

job_install() {
   git_env
   rc_dir "$(git_src)"
   run make install NO_OPENSSL=YesPlease
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
