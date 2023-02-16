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
            echo "Note: chmod 600 $dotfile -> ~/.ssh/config"
            rm -rf ~/.ssh/config && cp -f $cdir/initrc/$dotfile ~/.ssh/config
            if [[ -f ~/$corp/corp_hosts.txt ]]; then
               echo "Include ~/$corp/corp_hosts.txt" >> ~/.ssh/config
               chmod 600 ~/$corp/corp_hosts.txt
            fi
            chmod 600 ~/.ssh/config 
            ;;
         svn.*)
            echo "Note: copying $dotfile into ~/.subversion/ loc"
            command mkdir -p ~/.subversion
            linkup ${cdir}/${dotfile} ~/.subversion/${dotfile%.*}
            ;;
         gitconfig)
            echo "Note: creating ~/.gitconfig from $dotfile"
            rm -rf ~/.gitconfig && cp -f $cdir/initrc/$dotfile ~/.gitconfig
            sed -i "s/__USERNAME__/$USER/" ~/.gitconfig
            sed -i "s/__USEREMAIL__/$USER@gmail.com/" ~/.gitconfig
            ;;
         starship.toml)
            echo "Note: creating ~/.starship.toml from $dotfile"
            rm -rf ~/.starship.toml && cp -f $cdir/initrc/$dotfile ~/.starship.toml
            [[ -f ~/$corp/corp_starship.txt ]] && cat ~/$corp/corp_starship.txt >> ~/.starship.toml
            ;;
         alacritty.yml)
            echo "Note: copying to ~/.config/alacritty/$dotfile"
            mkdir -p ~/.config/alacritty
            rm -rf ~/.config/alacritty/alacritty.yml && linkup $cdir/initrc/$dotfile ~/.config/alacritty/alacritty.yml
            ;;
         z.sh|gitmux.conf|dircolors)
            # skip
            ;;
         *)
            # link
            linkup $cdir/initrc/$dotfile ~/.$dotfile
            ;;
      esac
   done
   command mkdir -p ~/.config
   pushd ~/.config >/dev/null && rm -rf ./nvim && ln -fs ~/dotfiles/nvim .
   popd >/dev/null
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
#{{{ getvimwiki
function getvimwiki() {
   if [[ ! $(curl --head --silent --fail git@github.com) ]]; then
      echo "Attention: no url access"
      return
   fi
   echo "Info: Installing Vimwiki"
   if [[ -d ~/vimwiki ]]; then
      pushd ~/vimwiki > /dev/null
         git fetch --all
         git checkout master
         git pull origin master
      popd > /dev/null
   else
      pushd ~/ > /dev/null
         git clone git@github.com:/mallicksm/vimwiki >/dev/null 2>&1
         if [[ $? != 0 ]]; then
            echo "Tried using git@.. protocol, now trying https://..."
            git clone https://github.com:/mallicksm/vimwiki >/dev/null 2>&1
            if [[ $? != 0 ]]; then
               echo "Failed using https://..."
            fi
         fi
      popd > /dev/null
   fi
}
#}}}

#-------------------------------------------------------------------------------
#{{{ getz
function getz () {
   echo "Info: Installing z"
   if [[ $(curl --head --silent --fail git@github.com) ]]; then
      src=https://raw.githubusercontent.com/rupa/z/master/z.sh
      target=~/dotfiles/initrc/z.sh
      [[ ! -f $target ]] && curl -L -s $src -o $target
   fi
}
#}}}

#-------------------------------------------------------------------------------
#{{{ getgitmux
function getgitmux() {
   echo "Info: Installing gitmux"
   if [[ $(curl --head --silent --fail git@github.com) ]]; then
      src=https://github.com/arl/gitmux/releases/download/v0.7.9/gitmux_0.7.9_linux_amd64.tar.gz
      target=~/.local/bin/gitmux
      mkdir -p $(dirname $target)
      [[ ! -f $target ]] && curl -L -s $src | tar xz -C $(dirname $target) || true
   fi
}
#}}}

#-------------------------------------------------------------------------------
#{{{ getstarship
function getstarship() {
   echo "Info: Installing starship"
   if [[ $(curl --head --silent --fail git@github.com) ]]; then
      src=https://starship.rs/install.sh
      target=~/.local/bin/starship
      mkdir -p $(dirname $target)
      [[ ! -f $target ]] && curl -L -s $src | sh /dev/stdin -b $(dirname $target) || true
   fi
}
#}}}

#-------------------------------------------------------------------------------
function all() {
   linkrc
#  getvimwiki
   getz
   getgitmux
   getstarship
}

echo "Executing ~/$corp/dotfiles.sh if any.."
[[ -f ~/$corp/dotfiles.sh ]] && source ~/$corp/dotfiles.sh

if [[ "$corp" == "" ]]; then
   echo "Please export corp=xxx"
   exit
fi

${1:-all}
