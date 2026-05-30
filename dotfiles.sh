#!/usr/bin/env bash
#===============================================================================
# Bash Script
# Created: Feb-14-2023
# Author: soummya
#
# Note:
#
# Description: dotfiles executor to setup Unix environment.
#
#===============================================================================
# shellcheck source=utils/bash_snippets.sh
source ~/dotfiles/utils/bash_snippets.sh 2> /dev/null
cdir=$(dirname "$(realpath "$0")")

#-------------------------------------------------------------------------------
# --dry-run / -n : show every filesystem change without performing it.
# Recognized in any position; stripped before the action dispatch below.
DRY_RUN=0
__df_args=()
for __df_a in "$@"; do
   case "$__df_a" in
      --dry-run|-n) DRY_RUN=1 ;;
      *) __df_args+=("$__df_a") ;;
   esac
done
set -- "${__df_args[@]}"
unset __df_args __df_a
if [[ "$DRY_RUN" == "1" ]]; then
   warn "DRY-RUN mode: no filesystem changes will be made"
fi

# _dry_install <label> : in dry-run, print the install intent and return 0
# so the caller can `&& return` out of any install_* / get* function.
# In normal mode, returns 1 (caller proceeds with real work).
function _dry_install() {
   [[ "$DRY_RUN" == "1" ]] || return 1
   warn "  [dry-run] install  $*"
   return 0
}
#-------------------------------------------------------------------------------
# linkrc -link dotfiles
function linkrc() {
   linkup ~/corp/corp_settings.sh ~/corp_settings.sh

   declare -A link_map=(
      ["alacritty.toml"]="$HOME/.config/alacritty/alacritty.toml"
      ["atuin.toml"]="$HOME/.config/atuin/config.toml"
      ["bash_atuin.sh"]="$HOME/.bash_atuin.sh"
      ["kitty"]="$HOME/.config/kitty"
      ["gitk"]="$HOME/.config/git/gitk"
      ["config.ssh"]="$HOME/.ssh/config"
      ["cc"]="$HOME/.local/bin/c99/cc"
      ["z.sh"]="/dev/null"
      ["zellij"]="/dev/null"
   )

   mydotfiles=$(command ls -1 $cdir/initrc/)
   for dotfile in ${mydotfiles[@]}; do
      dest="${link_map[$dotfile]:-$HOME/.$dotfile}"
      info "Linking $dotfile → $dest"
      linkup "$cdir/initrc/$dotfile" "$dest"
   done

   link_kitty_os
}

#-------------------------------------------------------------------------------
# link_kitty_os - per-OS kitty.conf overrides ("ifdef mac vs linux")
# Picks kitty.<darwin|linux>.conf based on `uname` and exposes it as
# kitty.os.conf inside the kitty config dir, where kitty.conf
# globincludes it. The symlink is per-machine and gitignored, so the
# repo stays OS-agnostic.
function link_kitty_os() {
   local kitty_dir="$cdir/initrc/kitty"
   local os src target curr
   case "$(uname -s)" in
      Darwin) os="darwin" ;;
      Linux)  os="linux"  ;;
      *)      warn "unknown OS $(uname -s); skipping kitty.os.conf"; return ;;
   esac
   src="kitty.${os}.conf"
   target="$kitty_dir/kitty.os.conf"
   if [[ ! -f "$kitty_dir/$src" ]]; then
      warn "$kitty_dir/$src not found; skipping kitty.os.conf"
      return
   fi
   if [[ -L "$target" ]]; then curr="$(readlink "$target")"; else curr="(absent)"; fi
   if [[ "$curr" == "$src" ]]; then
      [[ "$DRY_RUN" == "1" ]] && completed "  [dry-run] keep   $target  →  $src"
      return
   fi
   if [[ "$DRY_RUN" == "1" ]]; then
      warn "  [dry-run] link   $target  →  $src    [was: $curr]    ($(uname -s))"
      return
   fi
   info "Linking kitty.os.conf → $src ($(uname -s))"
   ln -sf "$src" "$target"
}
function linkup() {
   s=$1 # Source
   d=$2 # Destination

   if [[ "$d" == "/dev/null" ]]; then
      echo "Info: Skipping link for $s → $d"
      return
   fi

   local curr
   if [[ -L "$d" ]]; then
      curr="symlink → $(readlink "$d")"
   elif [[ -d "$d" ]]; then
      curr="directory"
   elif [[ -e "$d" ]]; then
      curr="regular file"
   else
      curr="(absent)"
   fi

   if [[ -L "$d" && "$(readlink "$d")" == "$s" ]]; then
      [[ "$DRY_RUN" == "1" ]] && completed "  [dry-run] keep   $d  →  $s"
      return
   fi

   if [[ "$DRY_RUN" == "1" ]]; then
      warn "  [dry-run] link   $d  →  $s    [was: $curr]"
      return
   fi

   parent_dir=$(dirname "$d")
   mkdir -p "$parent_dir"
   rm -f "$d"
   ln -fs "$s" "$d"
}

