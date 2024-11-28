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
   [[ -f ~/$corp/corp_settings.sh ]] && ln -fs ~/$corp/corp_settings.sh ~/corp_settings.sh
   mydotfiles=$(command ls -1 $cdir/initrc/)
   for dotfile in ${mydotfiles[@]} ;do
      case $dotfile in
         # special cases
         config.ssh)
            info "Note: creating ~/.ssh/config from $dotfile"
            rm -rf ~/.ssh/config && cp -f $cdir/initrc/$dotfile ~/.ssh/config
            [[ -f ~/$corp/corp_hosts.txt ]] && cat ~/$corp/corp_hosts.txt >> ~/.ssh/config
            chmod 600 ~/.ssh/config 
            ;;
         gitconfig)
            info "Note: creating ~/.gitconfig from $dotfile"
            rm -rf ~/.gitconfig && cp -f $cdir/initrc/$dotfile ~/.gitconfig
            [[ -f ~/$corp/corp_gitconfig.txt ]] && cat ~/$corp/corp_gitconfig.txt >> ~/.gitconfig
            ;;
         starship.toml)
            info "Note: creating ~/.starship.toml from $dotfile"
            rm -rf ~/.starship.toml && cp -f $cdir/initrc/$dotfile ~/.starship.toml
            [[ -f ~/$corp/corp_starship.txt ]] && cat ~/$corp/corp_starship.txt >> ~/.starship.toml
            ;;
         alacritty.yml)
            info "Note: linking to ~/.config/alacritty/$dotfile"
            mkdir -p ~/.config/alacritty
            rm -rf ~/.config/alacritty/alacritty.{yml,toml} && linkup $cdir/initrc/$dotfile ~/.config/alacritty/alacritty.yml
            linkup $cdir/initrc/alacritty.toml  ~/.config/alacritty/alacritty.toml
            ;;
         lazygit.config.yml)
            info "Note: linking to ~/.config/lazygit/config.yml"
            mkdir -p ~/.config/lazygit
            rm -rf ~/.config/lazygit/config.yml && linkup $cdir/initrc/$dotfile $_
            ;;
         svn.*)
            info "Note: copying $dotfile to ~/.subversion/"
            command mkdir -p ~/.subversion
            linkup ${cdir}/initrc/${dotfile} ~/.subversion/${dotfile#*.}
            ;;
         cc)
            info "Note: copying $dotfile to ~/.local/bin/c99/"
            mkdir -p ~/.local/bin/c99 && cp ${cdir}/initrc/${dotfile} ~/.local/bin/c99/
            ;;
         z.sh|dircolors)
            # skip
            ;;
         *)
            # link
            linkup $cdir/initrc/$dotfile ~/.$dotfile
            ;;
      esac
   done
}
function linkup() {
   s=$1 # Source
   d=$2 # Destination
   rm -rf $d
   evalstr="ln -fs $s $d"
   echo "Info: $evalstr"
   eval $evalstr
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
#-------------------------------------------------------------------------------
function all() {
   linkrc
   clang-format
   getz
   getstarship
   zellij
   install_zvim
}

echo "Executing ~/$corp/dotfiles.sh if any.."
[[ -f ~/$corp/dotfiles.sh ]] && source ~/$corp/dotfiles.sh

if [[ "$corp" == "" ]]; then
   echo "Please export corp=xxx"
   exit
fi

${1:-all} $@
