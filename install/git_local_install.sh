#!/bin/bash
set -e

TEST=
PREFIX="$HOME/.local$TEST"
BUILD="$HOME/git-build$TEST"
mkdir -p "$PREFIX" "$BUILD"
cd "$BUILD"

export PATH="$PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
declare -A build_recipes

OPENSSL_VERSION="openssl-3.3.1"
build_recipes[openssl.url]="https://www.openssl.org/source/\$OPENSSL_VERSION.tar.gz"
build_recipes[openssl.config_cmd]="./Configure --prefix=\$PREFIX --openssldir=\$PREFIX/ssl no-shared linux-x86_64"
build_recipes[openssl.install_cmd]="make install_sw"

ZLIB_VERSION="zlib-1.3.1"
build_recipes[zlib.url]="https://zlib.net/\$ZLIB_VERSION.tar.gz"
build_recipes[zlib.config_cmd]="./configure --prefix=\$PREFIX"
build_recipes[zlib.install_cmd]="make install"

EXPAT_VERSION="expat-2.6.2"
expat_tag="$(echo "${EXPAT_VERSION#*-}" | tr . _)"
build_recipes[expat.url]="https://github.com/libexpat/libexpat/releases/download/R_\$expat_tag/\$EXPAT_VERSION.tar.gz"
build_recipes[expat.config_cmd]="./configure --prefix=\$PREFIX"
build_recipes[expat.install_cmd]="make install"

CURL_VERSION="curl-8.8.0"
build_recipes[curl.url]="https://curl.se/download/\$CURL_VERSION.tar.gz"
build_recipes[curl.config_cmd]="./configure --prefix=\$PREFIX --with-ssl=\$PREFIX --with-zlib=\$PREFIX --disable-shared"
build_recipes[curl.install_cmd]="make install"

build_from_recipe() {
   local name="$1"
   local version_var="${name^^}_VERSION"
   local version="${!version_var}"

   echo "→ URL: ${build_recipes[$name.url]}"

   # Download
   eval "curl -LO ${build_recipes[$name.url]}"
   tar xf "$version.tar.gz"

   cd "$version" || { echo "❌ Failed to enter $version"; exit 1; }

   # Configure
   echo "→ Configuring: ./configure ${build_recipes[$name.config_cmd]} > configure.log"
   eval "${build_recipes[$name.config_cmd]}" > configure.log

   # Build 
   echo "→ Compiling: make -j$(nproc) > build.log"
   make -j$(nproc) > build.log

   # install
   echo "→ Installing: ${build_recipes[$name.install_cmd]} > install.log"
   eval "${build_recipes[$name.install_cmd]}" > install.log

   cd ..
}
build_all_tools() {
   declare -A seen
   for key in "${!build_recipes[@]}"; do
      name="${key%%.*}"
      seen["$name"]=1
   done

   for name in "${!seen[@]}"; do
      version_var="${name^^}_VERSION"
      version="${!version_var}"
      echo ""
      echo "🔧 Building $name ($version)..."
      start_time=$(date +%s)
      build_from_recipe "$name"
      end_time=$(date +%s)
      elapsed=$((end_time - start_time))
      echo "✅ Finished building $name in $elapsed seconds"
   done
}
build_all_tools

GIT_VERSION="git-2.45.1"
git_tag="$(echo "${GIT_VERSION#*-}")"
echo ""
echo "🔧 Building git ($GIT_VERSION)..."

# Download
curl -L "https://github.com/git/git/archive/refs/tags/v$git_tag.tar.gz" -o "$GIT_VERSION.tar.gz"
tar xf "$GIT_VERSION.tar.gz"
cd "$GIT_VERSION"

# Cleanup
echo "→ Initial Cleanup: make clean..."
make clean > clean.log 2>&1 || true
make configure

# Configure
echo "→ Configuring: ./configure..."
./configure --prefix="$PREFIX"   --with-curl="$PREFIX"   --with-expat="$PREFIX"   --with-zlib="$PREFIX"   CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" > configure.log

# Build
echo "→ Compiling: make -j$(nproc) > build.log"
make -j$(nproc) NO_OPENSSL=YesPlease > build.log

# Install
echo "→ Installing: make install > install.log"
make install NO_OPENSSL=YesPlease > install.log

echo ""
echo "✅ Git $GIT_VERSION installed in $PREFIX/bin without direct OpenSSL usage"
echo "👉 Add to PATH if not already:"
echo "   export PATH=\"$PREFIX/bin:\$PATH\""