#-------------------------------------------------------------------------------
function install_zvim() {
   linkup ~/dotfiles/utils/zvim ~/.local/bin/zvim
}
#-------------------------------------------------------------------------------
# shellcheck disable=SC2120  # invoked via dispatcher; args optional
function zellij() {
   local force="" arg
   for arg in "$@"; do
      [[ "$arg" == "-f" || "$arg" == "--force" ]] && force="yes"
   done
   _dry_install "zellij  →  ~/.local/bin/zellij${force:+  (force)}" && return
   echo "Info: Installing zellij"
   if [[ $(uname -s) == "Linux" ]]; then
      local src target tarball
      src="https://github.com/zellij-org/zellij/releases/latest/download/zellij-$(uname -m)-unknown-linux-musl.tar.gz"
      target=~/.local/bin/zellij
      tarball="${src##*/}"
      if [[ (! -f $target) || ($force == "yes") ]]; then
         mkdir -p "$(dirname "$target")"
         Pushd "$(dirname "$target")"
         if download "$src" && tar -xz -f "$tarball"; then
            chmod +x "$target"
            "$target" --version
         else
            echo "Info: zellij install failed (download or extract)"
         fi
         rm -f "$tarball"
         Popd
      else
         echo "Info: Already installed ($("$target" --version 2>/dev/null)). Pass -f to force reinstall."
      fi
   elif [[ $(uname -s) == "Darwin" ]]; then
      if [[ "$force" == "yes" ]]; then
         brew reinstall zellij
      else
         brew install zellij
      fi
   else
      echo "Attention: unsupported OS"
   fi
}

#-------------------------------------------------------------------------------
function clang-format() {
   _dry_install "clang-format  →  ~/.local/bin/clang-format" && return
   echo "Info: Installing clang-format"
   if [[ $(uname -s) == "Linux" ]]; then
      src=https://github.com/muttleyxd/clang-tools-static-binaries/releases/download/master-f4f85437/clang-format-16_linux-amd64
      target=~/.local/bin/clang-format
      if [[ ! -f $target ]]; then
         Pushd "$(dirname $target)"
         download "$src" && mv "${src##*/}" "$(basename $target)" && chmod +x "$(basename $target)" || echo "Info: Download failed"
         Popd
      fi
   elif [[ $(uname -s) == "Darwin" ]]; then
      brew install clang-format
   else
      echo "Attention: unsupported OS"
   fi
}

#-------------------------------------------------------------------------------
function getz() {
   _dry_install "z.sh  →  ~/dotfiles/initrc/z.sh" && return
   echo "Info: Installing z"
   src=https://raw.githubusercontent.com/rupa/z/master/z.sh
   target=~/dotfiles/initrc/z.sh
   if [[ ! -f $target ]]; then
      Pushd "$(dirname $target)"
      download "$src" && mv "${src##*/}" "$(basename $target)" || echo "Info: Download failed"
      Popd
   fi
}

