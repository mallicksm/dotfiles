#!/usr/bin/env bash
#===============================================================================
# riscvgcc_local_install.sh -- build the RISC-V GNU toolchain from source.
#
# Builds texinfo, gmp and mpfr into ~/.local, then riscv-gnu-toolchain into
# ~/.local/tools/riscvgcc_<ts>, retags riscvgcc_latest and links its bin/*
# into ~/.local/bin.
#
# This is by far the longest build in here -- hours, not minutes.
#
# Tracks master by default; pin with $RISCVGCC_REF or -r.
#
# Spec: ~/dotfiles/install/recipe.md
#===============================================================================
set -uo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=riscvgcc
TOOL_DESC="RISC-V GNU cross toolchain (gcc, binutils, gdb)"
TOOL_REPO=riscv/riscv-gnu-toolchain
TOOL_PIN_VAR=RISCVGCC_REF
TOOL_PIN_DEFAULT=master
TOOL_PIN_IS_POLICY=1          # a branch, not a tag
TOOL_BINS=(riscv64-unknown-elf-gcc)
TOOL_NEEDS=(git curl tar make gcc g++)
TOOL_JOBS=(check fetch build install link verify)
TOOL_SLOW=1
TOOL_ENV_EXTRA="  \$TEXINFO_VERSION, \$GMP_VERSION, \$MPFR_VERSION
                  pin a build dependency (defaults: texinfo-7.1 gmp-6.3.0 mpfr-4.2.1)"
RECIPE_JOB_DESC[fetch]="download texinfo/gmp/mpfr and clone riscv-gnu-toolchain"
RECIPE_JOB_DESC[build]="build+install the three dependencies, then configure the toolchain"
RECIPE_JOB_DESC[install]="make the toolchain into \$TOOLSDIR/riscvgcc_<ts> and retag riscvgcc_latest"
RECIPE_JOB_DESC[link]="symlink \$TOOLSDIR/riscvgcc_latest/bin/* into \$BIN"

TEXINFO_VERSION="${TEXINFO_VERSION:-texinfo-7.1}"
GMP_VERSION="${GMP_VERSION:-gmp-6.3.0}"
MPFR_VERSION="${MPFR_VERSION:-mpfr-4.2.1}"

RISCVGCC_DST="$TOOLSDIR/riscvgcc_$(date +%Y_%b_%d_%H_%M_%S)"

# NOTE: colon, not semicolon. The pre-recipe version of this script had a
# PATH-breaking ';' here that silently poisoned the rest of the build.
riscv_env() {
   rc_export \
      "PATH=$BIN:$PATH" \
      "CPPFLAGS=-I$PREFIX/include" \
      "LDFLAGS=-L$PREFIX/lib" \
      "PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig"
}

riscv_build_dep() {
   local top="$1"; shift
   echo "    --- $top"
   rc_dir "$W/$top"
   run "$@"               || return 1
   run make -j"$(nproc)"  || return 1
   run make install
}

job_check() {
   local have
   [[ -x "$BIN/riscv64-unknown-elf-gcc" ]] \
      && have="$("$BIN/riscv64-unknown-elf-gcc" --version 2>/dev/null | head -1)"
   echo "    target ref: $VER"
   echo "    installed : ${have:-<not installed>}"
   echo "    latest dir: $(readlink "$TOOLSDIR/riscvgcc_latest" 2>/dev/null || echo '<none>')"
   if [[ -z "${have:-}" ]]; then
      record check WARN "not installed yet; would build $VER (expect hours)"
   else
      record check OK "installed ($have); rebuilding $VER picks up any new commits"
   fi
}

job_fetch() {
   rc_workdir
   rc_fetch_extract "https://ftp.gnu.org/gnu/texinfo/${TEXINFO_VERSION}.tar.gz" || return 1
   rc_fetch_extract "https://ftp.gnu.org/gnu/gmp/${GMP_VERSION}.tar.xz"         || return 1
   rc_fetch_extract "https://ftp.gnu.org/gnu/mpfr/${MPFR_VERSION}.tar.xz"       || return 1
   rc_dir "$W"
   run git clone "https://github.com/$TOOL_REPO" riscvgcc-src || return 1
   if [[ "$VER" != master ]]; then
      rc_dir "$W/riscvgcc-src"
      run git checkout "$VER"
   fi
}

job_build() {
   riscv_env
   riscv_build_dep "$TEXINFO_VERSION" ./configure --prefix="$PREFIX"                      || return 1
   riscv_build_dep "$GMP_VERSION"     ./configure --prefix="$PREFIX" --enable-cxx         || return 1
   riscv_build_dep "$MPFR_VERSION"    ./configure --prefix="$PREFIX" --with-gmp="$PREFIX" || return 1

   echo "    --- riscv-gnu-toolchain $VER"
   rc_dir "$W/riscvgcc-src"
   rc_export "GDB_CONFIGURE_ARGS=--with-gmp=$PREFIX --with-mpfr=$PREFIX"
   run ./configure --prefix="$RISCVGCC_DST"
}

job_install() {
   riscv_env
   rc_dir "$W/riscvgcc-src"
   # No -j here on purpose: riscv-gnu-toolchain's make self-parallelizes and
   # adding our own -j oversubscribes the box badly.
   run make || return 1
   step / ln -sfn "$RISCVGCC_DST" "$TOOLSDIR/riscvgcc_latest"
   record install OK "$RISCVGCC_DST (riscvgcc_latest retagged)"
}

job_link() {
   rc_link_tree_bins "$TOOLSDIR/riscvgcc_latest"
}

recipe_main "$@"
# vim: ts=3 sts=3 sw=3 et
