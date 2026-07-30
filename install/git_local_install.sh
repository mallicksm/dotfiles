#!/usr/bin/env bash
#===============================================================================
# git_local_install.sh -- build git (and its deps) from source, non-root.
#
# Builds static openssl/zlib/expat/curl into ~/.local, then git against them,
# so you get a self-contained git with working https on boxes with an ancient
# system git. Versions are PINNED to the known-good set that produced the
# current (golden) toolchain; override any with the matching *_VERSION env var:
#     GIT_VERSION=2.47.1 ./git_local_install.sh
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

sm_require curl tar make gcc

# Pinned, known-good versions (override via env).
OPENSSL_VERSION="${OPENSSL_VERSION:-openssl-3.3.1}"
ZLIB_VERSION="${ZLIB_VERSION:-zlib-1.3.1}"
EXPAT_VERSION="${EXPAT_VERSION:-expat-2.6.2}"
CURL_VERSION="${CURL_VERSION:-curl-8.8.0}"
GIT_VERSION="${GIT_VERSION:-2.45.1}"

BUILD="$(sm_workdir git)"
export PATH="$BIN:$PATH"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export LD_LIBRARY_PATH="$PREFIX/lib:${LD_LIBRARY_PATH:-}"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

sm_build_dep() { # name url configure_cmd install_cmd tarball topdir
   local name="$1" url="$2" cfg="$3" inst="$4" tarball="$5" top="$6"
   sm_banner "$name" ""
   cd "$BUILD"
   sm_fetch_extract "$url"
   cd "$top"
   info "configuring $name"; eval "$cfg" > configure.log
   info "building $name";    make -j"$(nproc)" > build.log
   info "installing $name";  eval "$inst" > install.log
   cd "$BUILD"
}

# openssl
sm_build_dep openssl \
   "https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz" \
   "./Configure --prefix=$PREFIX --openssldir=$PREFIX/ssl no-shared linux-x86_64" \
   "make install_sw" "${OPENSSL_VERSION}.tar.gz" "$OPENSSL_VERSION"

# zlib
sm_build_dep zlib \
   "https://zlib.net/${ZLIB_VERSION}.tar.gz" \
   "./configure --prefix=$PREFIX" "make install" \
   "${ZLIB_VERSION}.tar.gz" "$ZLIB_VERSION"

# expat (release tag uses R_2_6_2 form)
expat_tag="R_$(printf '%s' "${EXPAT_VERSION#*-}" | tr . _)"
sm_build_dep expat \
   "https://github.com/libexpat/libexpat/releases/download/${expat_tag}/${EXPAT_VERSION}.tar.gz" \
   "./configure --prefix=$PREFIX" "make install" \
   "${EXPAT_VERSION}.tar.gz" "$EXPAT_VERSION"

# curl
sm_build_dep curl \
   "https://curl.se/download/${CURL_VERSION}.tar.gz" \
   "./configure --prefix=$PREFIX --with-ssl=$PREFIX --with-zlib=$PREFIX --disable-shared" \
   "make install" "${CURL_VERSION}.tar.gz" "$CURL_VERSION"

# git itself
sm_banner git "$GIT_VERSION"
cd "$BUILD"
gitdir="git-${GIT_VERSION}"
sm_fetch "https://github.com/git/git/archive/refs/tags/v${GIT_VERSION}.tar.gz" "${gitdir}.tar.gz"
sm_extract "${gitdir}.tar.gz"
cd "$gitdir"
make clean > clean.log 2>&1 || true
make configure
./configure --prefix="$PREFIX" --with-curl="$PREFIX" --with-expat="$PREFIX" \
   --with-zlib="$PREFIX" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" > configure.log
make -j"$(nproc)" NO_OPENSSL=YesPlease > build.log
make install NO_OPENSSL=YesPlease > install.log

completed "git ${GIT_VERSION} installed: $("$BIN/git" --version)"
# vim: ts=3 sts=3 sw=3 et