#-------------------------------------------------------------------------------
function getstarship() {
   _dry_install "starship  →  ~/.local/bin/starship" && return
   echo "Info: Installing starship"
   local src target tmpdir
   src=https://starship.rs/install.sh
   target=~/.local/bin/starship
   mkdir -p "$(dirname "$target")"
   if [[ ! -f "$target" ]]; then
      tmpdir=$(mktemp -d)
      Pushd "$tmpdir"
      download "$src" && sh "${src##*/}" -b "$(dirname "$target")" || echo "Info: Download/install failed"
      Popd
      rm -rf "$tmpdir"
   fi
}
function getfzf() {
   _dry_install "fzf  →  ~/.fzf (git clone)" && return
   [[ ! -d ~/.fzf ]] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
}
# getfonts [-f|--force] [Family ...]
# Install one or more Nerd Fonts from ryanoasis/nerd-fonts into
# ~/.local/share/fonts/<Family>/. Each Family is the basename of the release
# asset (e.g. FiraCode, Hack, JetBrainsMono, Meslo, Iosevka, CascadiaCode).
# With no args, installs the default set. Skips families already present
# unless -f/--force is passed. Refreshes fontconfig cache at the end.
function getfonts() {
   # The bottom-of-file dispatcher `"${1:-all}" "$@"` passes the function
   # name itself as $1; absorb it so it isn't treated as a font family.
   [[ "${1:-}" == "getfonts" ]] && shift
   local force="" arg families=()
   for arg in "$@"; do
      case "$arg" in
         -f|--force) force="yes" ;;
         -*) warn "getfonts: unknown flag $arg"; return 2 ;;
         *) families+=("$arg") ;;
      esac
   done
   [[ ${#families[@]} -eq 0 ]] && families=(FiraCode Hack)

   local fontdir="$HOME/.local/share/fonts"
   local fam target src zip
   for fam in "${families[@]}"; do
      target="$fontdir/$fam"
      src="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${fam}.zip"
      _dry_install "$fam Nerd Font  →  $target${force:+  (force)}" && continue
      if [[ -d "$target" && -n "$(command ls -A "$target" 2>/dev/null)" && "$force" != "yes" ]]; then
         info "$fam already installed at $target (pass -f to reinstall)"
         continue
      fi
      info "Installing $fam Nerd Font"
      mkdir -p "$target"
      Pushd "$target"
      zip="${src##*/}"
      if download "$src" && unzip -oq "$zip"; then
         rm -f "$zip"
         completed "$fam → $target"
      else
         error "$fam install failed (download or unzip)"
         rm -f "$zip"
      fi
      Popd
   done

   if has fc-cache; then
      info "Refreshing fontconfig cache"
      fc-cache -f "$fontdir" >/dev/null 2>&1
   fi
}
getnpm() {
   local NODE_VERSION="v20.12.2"
   local ARCH="linux-x64"
   local INSTALL_DIR="$HOME/.local/node"
   local TARBALL="node-$NODE_VERSION-$ARCH.tar.xz"
   local URL="https://nodejs.org/dist/$NODE_VERSION/$TARBALL"

   _dry_install "node $NODE_VERSION + npm  →  $INSTALL_DIR" && return

   echo "📦 Downloading Node.js $NODE_VERSION for $ARCH..."
   download "$URL" || {
      echo "❌ Failed to download Node.js"
      return 1
   }

   echo "📂 Extracting to $INSTALL_DIR..."
   mkdir -p "$INSTALL_DIR"
   tar -xf "$TARBALL" --strip-components=1 -C "$INSTALL_DIR" || {
      echo "❌ Failed to extract"
      return 1
   }

   echo "🧹 Cleaning up..."
   rm "$TARBALL"

   echo "✅ Node and npm installed locally in $INSTALL_DIR"
   "$INSTALL_DIR/bin/node" -v
   "$INSTALL_DIR/bin/npm" -v
}

#-------------------------------------------------------------------------------
# shellcheck disable=SC2120  # invoked via dispatcher; args optional
function all() {
   linkrc
   clang-format
   getz
   getstarship
   zellij "$@"   # forward -f/--force through to the zellij installer
   install_zvim
   getfzf
}

echo "Executing ~/corp/dotfiles.sh if any.."
# shellcheck source=/dev/null   # corp file may not exist on every host
[[ -f ~/corp/dotfiles.sh ]] && source ~/corp/dotfiles.sh

if [[ -z "${corp:-}" ]]; then
   echo "Please export corp=xxx"
   exit
fi

"${1:-all}" "$@"
