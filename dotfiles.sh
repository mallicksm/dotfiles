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
source ~/dotfiles/utils/bash_snippets.sh 2>/dev/null
cdir=$(dirname $(realpath $0))
#-------------------------------------------------------------------------------
# linkrc -link dotfiles
function linkrc () {
   linkup ~/corp/corp_settings.sh ~/corp_settings.sh

   declare -A link_map=(
      [alacritty.toml]="$HOME/.config/alacritty/alacritty.toml"
      [kitty]="$HOME/.config/kitty"
      [gitk]="$HOME/.config/git/gitk"
      [config.ssh]="$HOME/.ssh/config"
      [cc]="$HOME/.local/bin/c99/cc"
      [z.sh]="/dev/null"
      [zellij]="/dev/null"
   )

   mydotfiles=$(command ls -1 $cdir/initrc/)
   for dotfile in ${mydotfiles[@]} ;do
      dest="${link_map[$dotfile]:-$HOME/.$dotfile}"
      info "Linking $dotfile → $dest"
      linkup "$cdir/initrc/$dotfile" "$dest"
   done
}
function linkup() {
   s=$1 # Source
   d=$2 # Destination

   if [[ "$d" == "/dev/null" ]]; then
      echo "Info: Skipping link for $s → $d"
      return
   fi
   parent_dir=$(dirname "$d")
   mkdir -p "$parent_dir"
   rm -f "$d"
   ln -fs "$s" "$d"
}

#-------------------------------------------------------------------------------
function install_zvim() {
   ln -sf ~/dotfiles/utils/zvim ~/.local/bin/zvim
}
#-------------------------------------------------------------------------------
function zellij() {
   if [[ $2 == "-f" ]]; then
      force="yes"
   fi
   # https://github.com/muttleyxd/clang-tools-static-binaries
   echo "Info: Installing zellij"
   if [[ $(curl --head --silent --fail git@github.com) && ($(uname -s) == "Linux") ]]; then
      src="https://github.com/zellij-org/zellij/releases/latest/download/zellij-$(uname -m)-unknown-linux-musl.tar.gz"
      target=~/.local/bin/zellij
      [[ (! -f $target) || ($force == "yes") ]] && curl -L "$src" | tar -C "$(dirname $target)" -xz || echo "Info: Already Installed"
   elif [[ $(uname -s) == "Darwin" ]]; then
      brew install zellij
   else
      echo "Attention: no url access or not Linux"
   fi
}

#-------------------------------------------------------------------------------
function clang-format() {
   # https://github.com/muttleyxd/clang-tools-static-binaries
   echo "Info: Installing clang-format"
   if [[ $(curl --head --silent --fail git@github.com) && ($(uname -s) == "Linux") ]]; then
      src=https://github.com/muttleyxd/clang-tools-static-binaries/releases/download/master-f4f85437/clang-format-16_linux-amd64
      target=~/.local/bin/clang-format
      [[ ! -f $target ]] && curl -L -s $src -o $target && chmod +x $target
   elif [[ $(uname -s) == "Darwin" ]]; then
      brew install clang-format
   else
      echo "Attention: no url access or not Linux"
   fi
}

#-------------------------------------------------------------------------------
function getz () {
   echo "Info: Installing z"
   if [[ $(curl --head --silent --fail git@github.com) ]]; then
      src=https://raw.githubusercontent.com/rupa/z/master/z.sh
      target=~/dotfiles/initrc/z.sh
      [[ ! -f $target ]] && curl -L -s $src -o $target
   else
      echo "Attention: no url access"
   fi
}

#-------------------------------------------------------------------------------
function getstarship() {
   echo "Info: Installing starship"
   if [[ $(curl --head --silent --fail git@github.com) ]]; then
      src=https://starship.rs/install.sh
      target=~/.local/bin/starship
      mkdir -p $(dirname $target)
      [[ ! -f $target ]] && curl -L -s $src | sh /dev/stdin -b $(dirname $target) || true
   else
      echo "Attention: no url access"
   fi
}
function getfzf() {
   [[ ! -f ~/.fzf ]] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
}
function getfonts() {
   # Create fonts directory if needed
   mkdir -p ~/.local/share/fonts

# Download and unzip
   curl -fLo ~/.local/share/fonts/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
   unzip ~/.local/share/fonts/FiraCode.zip -d ~/.local/share/fonts/FiraCode
   rm ~/.local/share/fonts/FiraCode.zip
}
getnpm() {
   local NODE_VERSION="v20.12.2"
   local ARCH="linux-x64"
   local INSTALL_DIR="$HOME/.local/node"
   local TARBALL="node-$NODE_VERSION-$ARCH.tar.xz"
   local URL="https://nodejs.org/dist/$NODE_VERSION/$TARBALL"

   echo "📦 Downloading Node.js $NODE_VERSION for $ARCH..."
   curl -LO "$URL" || { echo "❌ Failed to download Node.js"; return 1; }

   echo "📂 Extracting to $INSTALL_DIR..."
   mkdir -p "$INSTALL_DIR"
   tar -xf "$TARBALL" --strip-components=1 -C "$INSTALL_DIR" || { echo "❌ Failed to extract"; return 1; }

   echo "🧹 Cleaning up..."
   rm "$TARBALL"

   echo "✅ Node and npm installed locally in $INSTALL_DIR"
   "$INSTALL_DIR/bin/node" -v
   "$INSTALL_DIR/bin/npm" -v
}

#-------------------------------------------------------------------------------
function all() {
   linkrc
   clang-format
   getz
   getstarship
   zellij
   install_zvim
   getfzf
}

echo "Executing ~/corp/dotfiles.sh if any.."
[[ -f ~/corp/dotfiles.sh ]] && source ~/corp/dotfiles.sh

if [[ "$corp" == "" ]]; then
   echo "Please export corp=xxx"
   exit
fi

${1:-all} $@
